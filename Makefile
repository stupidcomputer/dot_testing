LOCATION="$(HOME)/.config"
install:
	mkdir -p $(LOCATION)
	cp -r bspwm $(LOCATION)
	cp -r nvim $(LOCATION)
	cp -r sx $(LOCATION)
	cp -r sxhkd $(LOCATION)
	cp -r vimb $(LOCATION)
	cp -r zathura $(LOCATION)
	cp -r wyebadblock $(LOCATION)
