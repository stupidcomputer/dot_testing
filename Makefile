LOCATION="$(HOME)/.config"
DATA="$(HOME)/.local/share"
install_local: install_bspwm install_nvim install_sx install_sxhkd install_zathura install_simplestatus install_bash install_ssh install_git
install: .environment
install_bspwm:
	ln -sf $(CURDIR)/bspwm $(LOCATION)/bspwm
install_nvim:
	ln -sf $(CURDIR)/nvim $(LOCATION)/nvim
install_sx:
	ln -sf $(CURDIR)/sx $(LOCATION)/sx
install_sxhkd:
	ln -sf $(CURDIR)/sxhkd $(LOCATION)/sxhkd
install_zathura:
	ln -sf $(CURDIR)/zathura $(LOCATION)/zathura
install_simplestatus:
	ln -sf $(CURDIR)/simplestatus $(LOCATION)/simplestatus
install_bash:
	ln -sf $(CURDIR)/bash $(LOCATION)/bash
install_ssh:
	ln -sf $(CURDIR)/ssh $(LOCATION)/ssh
install_git:
	ln -sf $(CURDIR)/git $(LOCATION)/git
.environment:
	sh environ
