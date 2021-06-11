struct timer {
  int s; /* seconds */
  int d; /* data storage */
  void (*u)(struct timer *t); /* update function */
  int (*c)(struct timer *t); /* stop check function */
  int (*p)(struct timer *t); /* pause check function */
};

void timerdec(struct timer *t) {
  if (t->s != 0) t->s--;
}

void timerinc(struct timer *t) {
  t->s++;
}

void timerupdate(struct timer *t) {
  if(t->u != NULL) t->u(t);
}

int timerstate(int (*f)(struct timer *t), struct timer *t) {
  if(f != NULL) {
    if(f(t)) return 1;
    else return 0;
  }
  return 0;
}

int timerstop(struct timer *t) {
  return timerstate(t->c, t);
}

int timerpause(struct timer *t) {
  return timerstate(t->p, t);
}

int timerzero(struct timer *t) {
  if(t->s == 0) return 1;
  return 0;
}

struct timer *timerinit(void) {
  struct timer *t = malloc(sizeof *t);
  t->s = 0;
  t->d = 0;
  t->u = NULL;
  t->c = NULL;
  t->p = NULL;
  return t;
}
