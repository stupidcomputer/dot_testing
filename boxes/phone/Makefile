.DEFAULT_GOAL := all
SHELL := /bin/bash

REPO_ROOT   := $(CURDIR)/../..
PPKGS       := $(REPO_ROOT)/ppkgs
BIN_DIR     := $(HOME)/.local/bin

.PHONY: all help utils-sh rebuild-sh pip-pkgs pip-pkgs-upgrade \
        termux-pkgs termux-dots shortcuts boot phone-routine

all: termux-pkgs termux-dots utils-sh rebuild-sh pip-pkgs phone-routine

## help: list targets with descriptions
help:
	@grep -E '^## [a-zA-Z0-9_.-]+:' $(MAKEFILE_LIST) | sed 's/^## /  /'

## utils-sh: install utility scripts
utils-sh:
	install -Dm755 -t $(BIN_DIR) $(PPKGS)/utils/*

## rebuild-sh: install a helper script
rebuild-sh:
	install -d $(BIN_DIR)
	printf '#!/bin/sh\nexec $(MAKE) -C $(CURDIR) "$$@"\n' > $(BIN_DIR)/rebuild
	chmod 755 $(BIN_DIR)/rebuild

## pip-pkgs: install pip packages
PIP_PKGS :=
#PIP_PKGS += khard

pip-pkgs:
ifneq ($(strip $(PIP_PKGS)),)
	pip3 install $(PIP_PKGS)
else
	@echo "pip-pkgs: PIP_PKGS is empty, skipping"
endif

## pip-pkgs-upgrade: force pip packages to latest
pip-pkgs-upgrade:
ifneq ($(strip $(PIP_PKGS)),)
	pip3 install --upgrade $(PIP_PKGS)
else
	@echo "pip-pkgs-upgrade: PIP_PKGS is empty, skipping"
endif

## termux-pkgs: install termux packages
TERMUX_REPOS := tur-repo
TERMUX_PKGS  := neovim emacs python-pip git tig \
                clang elinks tmux fontconfig fzy man \
                firefox mupdf texlive-bin htop rbw pkg-config \
                termux-api jq isync neomutt \
                pandoc wget which rsync openssl chromium espeak

termux-pkgs:
	@wanted="$(TERMUX_REPOS) $(TERMUX_PKGS)"; \
	installed="$$(pkg list-installed 2>/dev/null | cut -d/ -f1)"; \
	missing="$$(comm -23 <(tr ' ' '\n' <<<"$$wanted" | sort -u) <(sort -u <<<"$$installed"))"; \
	if [ -n "$$missing" ]; then \
		echo "Installing:"; echo "$$missing" | sed 's/^/  /'; \
		pkg install -y $$missing; \
	else \
		echo "termux-pkgs: all packages already present, skipping"; \
	fi

## termux-dots: symlink dotfiles into place
termux-dots: $(HOME)/.ssh/config $(HOME)/.bashrc $(HOME)/.bash_profile \
             $(HOME)/.emacs.d/init.el \
             $(HOME)/.config/nvim/init.lua $(HOME)/.config/nvim/colors/earth.vim \
             $(HOME)/.termux/termux.properties $(HOME)/.config shortcuts boot

## config-dir: ensure ~/.config is a real directory, healing it if something
## (unidentified so far) has left it as a broken symlink
$(HOME)/.config:
	@if [ -L "$(HOME)/.config" ] && [ ! -e "$(HOME)/.config" ]; then \
		echo "removing broken symlink at $(HOME)/.config -> $$(readlink $(HOME)/.config)"; \
		rm -f "$(HOME)/.config"; \
	fi
	mkdir -p "$(HOME)/.config"

## ssh-config: symlink ssh config
$(HOME)/.ssh/config:
	mkdir -p $(HOME)/.ssh
	ln -sf $(REPO_ROOT)/config/ssh/config $(HOME)/.ssh/config

## bashrc: symlink bashrc
$(HOME)/.bashrc:
	ln -sf $(REPO_ROOT)/config/bash/bashrc $(HOME)/.bashrc

## bash-profile: symlink bash_profile
$(HOME)/.bash_profile:
	ln -sf $(REPO_ROOT)/config/bash/profile $(HOME)/.bash_profile

## emacs-init: symlink emacs init.el
$(HOME)/.emacs.d/init.el:
	mkdir -p $(HOME)/.emacs.d
	ln -sf $(REPO_ROOT)/config/emacs/init.el $(HOME)/.emacs.d/init.el

## nvim-init: symlink neovim config (mirrors what home-manager's
## common/ryande.nix wires up on the NixOS boxes, since that doesn't apply
## to Termux)
$(HOME)/.config/nvim/init.lua: $(HOME)/.config
	mkdir -p $(HOME)/.config/nvim
	ln -sf $(REPO_ROOT)/config/nvim/init.lua $(HOME)/.config/nvim/init.lua

$(HOME)/.config/nvim/colors/earth.vim: $(HOME)/.config/nvim/init.lua
	mkdir -p $(HOME)/.config/nvim/colors
	ln -sf $(REPO_ROOT)/config/nvim/colors/earth.vim $(HOME)/.config/nvim/colors/earth.vim

## shortcuts: symlink termux shortcuts
shortcuts:
	mkdir -p $(HOME)/.shortcuts
	ln -sf -t $(HOME)/.shortcuts $(CURDIR)/shortcuts/*

## boot: symlink termux:boot scripts
boot:
	mkdir -p $(HOME)/.termux/boot
	ln -sf -t $(HOME)/.termux/boot $(CURDIR)/boot/*

## termux-config: symlink termux configuration
$(HOME)/.termux/termux.properties:
	mkdir -p $(HOME)/.termux
	ln -sf $(CURDIR)/termux.properties $(HOME)/.termux/termux.properties

## phone-routine: install the morning alarm / procedure runner
phone-routine:
	install -Dm755 $(CURDIR)/phone_routine.py $(BIN_DIR)/phone-routine
	ln -sf phone-routine $(BIN_DIR)/phone-routine-wakeup-check
