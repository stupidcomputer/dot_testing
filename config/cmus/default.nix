{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cmus

    # all audio utilities, broadly
    ncpamixer
    bluetuith

    # edit tags
    kid3-cli
  ];

  system.userActivationScripts.copyCmusConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/cmus
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/cmus/rc /home/usr/.config/cmus/rc
    '';
    deps = [];
  };
}
