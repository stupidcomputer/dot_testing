#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <fcntl.h>

#include "battery.h"
#include "common.h"

/* config contains a path to the battery */
int mod_battery(char *config, char *name, char *pipename) {
	struct message msg;
	strcpy(msg.name, name);

	int fd = open(pipename, O_WRONLY);
	int battery;
	int recvd;

	chdir("/sys/class/power_supply");
	chdir(config);

	for(;;) {
		battery = open("capacity", O_RDONLY);
		recvd = read(battery, msg.content, 3);
		msg.content[3] = '\0';
		if (msg.content[2] == '\n') {
			msg.content[2] = '\0';
		}
		close(battery);
		write(fd, &msg, sizeof(msg));

		sleep(30);
	}

	return 0;
}
