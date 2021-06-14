all: mkc
install: man sh mkc c
.PHONY: man sh mkc c

man:
	mkdir -p $(DESTDIR)$(PREFIX)/man1
	cp -f man/* $(DESTDIR)$(PREFIX)/man1
sh:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f sh/paste $(DESTDIR)$(PREFIX)/bin
	cp -f sh/bat $(DESTDIR)$(PREFIX)/bin
	cp -f sh/disp $(DESTDIR)$(PREFIX)/bin
	cp -f sh/wal $(DESTDIR)$(PREFIX)/bin
	cp -f sh/yt $(DESTDIR)$(PREFIX)/bin
	cp -f sh/connect $(DESTDIR)$(PREFIX)/bin
	cp -f sh/nws $(DESTDIR)$(PREFIX)/bin
	cp -f sh/urlhandle $(DESTDIR)$(PREFIX)/bin
	cp -f sh/indicate $(DESTDIR)$(PREFIX)/bin
	cp -f sh/vol $(DESTDIR)$(PREFIX)/bin
	cp -f sh/josm_launch $(DESTDIR)$(PREFIX)/bin

mkc:
	cc c/scream.c -o progs/scream
	cc c/timer.c -o progs/timer
c:
	cp -f c/scream $(DESTDIR)$(PREFIX)/bin
	cp -f c/timer $(DESTDIR)$(PREFIX)/bin
clean:
	rm c/scream
