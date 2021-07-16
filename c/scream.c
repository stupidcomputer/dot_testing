#include <stdio.h>
#include <ctype.h>

/* written on new year's eve 2020
 * good night and good riddance */

char newchar(char c, int i) {
  if(i % 2) {
    if(islower(c)) return c - 32;
  } else if(isupper(c)) return c + 32;
  if(c == 33) return -2;
  return c;
}
int main(void) {
  char c;
  int i;
  i = 0;
  while((c = getchar()) != EOF) {
    putchar(newchar(c, i));
    i++;
  }
}
