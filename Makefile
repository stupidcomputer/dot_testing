termux: termux-pkgs termux-dots utils-sh st

st:
	cd builds/st/ && CC=clang make && cp st ~/.local/bin/st

utils-sh:
	cp builds/utils/sh/* ~/.local/bin

termux-pkgs:
	pkg install \
		neovim \
		git \
		tigervnc \
		sxhkd \
		clang \
		fontconfig \
		xorgproto \
		fzy \
		libxft \
		firefox \
		htop \
		pkg-config \
		bspwm \
		x11-repo

termux-dots:
	ln -sf $(CURDIR)/.config ~/.config
	ln -sf ~/.config/bash/bashrc ~/.bashrc
	ln -sf ~/.config/bash/profile ~/.bash_profile
