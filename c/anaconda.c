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

point *mkPoint(double x, double y) {
  point *ret = malloc(sizeof ret);

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

void updateAnaconda(anaconda *anaconda) {
  point *prev = anaconda->chain;
  point *temp = rotate(mkPoint(10, 0), anaconda->rot);
  point *new = mkPoint(
    prev->x + temp->x,
    prev->y + temp->y
  );
  new->next = prev;
  anaconda->chain = new;

  free(temp);

  point *traverser = new;

  while(1) {
    if(traverser->next) {
      if(traverser->next->next) {
        traverser = traverser->next;
      } else break;
    } else break;
  }
  free(traverser->next);
  traverser->next = NULL;
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
  anaconda *ret = malloc(sizeof ret);

  ret->chain = point;
  ret->rot = rot;
  ret->score = 0;

  return ret;
}

int main(void) {
  anaconda *anaconda = mkAnaconda(generateChain(10), 0);
  xinit();
  while(1) {
    updateAnaconda(anaconda);
    XClearWindow(d, w);
    point *ptr = anaconda->chain;
    while(ptr->next) {
      XDrawLine(d, w, gc, ptr->x, ptr->y, ptr->next->x, ptr->next->y);
      ptr = ptr->next;
    }
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
