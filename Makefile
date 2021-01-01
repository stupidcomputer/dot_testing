install: man sh c
man:
	mkdir -p $(DESTDIR)$(PREFIX)/man1
	cp -f *.1 $(DESTDIR)$(PREFIX)/man1
sh:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/paste $(DESTDIR)$(PREFIX)/bin
	cp -f scripts/bat $(DESTDIR)$(PREFIX)/bin
c:
	cc progs/scream.c -o progs/scream
	cp -f progs/scream $(DESTDIR)$(PREFIX)/bin
