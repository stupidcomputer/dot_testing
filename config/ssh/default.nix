{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # other ssh related stuff
    sshfs
    sshuttle
  ];

  system.userActivationScripts.copySSHConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/ssh
      mkdir -p /home/usr/.ssh
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/ssh/config /home/usr/.config/ssh/config
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/ssh/config /home/usr/.ssh/config
    '';
    deps = [];
  };
}
