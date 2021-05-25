LOCATION="$(HOME)/.config"
install: install_bspwm install_nvim install_sx install_sxhkd install_vimb install_zathura install_wyebadblock
install_bspwm:
	cp -r bspwm $(LOCATION)
install_nvim:
	cp -r nvim $(LOCATION)
install_sx:
	cp -r sx $(LOCATION)
install_sxhkd:
	cp -r sxhkd $(LOCATION)
install_vimb:
	cp -r vimb $(LOCATION)
install_zathura:
	cp -r zathura $(LOCATION)
install_wyebadblock:
	cp -r wyebadblock $(LOCATION)
