#include <stdio.h>
#include <ctype.h>

/* written on new year's eve 2020
 * good night and good riddance */

char newchar(char c, int i) {
	switch(i) {
		case 0:
			if(isupper(c)) return c + 32;
			if(c == 33) return -2;
			else return c;
		case 1:
			if(islower(c)) return c - 32;
			if(c == 33) return -2;
			else return c;
		default: return -1;
	}
}
int advi(int i) {
	switch(i) {
		case 0: return 1;
		case 1: return 0;
		default: return -1;
	}
}
int main(void) {
	char c;
	int i = 0;
	while((c = getchar()) != EOF) {
		putchar(newchar(c, i));
		i = advi(i);
	}
}
