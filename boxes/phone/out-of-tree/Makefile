termux: termux-pkgs termux-dots utils-sh st pip-pkgs git-annex.linux

st:
	cd ../../../builds/st/ && CFLAGS="-DIS_PHONE" CC=clang make && cp st ~/.local/bin/st

utils-sh:
	cp ../../../builds/utils/* ~/.local/bin

pip-pkgs:
	pip3 install vdirsyncer
	pip3 install khal
#	pip3 install khard

termux-pkgs:
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
		bspwm \
		termux-api \
		jq \
		isync \
		neomutt \
		wget \
		tur-repo \
		x11-repo

	pkg install \
		chromium # from tur-repo

termux-dots:
	ln -sf $(CURDIR)/../../../.config ~/.config
	ln -sf $(CURDIR)/../../../home/ssh/config ~/.ssh/config
	ln -sf ~/.config/bash/bashrc ~/.bashrc
	ln -sf ~/.config/bash/profile ~/.bash_profile
	mkdir -p ~/.local/share
	cp $(CURDIR)/../../../home/wallpapers/pape.jpg ~/.local/share
	mkdir -p ~/.shortcuts
	cp $(CURDIR)/shortcuts/* ~/.shortcuts

git-annex.linux:
	bash install-git-annex.sh
