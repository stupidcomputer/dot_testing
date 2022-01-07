#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#define NAME "simplestatus"

typedef struct module {
  char *mod_name;
  int refresh;
  int signal;
  struct module *next;
} module;

typedef struct cache {
  char *mod_name;
  char *data;
  struct cache *next;
} cache;

const int alloc_inc = 30;
const char module_text[] = "module";
const char order_text[] = "order";
const char format_text[] = "format";
char *format_string = NULL;
module *table = NULL;
cache *mcache = NULL;

void llprintf(char *fmt) {
  int length = strlen(fmt);
  cache *ptr = mcache;

  ptr = mcache;

  for(int i = 0; i < length; i++) {
    if(fmt[i] == '&') {
      fprintf(stdout, "%s", ptr->data);
      ptr = ptr->next;
    } else {
      fprintf(stdout, "%c", fmt[i]);
    }
  }

  fprintf(stdout, "\n");

  fflush(stdout);
}

char *get_conf_dir(void) {
  /* check if $XDG_CONFIG_DIR is set */
  char *rootdir, *append;
  if((rootdir = getenv("XDG_CONFIG_DIR"))) {
    append = "/"NAME"/";
  } else if((rootdir = getenv("HOME"))) {
    append = "/.config/"NAME"/";
  } else {
    return NULL;
  }

  char *buffer = malloc(strlen(rootdir) + strlen(append) + 1);
  strcpy(buffer, rootdir);
  strcat(buffer, append);

  return buffer;
}

char *execstdout(char *file, char *arg[], char *env[]) {
  int pfds[2];

  if(pipe(pfds) == -1) {
    perror("PIPE");
    fprintf(stderr, "pipe failed! aborting.\n");
    abort();
  }

  int pid = fork();

  if(pid == -1) {
    fprintf(stderr, "fork failed! aborting.\n");
    abort();
  } else if(pid == 0) {
    if(close(1) == -1) exit(0);
    if(dup(pfds[1]) == -1) exit(0);
    if(close(pfds[0])) exit(0);
    execlp(file, file, NULL);
  } else {
    wait(NULL);

    int bufsize = alloc_inc, total = 0;
    char *buf = malloc(bufsize);

    if(!buf) {
      fprintf(stderr, "malloc failed! aborting.\n");
      abort();
    }

    for(;;) {
      int size = read(pfds[0], buf + total, alloc_inc);

      if(size == -1) {
        if(errno == EINTR) {
          continue;
        } else {
          free(buf);
          close(pfds[0]);
          close(pfds[1]);
          return NULL;
        }
      }

      total += size;

      if(size == alloc_inc) { /* we need to reallocate */
        buf = realloc(buf, (bufsize *= 2));
        if(!buf) {
          fprintf(stderr, "realloc failed! aborting.\n");
          abort();
        }
        continue;
      }

      buf[total] = '\0';
      buf = realloc(buf, strlen(buf));

      close(pfds[0]);
      close(pfds[1]);
      return buf;
    }
  }
}

char *read_line(FILE *fp) {
  int size = 30;
  int filled = 0;
  int c;
  char *buf = malloc(size);

  while(c = fgetc(fp)) {
    if(c == EOF) {
      if(filled == 0) {
        free(buf);
        return NULL;
      } else {
        break;
      }
    }
    if(c == '\n') break;
    if(size == filled) {
      buf = realloc(buf, (size *= 2));
    }
    buf[filled] = c;
    filled++;
  }
  buf[filled] = '\0';

  return buf;
}

module *parse_file(char *file) {
  FILE *fp = fopen(file, "r");
  char *cline;
  module *current = NULL, *head = NULL;
  int linenumber = 0;
  while((cline = read_line(fp)) != NULL) {
    linenumber++;
    /* free the string up here */
    if(strlen(cline) == 0) {
      free(cline);
      continue;
    }
    if(cline[0] == '#') {
      free(cline);
      continue;
    }

    char *command = strdup(strtok(cline, " "));
    if(!memcmp(command, module_text, sizeof module_text)) {
      if(current == NULL) {
        current = malloc(sizeof *current);
        head = current;
        current->next = NULL;
      } else {
        current->next = malloc(sizeof *current);
        current = current->next;
        current->next = NULL;
      }

      /* get the module name */
      char *token = strtok(NULL, " ");
      if(!token) {
        fprintf(stderr, "syntax error at line %i: specify a module name!\n", linenumber);
        return NULL;
      }
      current->mod_name = strdup(token);

      /* get the signal number */
      token = strtok(NULL, " ");
      if(!token) {
        fprintf(stderr, "syntax error at line %i: specify the signal number!\n", linenumber);
        return NULL;
      }
      current->signal = atoi(token);

      /* get the refresh duration */
      token = strtok(NULL, " ");
      if(!token) {
        fprintf(stderr, "syntax error at line %i: specify the refresh duration!\n", linenumber);
        return NULL;
      }
      current->refresh = atoi(token);

      free(cline);
      continue;
    } else if(!memcmp(command, order_text, sizeof order_text)) {
      if(mcache) {
        fprintf(stderr, "syntax error at line %i: you can't issue the order command twice\n", linenumber);
        return NULL;
      }

      char *token;
      cache *ptr = mcache;
      while(token = strtok(NULL, " ")) {
        if(mcache) {
          ptr->next = malloc(sizeof *mcache);
          ptr = ptr->next;
        } else {
          mcache = malloc(sizeof mcache);
          ptr = mcache;
        }
        ptr->mod_name = token;
        ptr->data = NULL;
        ptr->next = NULL;
      }
    } else if(!memcmp(command, format_text, sizeof format_text)) {
      char *pattern = cline + sizeof format_text;
      format_string = strdup(pattern);
    }
  }

  fclose(fp);

  return head;
}

int is_dir(char *dir) {
  struct stat sb;

  if(stat(dir, &sb) == 0 && S_ISDIR(sb.st_mode)) {
    return 1;
  } else {
    return 0;
  }
}

void sighandler(int sig) {
  module *ptr = table;
  char *mod = NULL;
  while(ptr) {
    if(ptr->signal == sig) {
      mod = ptr->mod_name;

      char *path = malloc(strlen(mod) + 3);
      strcpy(path, "./");
      strcat(path, mod);

      char *output = execstdout(path, NULL, NULL);
      free(path);

      cache *ptr2 = mcache;
      while(ptr2) {
        if(!memcmp(mod, ptr2->mod_name, strlen(mod))) {
          ptr2->data = output;
          break;
        }
        ptr2 = ptr2->next;
      }
    }
    ptr = ptr->next;
  }
}

void sighandler_w(int sig) {
  sighandler(sig);
  llprintf(format_string);
}

void create_sighandle_from_table(void) {
  module *ptr = table;
  struct sigaction *action = malloc(sizeof *action);
  action->sa_handler = sighandler_w;
  sigemptyset(&(action->sa_mask));
  action->sa_flags = 0;
  while(ptr) {
    sigaction(ptr->signal, action, NULL);
    sighandler(ptr->signal); /* force an update */
    ptr = ptr->next;
  }
}

int main(void) {
  char *conf_dir = get_conf_dir();
  if(!is_dir(conf_dir)) {
    fprintf(stderr, "create configuration at %s and try again\n", conf_dir);
    exit(1);
  }
  chdir(conf_dir);
  table = parse_file("config");
  create_sighandle_from_table();
  llprintf(format_string);

  int counter = 0;

  for(;;) {
    module *ptr = table;

    counter++;
    sleep(1);

    while(ptr) {
      if(counter % ptr->refresh == 0) {
        sighandler_w(ptr->signal);
      }
      ptr = ptr->next;
    }
  }

  return 0;
}
