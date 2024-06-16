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

for installation onto Termux, run `make`.

things to do
------------

- integrate `disko` and `sops-nix` into the setup
- establish backup infrastructure for `netbox`
- move gmail-mail-bridge into mail-sync repo
  * (perhaps figure out how to produce a flake for it)

license
-------

all materials in this repository, except for:

* `./home/wallpapers/pape.jpg`, which is of unknown license, and
* `./builds/st`, which is licensed under MIT, persuant to `./builds/st/LICENSE`,

is (c) rndusr, randomuser, stupidcomputer, etc 2024 and licensed under the GPLv3 (see `./LICENSE`)
