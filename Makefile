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
	ln -sf $(CURDIR)/bspwm $(LOCATION)/
install_nvim:
	ln -sf $(CURDIR)/nvim $(LOCATION)/
install_sx:
	ln -sf $(CURDIR)/sx $(LOCATION)/
install_sxhkd:
	ln -sf $(CURDIR)/sxhkd $(LOCATION)/
install_zathura:
	ln -sf $(CURDIR)/zathura $(LOCATION)/
install_bash:
	ln -sf $(CURDIR)/bash $(LOCATION)/
install_ssh:
	ln -sf $(CURDIR)/ssh $(LOCATION)/
install_git:
	ln -sf $(CURDIR)/git $(LOCATION)/
install_tridactyl:
	ln -sf $(CURDIR)/tridactyl $(LOCATION)/
install_htop:
	ln -sf $(CURDIR)/htop $(LOCATION)/
install_python:
	ln -sf $(CURDIR)/python $(LOCATION)/
.environment:
	sh environ
.firefox_env:
	sh firefox_setup
