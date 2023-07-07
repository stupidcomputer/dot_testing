#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <errno.h>
#include <time.h>
#include <stddef.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <unistd.h>
#include <string.h>

struct color {
	int r;
	int g;
	int b;
};

void init_random(void) {
	srand(time(0));
}

int rand_range(int u, int l) {
	return (rand() % (u - l + 1)) + l;
}

void exec_with_stdout(char *file, char *args[], char *buf, int length) {
	int pfds[2];
	pipe(pfds);
	int status = fork();

	if(status == 0) {
		close(1);
		dup(pfds[1]);
		close(pfds[0]);

		execvp(file, args);
	} else {
		if(!buf) return; /* don't read anything */
		int readin = read(pfds[0], buf, length - 1);
		buf[readin] = '\0';
	}
}

void imagemagick(char *filename, char *buffer, int size) {
	char *execargs[] = {
		"convert",
		filename,
		"-resize",
		"25%",
		"-colors",
		"16",
		"-unique-colors",
		"-quiet",
		"txt:-",
		NULL
	};
	char *name = "convert";

	exec_with_stdout(name, execargs, buffer, size);
}

struct color *get_raw_colors(char *image) {
	char buf[2048];

	imagemagick(image, (char *)&buf, 2048);
	int hcount = 0;
	char cbuf[3][3];
	static struct color colors[16];

	for(int i = 0; (unsigned int)i < sizeof buf; i++) {
		if(buf[i] == '#') {
			hcount++; /* we have to ignore a comment, that's why there's a special case */
			if(hcount >= 2 && hcount - 2 < 16 && (unsigned int)(i + 6) < sizeof buf) {
				memcpy((char *)&cbuf[0], buf + i + 1, 2);
				memcpy((char *)&cbuf[1], buf + i + 3, 2);
				memcpy((char *)&cbuf[2], buf + i + 5, 2);
				cbuf[0][2] = '\0';
				cbuf[1][2] = '\0';
				cbuf[2][2] = '\0';
				colors[hcount - 2].r = (int)strtol((char *)&cbuf[0], NULL, 16);
				colors[hcount - 2].g = (int)strtol((char *)&cbuf[1], NULL, 16);
				colors[hcount - 2].b = (int)strtol((char *)&cbuf[2], NULL, 16);
			}
		}
	}

	return (struct color *)&colors;
}

void blend_color(struct color *a, struct color *b, struct color *c) {
	c->r = (int)(0.5 * a->r + 0.5 * b->r);
	c->g = (int)(0.5 * a->g + 0.5 * b->g);
	c->b = (int)(0.5 * a->b + 0.5 * b->b);
}

void darken_color(struct color *a, struct color *b, double percentage) {
	b->r = (int)(a->r * (1 - percentage));
	b->g = (int)(a->g * (1 - percentage));
	b->b = (int)(a->b * (1 - percentage));
}

void adjust_colors(struct color *colors) {
	/* #eeeeee */
	struct color e = {238, 238, 238};

	/* if top digit != 0 */
	if(colors[0].r > 15)
		darken_color(&colors[0], &colors[0], 0.40);

	blend_color(&colors[7], &e, &colors[7]);
	darken_color(&colors[7], &colors[8], 0.30);
	blend_color(&colors[15], &e, &colors[15]);
}

int check_colors(struct color *colors) {
	int j = 0;
	for(int i = 0; i < 16; i++) {
		if(colors[i].r + colors[i].g + colors[i].b == 0) j++;
	}
	if(j > 0) return 0;
	return 1;
}

struct color *get_colors(char *filename) {
	/* check for permission */
	if(access(filename, F_OK | R_OK) != 0) {
		errno = ENOENT;
		return NULL;
	}

	struct color *col = get_raw_colors(filename);
	adjust_colors(col);

	return col;
}

/* generalized function ,
 * used by get_conf_file and get_wal_dir */
char *get_file_gen(char *initvar, char *backvar, char *postfix, char *file) {
	static char buffer[256];
	int extension = 0;
	char *path = getenv(initvar);
	if(!path) {
		path = getenv(backvar);
		extension = 1;
	}
	if(!path) {
		fprintf(stderr, "error: both initvar and backvar are undefined.\n");
		exit(1);
	}

	snprintf(buffer, 256, "%s%s/%s", path, extension ? postfix : "", file);
	return buffer;
}

char *get_conf_file(char *file) {
	return get_file_gen("XDG_CONFIG_HOME", "HOME", "/.config/cwal", file);
}

/* pass NULL to get the base dir name, not specific file */
char *get_wal_dir(char *file) {
	if(!file) file = "";

	return get_file_gen("XDG_DATA_HOME", "HOME", "/.local/share/wallpapers", file);
}

char *select_random_rel(void) {
	DIR *dir = opendir(get_wal_dir(NULL));
	struct dirent *file;
	/* probably should move hardcoded constants somewhere that makes sense */
	static char names[50][256];
	int i = 0, random;

	init_random();

	while(file = readdir(dir)) {
		if(i == 50) break;
		if(file->d_type != DT_REG) continue;

		memcpy(&names[i], file->d_name, 256);
		i++;
	}

	random = rand_range(i - 1, 0);

	return names[random];
}

void print_color(struct color *color) {
	printf("#%02x%02x%02x\n", color->r, color->g, color->b);
}

void run_handler(struct color *colors, char *wal) {
	char chars[16][8];
	char *argv[19];

	for(int i = 0; i < 16; i++) {
		snprintf(&chars[i], 8, "#%02x%02x%02x", colors[i].r, colors[i].g, colors[i].b);
	}
	for(int i = 0; i < 16; i++) {
		argv[i + 1] = &chars[i];
	}
	argv[17] = wal;
	argv[18] = NULL;

	char *conf = get_conf_file("handler");
	argv[0] = "handler";

	if(access(conf, F_OK | R_OK | X_OK) != 0) {
		printf("couldn't find %s!\n", conf);
		return;
	}

	exec_with_stdout(conf, argv, NULL, 0);
}

struct settings {
	int h:1; /* running hooks or not */
	int e:1; /* echo colors */
	int c:1; /* enable color check */
	int f:1; /* print filename used */
	char *wal; /* custom file if provided */
} settings = {
	.h = 1,
	.e = 0,
	.c = 0,
	.f = 0,
	.wal = NULL,
};

char *select_random_file(char *file) {
	if(!file) file = select_random_rel();
	static char ret[256];
	file = get_wal_dir(file);
	memcpy(&ret, file, 256);

	return ret;
}

int main(int argc, char **argv) {
	int c;
	while((c = getopt(argc, argv, "hefcw:")) != -1) {
		switch(c) {
			case 'h':
				settings.h = 0;
				break;
			case 'w':
				settings.wal = optarg;
				break;
			case 'e':
				settings.e = 1;
				break;
			case 'c':
				settings.c = 1;
				break;
			case 'f':
				settings.f = 1;
				break;
		}
	}

	if(settings.h == 0) settings.e = 1;

	char *file = select_random_file(settings.wal);
	struct color *colors = get_colors(file);

	if(settings.f) printf("%s\n", file);

	if(settings.e) {
		for(int i = 0; i < 16; i++) {
			print_color(&colors[i]);
		}
	}

	if(settings.c) {
		c = check_colors(colors);
		if(c == 0) {
			return 1;
		}
	}

	if(settings.h) run_handler(colors, file);

	return 0;
}