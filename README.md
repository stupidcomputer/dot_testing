randomuser's dotfiles
=====================

![an image of the desktop while editing this repo's flake.nix](./demo.png)

features
--------

- `bspwm` + `sxhkd` + `st` + `firefox`
- most everything on the desktop save for the browser, media viewers, and desktop background, is a terminal
- on the server, runs gitea + simple-nixos-mailserver
- built with NixOS flakes

installation
------------

`sudo nixos-rebuild --flake .#your-flake-name-here switch`

if you're trying to install `netbox`, then use the `--impure` flag:

`sudo nixos-rebuild --flake .#netbox switch --impure`

for alternate installations on non-NixOS hosts, a Makefile will be made available

things to do
------------

- integrate `disko` and `sops-nix` into the setup
- establish backup infrastructure for `netbox`
- move gmail-mail-bridge into mail-sync repo
  * (perhaps figure out how to produce a flake for it)

license
-------

all materials, except for:
	a) `./home/wallpapers/pape.jpg`, which is of unknown licenses, and
	b) ./builds/st, which is licensed under MIT, persuant to ./builds/st/LICENSE,
is licensed under the GPLv3.
