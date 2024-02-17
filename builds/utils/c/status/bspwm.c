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
		int recvd = recv(bspcfd, msg.content, sizeof(msg.content), 0);
		msg.content[recvd - 1] = '\0';
		write(fd, &msg, sizeof(msg));
		memset(msg.content, 0, 512);
	}

	return 0;
}
