#include <X11/Xlib.h>
#include <stdio.h>

int main(void) {
	Display* display = XOpenDisplay(NULL);
	if(!display) {
		printf("Error: Unable to open display.\n");
		return 1;
	}

	int screen = DefaultScreen(display);
	Window root = RootWindow(display, screen);

	/* SubstructureNotifyMask allows us to be notified of CreateNotify events */
	XSelectInput(display, root, SubstructureNotifyMask);

	XEvent event;
	for(;;) {
		XNextEvent(display, &event);
		if(event.type == CreateNotify) {
			/* print window id */
			printf("0x%x\n", event.xcreatewindow.window);
			break;
		}
	}

	XCloseDisplay(display);
	return 0;
}
