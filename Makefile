all: mkc
install: man sh mkc c
.PHONY: man sh mkc c

man:
	mkdir -p $(DESTDIR)$(PREFIX)/man1
	cp -f *.1 $(DESTDIR)$(PREFIX)/man1
sh:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/paste $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/bat $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/disp $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/shime $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/wal $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/yt $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/connect $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/nws $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/urlhandle $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/indicate $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/vol $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/timer $(DESTDIR)$(PREFIX)/bin
	ln -sf $(DESTDIR)$(PREFIX)/bin/timer $(DESTDIR)$(PREFIX)/bin/alarm
	ln -sf $(DESTDIR)$(PREFIX)/bin/timer $(DESTDIR)$(PREFIX)/bin/tomato
	ln -sf $(DESTDIR)$(PREFIX)/bin/timer $(DESTDIR)$(PREFIX)/bin/stopwatch
	ln -sf $(DESTDIR)$(PREFIX)/bin/timer $(DESTDIR)$(PREFIX)/bin/verbosewatch

mkc:
	cc progs/scream.c -o progs/scream
c:
	cp -f progs/scream $(DESTDIR)$(PREFIX)/bin
clean:
	rm progs/scream
