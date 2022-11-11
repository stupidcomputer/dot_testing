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
	cp -f sh/trss-yt-id $(DESTDIR)$(PREFIX)/bin
	cp -f sh/disp $(DESTDIR)$(PREFIX)/bin
	cp -f sh/wallpaper $(DESTDIR)$(PREFIX)/bin
	cp -f sh/connect $(DESTDIR)$(PREFIX)/bin
	cp -f sh/nws $(DESTDIR)$(PREFIX)/bin
	cp -f sh/vol $(DESTDIR)$(PREFIX)/bin
	cp -f sh/proxtest $(DESTDIR)$(PREFIX)/bin
	cp -f sh/pco $(DESTDIR)$(PREFIX)/bin
	cp -f sh/git-survey $(DESTDIR)$(PREFIX)/bin
	cp -f sh/vim-swap-handler $(DESTDIR)$(PREFIX)/bin
	cp -f sh/status $(DESTDIR)$(PREFIX)/bin
	cp -f sh/statusbar $(DESTDIR)$(PREFIX)/bin
	cp -f sh/cfg $(DESTDIR)$(PREFIX)/bin
	cp -f sh/fire $(DESTDIR)$(PREFIX)/bin
	cp -f sh/pash-dmenu $(DESTDIR)$(PREFIX)/bin
	cp -f sh/pash-dmenu-backend $(DESTDIR)$(PREFIX)/bin
	cp -f sh/tmenu $(DESTDIR)$(PREFIX)/bin
	cp -f sh/tmenu-backend $(DESTDIR)$(PREFIX)/bin
	cp -f sh/tmenu_run $(DESTDIR)$(PREFIX)/bin
	cp -f sh/ss $(DESTDIR)$(PREFIX)/bin
	cp -f sh/net $(DESTDIR)$(PREFIX)/bin
	cp -f sh/bspwm-toggle-gaps $(DESTDIR)$(PREFIX)/bin
	cp -f sh/machine $(DESTDIR)$(PREFIX)/bin
	cp -f sh/brightness $(DESTDIR)$(PREFIX)/bin
	cp -f sh/git-credential-gitpass $(DESTDIR)$(PREFIX)/bin

check:
	shellcheck sh/*

mkc: c/scream c/timer c/boid c/anaconda c/colors

c/boid:
	cc c/boid.c -o c/boid -lm -lX11

c/anaconda:
	cc c/anaconda.c -o c/anaconda -lm -lX11

c:
	cp -f c/scream $(DESTDIR)$(PREFIX)/bin
	cp -f c/timer $(DESTDIR)$(PREFIX)/bin
	cp -f c/boid $(DESTDIR)$(PREFIX)/bin
	cp -f c/anaconda $(DESTDIR)$(PREFIX)/bin
	cp -f c/colors $(DESTDIR)$(PREFIX)/bin

clean:
	rm c/scream
	rm c/timer
	rm c/boid
	rm c/anaconda
	rm c/simplestatus
