#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>

#include "battstatus.h"
#include "common.h"

int mod_battstatus(char *config, char *name, char *pipename) {
	char status;
	int battery;
	struct message msg;
	strcpy(msg.name, name);

	int fd = open(pipename, O_WRONLY);

	chdir("/sys/class/power_supply");
	chdir(config);

	for(;;) {
		battery = open("status", O_RDONLY);
		read(battery, msg.content, 1);
		switch(msg.content[0]) {
			case 'N': /* not charging */
				msg.content[0] = '-';
				break;
			case 'C': /* charging */
				msg.content[0] = '^';
				break;
			case 'D': /* discharging */
				msg.content[0] = 'U';
				break;
			case 'U': /* unknown */
				msg.content[0] = '?';
				break;
			default: /* what's going on? */
				msg.content[0] = '!';
				break;
		}
		msg.content[1] = '\0';
		close(battery);
		write(fd, &msg, sizeof(msg));

		sleep(30);
	}

	return 0;
}
