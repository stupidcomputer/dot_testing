#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>
#include <string.h>

#include "timerlib.h"

struct settings {
  int e:1; /* use escape (v assumed) */
  int v:1; /* verbose */
  int d:1; /* count down/up (1/0) */
  int b:1; /* ascii bel when done */
  int f:1; /* display hours */
  int m; /* minutes */
  int s; /* seconds */
} settings = {
  .e = 0,
  .v = 0,
  .d = 0,
  .b = 0,
  .f = 0,
  .m = 0,
  .s = 0
};

int timerissettings(struct timer *t) {
  if(t->m == 0 && t->s == 0) return 0;
  if(t->m == settings.m &&
    t->s == settings.s) return 1;
  return 0;
}

char *timerdisp(struct timer *t) {
  char *str = malloc(20);
  if(settings.f) snprintf(str, 20, "%02i:%02i:%02i",
    (t->m / 60), (t->m % 60), t->s);
  else snprintf(str, 20, "%02i:%02i", t->m, t->s);
  return str;
}

void timerloop() {
  struct timer *t = timerinit();
  if(settings.d) {
    t->u = timerdec;
    t->m = settings.m;
    t->s = settings.s;
    t->c = timerzero;
  } else {
    t->u = timerinc;
    t->c = timerissettings;
  }
  char *c;
  struct pollfd *p = malloc(sizeof p);
  p->fd = STDIN_FILENO;
  p->events = POLLIN;
  for(;;) {
    poll(p, 1, 60);
    if(p->revents == POLLIN) {
      /* TODO: make this nicer */
      getchar();
      if(settings.e) {
        c = timerdisp(t);
        printf("\r\e[1A* %s", c);
      }
      getchar();
      /* TODO: stop relying on hard assumptions */
      if(settings.e) printf("\r\e[1A           \r", c);
    }
    c = timerdisp(t);
    if(settings.e) {
      printf("%s\r", c);
      fflush(stdout);
    }
    else if(settings.v) printf("%s\n", c);
    if(timerstate(t)) break;
    timerupdate(t);
    sleep(1);
  }
  if(settings.b) putchar('\a');
}

int main(int argc, char **argv) {
  char c;
  while((c = getopt (argc, argv, "evdbfm:s:")) != -1) {
    switch(c) {
      break; case 'e': settings.e = 1;
      break; case 'v': settings.v = 1;
      break; case 'd': settings.d = 1;
      break; case 'b': settings.b = 1;
      break; case 'f': settings.f = 1;
      break; case 'm': settings.m = atoi(optarg);
      break; case 's': settings.s = atoi(optarg);
      break; case '?': return 1;
      break; default: abort();
    }
  }
  timerloop();
  return 0;
}
