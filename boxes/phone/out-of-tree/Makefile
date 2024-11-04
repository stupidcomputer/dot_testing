termux: termux-pkgs termux-dots utils-sh rebuild-sh st pip-pkgs git-annex.linux sssg statusbar-polyfill

list: options # alias
options:
	@echo specific options
	@echo st - rebuild st
	@echo utils-sh - copy utilities
	@echo pip-pkgs - install pip packages
	@echo termux-pkgs - install termux pkgs
	@echo termux-dots - install termux dotfiles
	@echo git-annex.linux - install git-annex
	@echo sssg - install sssg

st:
	-cd ../../../builds/st/ && CFLAGS="-DIS_PHONE" CC=clang make && cp st ~/.local/bin/st

utils-sh:
	mkdir -p ~/.local/bin
	cp ../../../builds/utils/* ~/.local/bin

rebuild-sh:
	mkdir -p ~/.local/bin
	cp ../../../builds/rebuild/* ~/.local/bin

pip-pkgs:
	pip3 install vdirsyncer
	pip3 install khal
#	pip3 install khard

termux-pkgs:
	pkg install \
		tur-repo \
		x11-repo
		
	pkg install \
		neovim \
		python-pip \
		feh \
		xdotool \
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
		xorg-xrandr \
		bspwm \
		termux-api \
		jq \
		xclip \
		isync \
		neomutt \
		pandoc \
		wget \
		which \
		openssl

	pkg install \
		chromium # from tur-repo

termux-dots:
	mkdir -p ~/.local/bin
	ln -sf $(CURDIR)/../../../.config ~/.config
	ln -sf $(CURDIR)/../../../.config/ssh/config ~/.ssh/config
	ln -sf ~/.config/bash/bashrc ~/.bashrc
	ln -sf ~/.config/bash/profile ~/.bash_profile
	mkdir -p ~/.local/share
	cp $(CURDIR)/../../../home/wallpapers/pape.jpg ~/.local/share
	mkdir -p ~/.shortcuts
	cp $(CURDIR)/shortcuts/* ~/.shortcuts

git-annex.linux:
	bash install-git-annex.sh

sssg:
	-cp ~/git/sssg/sssg.sh ~/.local/bin/sssg
	-chmod +x ~/.local/bin/sssg

statusbar-polyfill:
	cp ~/dot_testing/builds/statusbar/termux-statusbar-polyfill ~/.local/bin
