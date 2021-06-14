#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>
#include <string.h>

#include "timerlib.c"

struct settings {
  int e:1; /* use escape (v assumed) */
  int v:1; /* verbose */
  int d:1; /* count down/up (1/0) */
  int b:1; /* ascii bel when done */
  int f:1; /* display hours */
  int s; /* seconds */
} s = {
  .e = 0,
  .v = 0,
  .d = 0,
  .b = 0,
  .f = 0,
  .s = 0
};

int timerissettings(struct timer *t) {
  if(t->s == 0) return 0;
  if(s.s == t->s) return 1;
  return 0;
}

char *timerdisp(struct timer *t) {
  char *str = malloc(20);
  if(s.f) snprintf(str, 20, "%02i:%02i:%02i",
    hours(t->s), minutes(t->s), seconds(t->s));
  /* TODO: give minute(...) and minutes(...) better names */
  else snprintf(str, 20, "%02i:%02i", minute(t->s), seconds(t->s));
  return str;
}

void timerloop() {
  struct timer *t = timerinit();
  if(s.d) {
    t->u = timerdec;
    t->s = s.s;
    t->c = timerzero;
  } else {
    t->u = timerinc;
    t->c = timerissettings;
  }
  char *c;
  struct pollfd p = { .fd = STDIN_FILENO, .events = POLLIN };
  for(;;) {
    poll(&p, 1, 60);
    if(p.revents == POLLIN) {
      /* TODO: make this nicer */
      getchar();
      if(s.e) {
        c = timerdisp(t);
        printf("\r\e[1A* %s", c);
      }
      getchar();
      /* TODO: stop relying on hard assumptions */
      if(s.e) printf("\r\e[1A           \r");
    }
    c = timerdisp(t);
    if(s.e) {
      printf("%s\r", c);
      fflush(stdout);
    }
    else if(s.v) printf("%s\n", c);
    if(timerstop(t)) break;
    free(c);
    timerupdate(t);
    sleep(1);
  }
  if(s.b) putchar('\a');
  free(t);
  free(c);
}

int main(int argc, char **argv) {
  char c;
  while((c = getopt(argc, argv, "evdbfh:m:s:")) != -1) {
    switch(c) {
      break; case 'e': s.e = 1;
      break; case 'v': s.v = 1;
      break; case 'd': s.d = 1;
      break; case 'b': s.b = 1;
      break; case 'f': s.f = 1;
      break; case 'h': s.s = s.s + (atoi(optarg) * 3600);
      break; case 'm': s.s = s.s + (atoi(optarg) * 60);
      break; case 's': s.s = s.s + atoi(optarg);
      break; case '?': return 1;
      break; default: abort();
    }
  }
  timerloop();
  return 0;
}
