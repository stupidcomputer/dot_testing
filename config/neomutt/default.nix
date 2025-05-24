{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    neomutt
  ];

  system.userActivationScripts.copyNeomuttConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/neomutt
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/neomutt/aristotle_neomuttrc /home/usr/.config/neomutt/neomuttrc
    '';
    deps = [];
  };
}
