{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git

    # supporting utils
    gh
    tea
  ];

  system.userActivationScripts.copyGitConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/git
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/git/config /home/usr/.config/git/config
    '';
    deps = [];
  };
}
