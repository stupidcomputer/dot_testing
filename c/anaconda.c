#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <time.h>

#include <X11/Xlib.h>

typedef struct point {
  double x;
  double y;
  struct point *next;
} point;

typedef struct anaconda {
  int score;
  double rot;
  struct point *chain;
} anaconda;

Display *d;
Window w;
XEvent e;
int s;
GC gc;

void xinit(void) {
  d = XOpenDisplay(NULL);
  s = DefaultScreen(d);
  w = XCreateSimpleWindow(d, RootWindow(d, s), 10, 10, 100, 100, 1,
      BlackPixel(d, s), WhitePixel(d, s));
  XSelectInput(d, w, ExposureMask | KeyPressMask | PointerMotionMask);
  XMapWindow(d, w);
  gc = XCreateGC(d, w, 0, NULL);
}

/* thanks to
 * https://stackoverflow.com/questions/3838329/how-can-i-check-if-two-segments-intersect/9997374#9997374
 * for functions ccw and intersect
*/

int ccw(point *a, point *b, point *c) {
  return (c->y - a->y) * (b->x - a->x) >
    (b->y - a->y) * (c->x - a->x);
}

int intersect(point *a, point *b, point *c, point *d) {
  return (ccw(a, c, d) != ccw(b, c, d)) && (ccw(a, b, c) != ccw(a, b, d));
}

int randrange(int b, int s) {
  return rand() % (b - s + 1) + s;
}

int eucliddist(point *a, point *b) {
  return sqrt(pow(a->x - b->x, 2) + pow(a->y - b->y, 2));
}

point *mkPoint(double x, double y) {
  point *ret = malloc(sizeof *ret);

  ret->x = x;
  ret->y = y;
  ret->next = NULL;

  return ret;
}

point *rotate(point *p, double rot) {
  double rad = rot * M_PI/180;

  return mkPoint(
    p->x * cos(rad) - p->y * sin(rad),
    p->x * sin(rad) + p->y * cos(rad)
  );
}

void appendPoint(point *dest, point *origin) {
  while(dest->next) dest = dest->next;
  dest->next = origin;
}

int updateAnaconda(anaconda *anaconda, int w, int h, point *apple) {
  point *temp, *new, *ptr;
  new = anaconda->chain;
  temp = rotate(mkPoint(10, 0), anaconda->rot);
  new = mkPoint(
    new->x + temp->x,
    new->y + temp->y
  );
  new->next = anaconda->chain;
  anaconda->chain = new;

  free(temp);

  if(eucliddist(new, apple) <= 30) {
    anaconda->score += 30;
    apple->x = randrange(20, w / 2);
    apple->y = randrange(20, h / 2);
  } else {
    ptr = new;

    while(1) {
      if(ptr->next) {
        if(ptr->next->next) ptr = ptr->next;
        else break;
      } else break;
    }
    free(ptr->next);
    ptr->next = NULL;
  }

  ptr = anaconda->chain;
  for(int i = 0; i < 3; i++) {
    if(ptr->next) ptr = ptr->next;
    else return 1; /* we're fine, the snake is too short to intersect itself */
  }

  while(ptr->next) {
    if(intersect(new, new->next, ptr, ptr->next)) return 0;
    ptr = ptr->next;
  }

  if(
    new->x >= w || new->x <= 0 ||
    new->y >= h || new->y <= 0
  ) return 0;

  if(eucliddist(new, apple) <= 30) {
    anaconda->score += 30;
    apple->x = randrange(20, w / 2);
    apple->y = randrange(20, h / 2);
  }

  return 1;
}

point *generateChain(int length) {
  point *ret = mkPoint(100, 100);
  point *head = ret;

  for(int i = 1; i < length - 1; i++) {
    ret->next = mkPoint(
      10 * i + 100,
      5 * i + 100
    );
    ret = ret->next;
  }

  return head;
}

anaconda *mkAnaconda(point *point, double rot) {
  anaconda *ret = malloc(sizeof *ret);

  ret->chain = point;
  ret->rot = rot;
  ret->score = 0;

  return ret;
}

int main(void) {
  anaconda *anaconda = mkAnaconda(generateChain(30), 0);
  xinit();
  srand(time(0));
  int width = DisplayWidth(d, s);
  int height = DisplayHeight(d, s);
  point *apple = mkPoint(randrange(20, width / 2 - 20), randrange(20, height / 2 - 20));
  while(1) {
    if(!updateAnaconda(anaconda, width, height, apple)) {
      return 0;
    }
    XClearWindow(d, w);
    point *ptr = anaconda->chain;
    while(ptr->next) {
      XDrawLine(d, w, gc, ptr->x, ptr->y, ptr->next->x, ptr->next->y);
      ptr = ptr->next;
    }
    printf("%f %f\n", apple->x, apple->y);
    XDrawArc(d, w, gc, apple->x - (5/2), apple->y - (5/2), 5, 5, 0, 360*64);
    while(XPending(d)) {
      XNextEvent(d, &e);
      switch(e.type) {
        case KeyPress:
          switch(e.xkey.keycode) {
            case 113: /* left arrow key */
              anaconda->rot += 10;
              break;
            case 114: /* right arrow key */
              anaconda->rot -= 10;
              break;
          }
          break;
      }
    }
    usleep(100000);
  }

  return 0;
}
