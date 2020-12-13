install: man sh
man:
	mkdir -p $(DESTDIR)$(PREFIX)/man1
	cp -f *.1 $(DESTDIR)$(PREFIX)/man1
sh:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f paste $(DESTDIR)$(PREFIX)/bin
	cp -f bat $(DESTDIR)$(PREFIX)/bin
