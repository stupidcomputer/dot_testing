#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <sys/inotify.h>

#include "message.h"
#include "common.h"

int mod_message(char *config, char *name, char *pipename) {
	struct message msg;
	struct inotify_event buf;
	strcpy(msg.name, name);

	int fd = inotify_init();
	int outfd = open(pipename, O_WRONLY);

	for(;;) {
		int watchdesc = inotify_add_watch(fd, config, IN_MODIFY);
		read(fd, &buf, sizeof(struct inotify_event));

		/* the file's changed, so reread it */
		int filefd = open(config, O_RDONLY, 0);
		int read_in = read(filefd, msg.content, sizeof(msg.content));
		msg.content[read_in - 1] = '\0';
		close(filefd);

		/* write the new */
		write(outfd, &msg, sizeof(msg));
		inotify_rm_watch(fd, watchdesc); /* not sure why this is needed */
	}

	return 0;
}
