struct timer {
  int m;
  int s;
  void (*u)(struct timer *t);
  int (*c)(struct timer *t);
};

void timerdec(struct timer *t) {
  if(t->s > 0) t->s--;
  else if(t->s == 0) {
    t->s = 59;
    t->m--;
  }
}

void timerinc(struct timer *t) {
  if(t->s < 59) t->s++;
  else if(t->s == 59) {
    t->s = 0;
    t->m++;
  }
}

void timerupdate(struct timer *t) {
  if(t->u != NULL) t->u(t);
}

int timerstate(struct timer *t) {
  if(t->c != NULL) {
    if(t->c(t)) return 1;
    else return 0;
  }
  return 0;
}

int timerzero(struct timer *t) {
  if(t->m == 0 && t->s == 0) return 1;
  return 0;
}

struct timer *timerinit(void) {
  struct timer *t = malloc(sizeof t);
  t->m = 0;
  t->s = 0;
  t->u = NULL;
  t->c = NULL;
  return t;
}
