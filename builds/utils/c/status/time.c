#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <string.h>

#include "common.h"
#include "time.h"

int mod_time(char *config, char *name, char *pipename) {
	struct message msg;
	time_t now;
	struct tm *tm;
	int fd;

	strcpy(msg.name, name);
	msg.flags = 0;
	fd = open(pipename, O_WRONLY);

	for(;;) {
		time(&now);
		tm = localtime(&now);
		strftime(msg.content, 512, "%H:%M", tm);
		write(fd, &msg, sizeof(msg));

		sleep(60);
	}
}
