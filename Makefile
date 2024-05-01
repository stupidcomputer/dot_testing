termux: termux-pkgs termux-dots utils-sh st

st:
	cd builds/st/ && CC=clang make && cp st ~/.local/bin/st

utils-sh:
	cp builds/utils/sh/* ~/.local/bin

termux-pkgs:
	pkg install \
		neovim \
		git \
		tig \
		tigervnc \
		sxhkd \
		clang \
		elinks \
		tmux \
		fontconfig \
		xorgproto \
		fzy \
		man \
		libxft \
		firefox \
		mupdf \
		texlive-bin \
		htop \
		rbw \
		pkg-config \
		bspwm \
		termux-api \
		jq \
		x11-repo

termux-dots:
	ln -sf $(CURDIR)/.config ~/.config
	ln -sf $(CURDIR)/home/ssh/config ~/.ssh/config
	ln -sf ~/.config/bash/bashrc ~/.bashrc
	ln -sf ~/.config/bash/profile ~/.bash_profile
