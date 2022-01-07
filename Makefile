all: mkc
install: man sh mkc c
.PHONY: man sh mkc c

man:
	# this used to be {command} $(DESTDIR)$(PREFIX)/man/man1
	# this did not work on my computer, but might be needed in other computers
	mkdir -p /usr/local/man/man1
	cp -f man/* /usr/local/man/man1
sh:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f sh/paste $(DESTDIR)$(PREFIX)/bin
	cp -f sh/bat $(DESTDIR)$(PREFIX)/bin
	cp -f sh/disp $(DESTDIR)$(PREFIX)/bin
	cp -f sh/wal $(DESTDIR)$(PREFIX)/bin
	cp -f sh/yt $(DESTDIR)$(PREFIX)/bin
	cp -f sh/connect $(DESTDIR)$(PREFIX)/bin
	cp -f sh/nws $(DESTDIR)$(PREFIX)/bin
	cp -f sh/pashmenu $(DESTDIR)$(PREFIX)/bin
	cp -f sh/urlhandle $(DESTDIR)$(PREFIX)/bin
	cp -f sh/ftphandle $(DESTDIR)$(PREFIX)/bin
	cp -f sh/indicate $(DESTDIR)$(PREFIX)/bin
	cp -f sh/vol $(DESTDIR)$(PREFIX)/bin
	cp -f sh/josm_launch $(DESTDIR)$(PREFIX)/bin
	cp -f sh/start $(DESTDIR)$(PREFIX)/bin

mkc:
	cc c/scream.c -o c/scream
	cc c/timer.c -o c/timer
	cc c/boid.c -o c/boid -lm -lX11
	cc c/anaconda.c -o c/anaconda -lm -lX11
	cc c/simplestatus.c -o c/simplestatus
c:
	cp -f c/scream $(DESTDIR)$(PREFIX)/bin
	cp -f c/timer $(DESTDIR)$(PREFIX)/bin
	cp -f c/boid $(DESTDIR)$(PREFIX)/bin
	cp -f c/anaconda $(DESTDIR)$(PREFIX)/bin
	cp -f c/simplestatus $(DESTDIR)$(PREFIX)/bin
clean:
	rm c/scream
