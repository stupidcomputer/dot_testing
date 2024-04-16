LDFLAGS=`pkg-config --cflags --libs xcb`
CFLAGS=-ggdb -fsanitize=address
main: battery.o bspwm.o time.o battstatus.o message.o

clean:
	rm *.o main

run:
	./main
