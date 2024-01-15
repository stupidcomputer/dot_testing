#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <xcb/xcb.h>
#include <fcntl.h>

#include "bspwm.h"
#include "common.h"

const char subscribe[] = "subscribe";

int get_socket(void) {
	struct sockaddr_un sock;
	char *host;
	int displaynumber, screennumber;
	int fd;

	xcb_parse_display(NULL, &host, &displaynumber, &screennumber);

	sock.sun_family = AF_UNIX;
	snprintf(
		sock.sun_path,
		sizeof(sock.sun_path), "/tmp/bspwm%s_%i_%i-socket",
		host, displaynumber, screennumber
	);

	free(host);

	fd = socket(AF_UNIX, SOCK_STREAM, 0);
	if (connect(
		fd,
		(struct sockaddr *) &sock,
		sizeof(sock)
	) == -1) {
		return -1;
	} else {
		return fd;
	}
}

int should_be_shown(char c) {
	return c == 'O' || c == 'o' || c == 'F' || c == 'U' || c == 'u';
}

int is_a_desktop(char c) {
	return c == 'O' || c == 'o' || c == 'F' || c == 'f' || c == 'U' || c == 'u';
}

/* XXX: this function has the potential to buffer overflow by ONE BYTE.
 * probably fix this? */
void print_desktop_status(char *in, char *out, int outlen) {
	int written;
	int i;
	char c;

	/* flags */
	int read_colon;
	int skip_to_next_colon;
	int read_until_colon;
	int is_first_desktop;
	int last_was_desktop;

	i = 0;
	written = 0;
	read_colon = 1;
	skip_to_next_colon = 0;
	read_until_colon = 0;
	is_first_desktop = 1;
	last_was_desktop = 0;

	for(;;) {
		c = in[i];

		if(!c) break;
		if(written == outlen) break;

		if (skip_to_next_colon) {
			if (c == ':') {
				skip_to_next_colon = 0;
				read_until_colon = 0;
				read_colon = 1;
			} else if (read_until_colon) {
				out[written] = c;
				written++;
			}
		} else if (read_colon && should_be_shown(c)) {
			if (!is_first_desktop) {
				out[written] = ' ';
				written++;
			}

			switch(c) {
				case 'O':
				case 'F': /* fallthrough */
					out[written] = '*';
					written++;
					break;
			}

			skip_to_next_colon = 1;
			read_until_colon = 1;
			read_colon = 0;
			is_first_desktop = 0;
			last_was_desktop = 1;
		} else if (read_colon && is_a_desktop(c)) {
			last_was_desktop = 1;
		} else {
			if(last_was_desktop) {
				break;
			}
		}
		i++;
	}

	out[written] = '\0';
}

int mod_bspwm(char *config, char *name, char *pipename) {
	struct message msg;
	int fd, bspcfd;
	char in[BUFFER_SIZE];

	strcpy(msg.name, name);
	msg.flags = 0;

	fd = open(pipename, O_WRONLY);
	bspcfd = get_socket();

	send(bspcfd, subscribe, sizeof(subscribe), 0);

	for(;;) {
		int recvd = recv(bspcfd, in, BUFFER_SIZE, 0);
		print_desktop_status(in, msg.content, 512);
		write(fd, &msg, sizeof(msg));
		memset(msg.content, 0, 512);
	}

	return 0;
}
