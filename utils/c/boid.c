#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include <X11/Xlib.h>

#define MIN(X, Y) (((X) < (Y)) ? (X) : (Y))

const double sprite[][2] = {
  {0, 1},
  {-0.5, -1},
  {0, -0.5},
  {0.5, -1},
};
#define SIZE sizeof sprite / sizeof sprite[0]

double buffer[SIZE][2];
int boidcounter = 0;

Display *d;
Window w;
XEvent e;
int s;
GC gc;

typedef struct point {
  double x;
  double y;
} point;

typedef struct boid {
  int id;
  point *p;
  double rot;
  struct boid *next;
} boid;

void xinit(void) {
  d = XOpenDisplay(NULL);
  s = DefaultScreen(d);
  w = XCreateSimpleWindow(d, RootWindow(d, s), 10, 10, 100, 100, 1,
      BlackPixel(d, s), WhitePixel(d, s));
  XSelectInput(d, w, ExposureMask | KeyPressMask | PointerMotionMask);
  XMapWindow(d, w);
  gc = XCreateGC(d, w, 0, NULL);
}

int sign(double x) {
  return (x > 0) - (x < 0);
}

point *rotate(double x, double y, double rot) {
  point *ret = malloc(sizeof ret);
  double rad = rot * M_PI/180;

  ret->x = x * cos(rad) - y * sin(rad);
  ret->y = x * sin(rad) + y * cos(rad);

  return ret;
}

double distance(point *a, point *b) {
  return sqrt(pow(a->x - b->x, 2) + pow(a->y - b->y, 2));
}

void calculateRender(
  double x,
  double y,
  double rot,
  int scale
) {
  memcpy(&buffer, &sprite, SIZE);

  for(int i = 0; i < SIZE; i++) {
    point *p = rotate(sprite[i][0], sprite[i][1], rot);

    buffer[i][0] = p->x * scale + x;
    buffer[i][1] = p->y * scale + y;

    free(p);
  }
}

void renderBuffer(void) {
  for(int i = 0; i < SIZE - 1; i++) {
    XDrawLine(d, w, gc,
        buffer[i][0], buffer[i][1],
        buffer[i + 1][0], buffer[i + 1][1]);
  }
  XDrawLine(d, w, gc,
      buffer[0][0], buffer[0][1],
      buffer[SIZE - 1][0], buffer[SIZE - 1][1]);
}

void renderBoid(boid *boid) {
  calculateRender(
    boid->p->x,
    boid->p->y,
    boid->rot,
    5
  );
  renderBuffer();
}

boid *mkBoid(double x, double y, double rot) {
  boid *b = malloc(sizeof b);
  point *p = malloc(sizeof p);
  b->p = p;

  b->p->x = x;
  b->p->y = y;
  b->rot = rot;
  b->next = NULL;
  b->id = boidcounter++;

  return b;
}

void appendBoid(boid *destination, boid *source) {
  destination->next = source;
}

double averageHeading(boid *b) {
  boid *c = b;
  double sum;
  int count;
  while(c) {
    sum += c->rot;
    count++;
    c = c->next;
  }
  return sum / count;
}

void randomBoids(boid *b, int num) {
  srand(time(0));
  boid *ptr = b;
  for(int i = 0; i < num; i++) {
    int w = rand() % DisplayWidth(d, s) + 1;
    int h = rand() % DisplayHeight(d, s) + 1;
    int deg = rand() % 360;
    appendBoid(ptr, mkBoid(w, h, deg));
    ptr = ptr->next;
  }
}

void updateBoid(boid *b, boid *chain, int id, double average) {
  point *p = rotate(5, 0, b->rot + 90);
  b->p->x = b->p->x + p->x;
  b->p->y = b->p->y + p->y;
  double toTurn = 0;

  boid *c = chain;
  while(c) {
    if(c->id != id) {
      int dist = distance(c->p, b->p);
      if(dist < 50) toTurn += dist / 75;
    }
    int w = DisplayWidth(d, s);
    int h = DisplayHeight(d, s);
    int centerw = w / 2 - b->p->x;
    int centerh = h / 2 - b->p->y;
    double deg = atan((double)centerh / (double)centerw) * 180/M_PI;
    toTurn += sign(deg) * 0.5;
    toTurn += (average - c->rot) * 0.4;
    if(b->p->x > w) b->p->x = 0;
    else if(b->p->x < 0) b->p->x = w;
    if(b->p->y > h) b->p->y = 0;
    else if(b->p->y < 0) b->p->y = h;

    toTurn = MIN(toTurn / 4, 30);

    b->rot += toTurn;
    c = c->next;
  }

  free(p);
}

int main() {
  xinit();
  boid *b = mkBoid(100, 100, 0);
  randomBoids(b, 100);
  while(1) {
    XClearWindow(d, w);
    boid *ptr = b;
    while(ptr) {
      updateBoid(ptr, b, ptr->id, averageHeading(b));
      renderBoid(ptr);
      XFlush(d);
      ptr = ptr->next;
    }
    while(XPending(d)) {
      XNextEvent(d, &e);
      switch(e.type) {
        case KeyPress:
          break;
      }
    }
    usleep(50000);
  }
  return 0;
}
