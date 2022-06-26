all: mkc
install: man sh c all
.PHONY: man sh mkc c

man:
	# this used to be {command} $(DESTDIR)$(PREFIX)/man/man1
	# this did not work on my computer, but might be needed on other installations
	mkdir -p /usr/local/man/man1
	cp -f man/* /usr/local/man/man1

sh:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f sh/paste $(DESTDIR)$(PREFIX)/bin
	cp -f sh/disp $(DESTDIR)$(PREFIX)/bin
	cp -f sh/wallpaper $(DESTDIR)$(PREFIX)/bin
	cp -f sh/yt $(DESTDIR)$(PREFIX)/bin
	cp -f sh/connect $(DESTDIR)$(PREFIX)/bin
	cp -f sh/nws $(DESTDIR)$(PREFIX)/bin
	cp -f sh/vol $(DESTDIR)$(PREFIX)/bin
	cp -f sh/proxtest $(DESTDIR)$(PREFIX)/bin
	cp -f sh/pco $(DESTDIR)$(PREFIX)/bin
	cp -f sh/git-survey $(DESTDIR)$(PREFIX)/bin
	cp -f sh/vim-swap-handler $(DESTDIR)$(PREFIX)/bin
	cp -f sh/snownews-url-handler $(DESTDIR)$(PREFIX)/bin
	cp -f sh/status $(DESTDIR)$(PREFIX)/bin
	cp -f sh/cfg $(DESTDIR)$(PREFIX)/bin
	cp -f sh/repos $(DESTDIR)$(PREFIX)/bin
	cp -f sh/fire $(DESTDIR)$(PREFIX)/bin

mkc: c/scream c/timer c/boid c/anaconda c/simplestatus c/colors

c/boid:
	cc c/boid.c -o c/boid -lm -lX11

c/anaconda:
	cc c/anaconda.c -o c/anaconda -lm -lX11

c:
	cp -f c/scream $(DESTDIR)$(PREFIX)/bin
	cp -f c/timer $(DESTDIR)$(PREFIX)/bin
	cp -f c/boid $(DESTDIR)$(PREFIX)/bin
	cp -f c/anaconda $(DESTDIR)$(PREFIX)/bin
	cp -f c/simplestatus $(DESTDIR)$(PREFIX)/bin
	cp -f c/colors $(DESTDIR)$(PREFIX)/bin

clean:
	rm c/scream
	rm c/timer
	rm c/boid
	rm c/anaconda
	rm c/simplestatus
