LOCATION="$(HOME)/.config"
DATA="$(HOME)/.local/share"
install_local: location_setup install_theme install_bspwm install_nvim install_sx install_sxhkd install_zathura install_bash install_ssh install_git install_tridactyl install_htop install_python
firefox: .firefox_env
install: .environment

location_setup:
	mkdir -p $(LOCATION)/
install_theme:
	mkdir -p $(HOME)/.themes
	mkdir -p $(HOME)/.local/share/firefox/.themes
	ln -sf $(CURDIR)/earth $(HOME)/.themes/
	ln -sf $(CURDIR)/earth $(HOME)/.local/share/firefox/.themes
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
install_bash:
	ln -sf $(CURDIR)/bash $(LOCATION)/bash
install_ssh:
	ln -sf $(CURDIR)/ssh $(LOCATION)/ssh
install_git:
	ln -sf $(CURDIR)/git $(LOCATION)/git
install_tridactyl:
	ln -sf $(CURDIR)/tridactyl $(LOCATION)/tridactyl
install_htop:
	ln -sf $(CURDIR)/htop $(LOCATION)/htop
install_python:
	ln -sf $(CURDIR)/python $(LOCATION)/python
.environment:
	sh environ
.firefox_env:
	sh firefox_setup
