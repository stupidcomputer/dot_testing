{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    neovim

    # for various lsp things
    lua-language-server
    # TODO: inclusion of this package causes a build error due to a long-running
    # test on package 'whatthepatch'. Need to contribute a fix to this.
#    python311Packages.python-lsp-server
    texlab
    nixd
  ];

  system.userActivationScripts.copyNeovimConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/nvim
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/nvim/init.lua /home/usr/.config/nvim/init.lua
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/nvim/colors /home/usr/.config/nvim/colors
    '';
    deps = [];
  };
}
