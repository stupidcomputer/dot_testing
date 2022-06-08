LOCATION="$(HOME)/.config"
DATA="$(HOME)/.local/share"
install_local: install_bspwm install_nvim install_sx install_sxhkd install_zathura install_simplestatus install_bash install_ssh install_git
install: .environment
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
install_simplestatus:
	cp -r simplestatus $(LOCATION)
install_bash:
	cp -r bash $(LOCATION)
install_ssh:
	cp -r ssh $(LOCATION)
install_git:
	cp -r git $(LOCATION)
.environment:
	sh environ
