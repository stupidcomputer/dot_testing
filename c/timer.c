#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <poll.h>
#include <string.h>

struct timer {
  int s; /* seconds */
  int d; /* data storage */
  void (*u)(struct timer *t); /* update function */
  int (*c)(struct timer *t); /* stop check function */
  int (*p)(struct timer *t); /* pause check function */
};

struct settings {
  unsigned int e:1; /* use escape (v assumed) */
  unsigned int v:1; /* verbose */
  unsigned int d:1; /* count down/up (1/0) */
  unsigned int b:1; /* ascii bel when done */
  unsigned int f:1; /* display hours */
  unsigned int t:1; /* tomato timer */
  unsigned int p:1; /* stop after tomato timer cycle finished */
  int s; /* seconds */
} s = {
  .e = 0,
  .v = 0,
  .d = 0,
  .b = 0,
  .f = 0,
  .t = 0,
  .p = 0,
  .s = 0
};

void timerdec(struct timer *t) { if (t->s != 0) t->s--; }
void timerinc(struct timer *t) { t->s++; }
void timerupdate(struct timer *t) { if(t->u != NULL) t->u(t); }

int timerstate(int (*f)(struct timer *t), struct timer *t) {
  if(f != NULL) {
    if(f(t)) return 1;
    else return 0;
  }
  return 0;
}

int timerstop(struct timer *t) { return timerstate(t->c, t); }
int timerpause(struct timer *t) { return timerstate(t->p, t); }

int timerzero(struct timer *t) {
  if(t->s == 0) return 1;
  return 0;
}

int seconds(int t) { return t % 60; }
int minutes(int t) { return (t / 60) % 60; }
int minute(int t) { return t / 60; }
int hours(int t) { return (t / 60) / 60; }

struct timer *timerinit(void) {
  struct timer *t = malloc(sizeof *t);
  t->s = 0;
  t->d = 0;
  t->u = NULL;
  t->c = NULL;
  t->p = NULL;
  return t;
}

int timerissettings(struct timer *t) {
  if(t->s == 0) return 0;
  if(s.s == t->s) return 1;
  return 0;
}

int tomatotimer(struct timer *t) {
  if(t->s != 0) return 0;
  if(t->d % 2) t->s = s.s / 2;
  else t->s = s.s;
  t->d++;
  if(s.b) putchar('\a');
  if(s.p) return 0;
  return 1;
}

char *timerdisp(struct timer *t) {
  char *str = malloc(20);
  if(s.f) snprintf(str, 20, "%02i:%02i:%02i",
    hours(t->s), minutes(t->s), seconds(t->s));
  /* TODO: give minute(...) and minutes(...) better names */
  else snprintf(str, 20, "%02i:%02i", minute(t->s), seconds(t->s));
  return str;
}

void defaultSettings(struct settings s) {
  s.e = 1;
  s.b = 1;
  s.f = 1;
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
  if(s.t) {
    t->u = timerdec;
    if(s.s == 0) s.s = 20 * 60;
    t->s = s.s;
    t->d = 1;
    t->p = tomatotimer;
    t->c = NULL;
  }

  char *c;
  int e;
  struct pollfd p = { .fd = STDIN_FILENO, .events = POLLIN };
  for(;;) {
    poll(&p, 1, 60);
    if((e = (p.revents == POLLIN)) || timerpause(t)) {
      /* TODO: make this nicer */
      if(e) getchar();
      if(s.e) {
        c = timerdisp(t);
        if(e) printf("\r\e[1A* %s", c);
        else printf("\r* %s", c);
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
  while((c = getopt(argc, argv, "evdbftpzh:m:s:")) != -1) {
    switch(c) {
      break; case 'e': s.e = 1;
      break; case 'v': s.v = 1;
      break; case 'd': s.d = 1;
      break; case 'b': s.b = 1;
      break; case 'f': s.f = 1;
      break; case 't': s.t = 1;
      break; case 'p': s.p = 1;
      break; case 'z': s.e = 1; s.b = 1; s.f = 1;
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
