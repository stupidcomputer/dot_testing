#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <time.h>
#include <fcntl.h>

#include <xcb/xcb.h>

#include <string.h>

#include "common.h"
#include "battery.h"
#include "battstatus.h"
#include "bspwm.h"
#include "time.h"
#include "message.h"

struct module mods[] = {
	{mod_battery, "battery", "BAT0", { '\0' }},
	{mod_battstatus, "battstatus", "BAT0", { '\0' }},
	{mod_time, "time", "", { '\0' }},
	{mod_bspwm, "bspwm", "", { '\0' }},
/*	{mod_message, "message", "/home/usr/.cache/statusbar_notification", { '\0' }}, */
};

void create_module_proc(int index, char *pipename) {
	pid_t pid = fork();

	if (pid == 0) { /* we're the child */
		mods[index].fork_callback(
			mods[index].config,
			mods[index].name,
			pipename
		);
	}
}

void create_module_procs(char *pipename) {
	for(int i = 0; i < LENGTH(mods); i++) {
		create_module_proc(i, pipename);
	}
}

void redraw() {
	/* get the progress' module's value, convert it to int, and then
	 * figure out how much of the screen should be shaded in */

	printf("\033[H\033[2J");
	for(int i = 0; i < LENGTH(mods); i++) {
		if (i == 0) printf("%s ", mods[i].buffer);
		else printf("| %s ", mods[i].buffer);
	}

	fflush(stdout);
}

static char NAMED_PIPE[] = "/home/usr/.cache/statusbar_pipe";

int main(void) {
	srand(time(NULL));
	mkfifo(&NAMED_PIPE, 0666); /* it's okay if this fails */
	int fd = open(&NAMED_PIPE, O_RDWR);
	struct message msg;

	create_module_procs(&NAMED_PIPE);

	for (;;) {
		int ret = read(fd, &msg, sizeof(msg));
		if(ret < 0) {
			printf("error while reading message from child\n");
		}

		for(int i = 0; i < LENGTH(mods); i++) {
			if(strcmp(mods[i].name, msg.name) == 0) {
				mods[i].buflen = strlen(msg.content);
				strcpy(mods[i].buffer, msg.content);
				redraw();
				break;
			}
		}
	}

	return 0;
}
