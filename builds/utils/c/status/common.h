#ifndef STATUS_COMMON_H
#define STATUS_COMMON_H

#define LENGTH(x)	sizeof(x) / sizeof(x[0])
#define BUFFER_SIZE 512

struct module {
	int (*fork_callback)(char *config, char *name, char *pipename);
	char name[16];
	char config[512];
	char buffer[512];
	int buflen;
};

struct message {
	int flags;
	char name[16];
	char content[512];
};

#endif
