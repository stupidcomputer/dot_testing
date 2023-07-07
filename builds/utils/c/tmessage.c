#include <sys/ioctl.h>
#include <ctype.h>
#include <termios.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#define ESC_CLEAR "\033[2J"
#define ESC_CUSHOME "\033[H"
#define ESC_NEWLINE "\033[E\033[1C"

const char MSG_OK[] = "(O)k";
const char MSG_CANCEL[] = "(C)ancel";

typedef struct winsize ws;

int lines, cols;
char *message;
size_t message_len;

struct termios original_termios;

void render(char *message, int message_len, int lines, int cols);

void rawmode_start() {
	tcgetattr(STDIN_FILENO, &original_termios);
	struct termios raw = original_termios;
	raw.c_lflag &= ~(ECHO | ICANON);
	tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void rawmode_stop() {
	tcsetattr(STDIN_FILENO, TCSAFLUSH, &original_termios);
	printf("\n\n");
	fflush(stdout);
}

ws *getWinSize(void) {
	/* we're only going to use these values once per invocation,
	 * so it's fine that it's static. */
	static ws w;
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

	return &w;
}

void handler(int signal, siginfo_t *info, void *context) {
	ws *w = getWinSize();
	lines = w->ws_row;
	cols = w->ws_col;

	render(message, message_len, lines, cols);
	return;
}

void termhandler(int signal, siginfo_t *info, void *context) {
	rawmode_stop();

	return;
}

int calculate_number_of_lines(int length, int cols) {
	/* cols - 1 accounts for right padding */
	return length / (cols - 1) + 1;
}

void go_to_initial_message_printing_pos(void) {
	printf(ESC_CUSHOME "\033[1B\033[1C");
}

void print_message(char *message, int messagelen, int cols) {
	int linecount = calculate_number_of_lines(messagelen, cols);
	int adjcols = cols - 2;
	int offset = 1;
	for(int character = 0; character < messagelen; character++) {
		if(character == adjcols * offset) {
			printf(ESC_NEWLINE);
			offset++;
		}
		putchar(message[character]);
	}
}

void render(char *message, int messagelen, int lines, int cols) {
	int cancel_length = sizeof(MSG_CANCEL) / sizeof(MSG_CANCEL[0]);

	/* print the stuff */
	printf(ESC_CLEAR "" ESC_CUSHOME);
	go_to_initial_message_printing_pos();
	print_message(message, message_len, cols);

	printf(ESC_NEWLINE);
	printf(ESC_NEWLINE);
	printf("%s", MSG_OK);
	printf("\033[1D\033[%iC\033[%iD%s", cols, cancel_length, MSG_CANCEL);
	fflush(stdout);
}

int main(int argc, char **argv) {
	int cancel_length = strlen(MSG_CANCEL);
	char c;
	struct sigaction resizeaction = {};
	struct sigaction termaction = {};
	ws *w;

	/* check if we have a message */
	if(argc > 1) {
		message = argv[1]; /* second argument's a message */
		message_len = strlen(message);
	} else {
		return 1;
	}

	/* setup sigaction handlers */
	resizeaction.sa_sigaction = &handler;
	if(sigaction(SIGWINCH, &resizeaction, NULL) == -1) {
		return 1;
	}

	termaction.sa_sigaction = &termhandler;
	if(sigaction(SIGTERM, &termaction, NULL) == -1) {
		return 1;
	}

	rawmode_start();

	/* get window properties */
	w = getWinSize();
	lines = w->ws_row;
	cols = w->ws_col;

	render(message, message_len, lines, cols);

	for(;;) {
		read(STDIN_FILENO, &c, 1);
		if(c == 'o') {
			return 2;
			rawmode_stop();
		} else if(c == 'c') {
			return 3;
			rawmode_stop();
		}
	}

	return 0;
}
