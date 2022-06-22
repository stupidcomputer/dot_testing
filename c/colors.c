#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
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

char *get_conf_file(char *file) {
	static char buffer[128];
	int extension = 0;
	char *path = getenv("XDG_CONFIG_HOME");
	if(!path) {
		path = getenv("HOME");
		extension = 1;
	}
	if(!path) {
		printf("do you have a $HOME?\n");
		exit(1);
	}

	snprintf(buffer, 128, "%s%s/%s", path, extension ? "/.config/cwal" : "", file);
	return buffer;
}

void print_color(struct color *color) {
	printf("#%x%x%x\n", color->r, color->g, color->b);
}

void run_handler(struct color *colors) {
	char chars[16][8];
	char *argv[18];

	for(int i = 0; i < 16; i++) {
		snprintf(&chars[i], 8, "#%x%x%x", colors[i].r, colors[i].g, colors[i].b);
	}
	for(int i = 0; i < 16; i++) {
		argv[i + 1] = &chars[i];
	}
	argv[17] = NULL;

	printf("envp[0] = %s\n", argv[1]);
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
	int r:1; /* pick a random wallpaper */
} settings = {
	.h = 1,
	.r = 1,
};

int main(void) {
	struct color *colors = get_colors("/home/usr/.local/share/wallpapers/forest-steps.jpg");

	for(int i = 0; i < 16; i++) {
		print_color(&colors[i]);
	}

	run_handler(colors);

	get_conf_file("hello");

	return 0;
}
