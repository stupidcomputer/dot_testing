{ pkgs, ... }:
{
  dmenu = (pkgs.callPackage ./dmenu.nix {});
  dwm = (pkgs.callPackage ./dwm.nix {});
  flasktrack = (pkgs.callPackage ./flasktrack.nix {});
  pcomon = (pkgs.callPackage ./pcomon.nix {});
  rebuild = (pkgs.callPackage ./rebuild.nix {});
  sssg = (pkgs.callPackage ./sssg.nix {});
  st = (pkgs.callPackage ./st.nix {});
  tilp = (pkgs.callPackage ./tilp.nix {});
  utils = (pkgs.callPackage ./utils.nix {});
}
