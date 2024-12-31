{ pkgs, ... }:
{
  virtualisation.docker.enable = true;

  services.nginx.virtualHosts."franklincce.beepboop.systems" = {
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      proxyPass = "http://localhost:1337";
    };
  };

  # WARNING WARNING WARNING
  # the below is SUPER BAD and should not be copied ANYWHERE
  # the docker container should be initialized by a flake or other nix concept,
  # not this nonsense

  systemd.services.franklincce = {
    description = "the docker container that runs the franklincce app";

    environment = { # this is EVIL, NEVER DO THIS!!!111!
      NIX_PATH = "nixpkgs=flake:nixpkgs:/nix/var/nix/profiles/per-user/root/channels";
    };

    script = ''
      cd /home/ryan

      # don't fail if cloning the git repo fails
      ${pkgs.git}/bin/git clone https://git.beepboop.systems/stupidcomputer/yig yig || true

      cd /home/ryan/yig
      ${pkgs.nix}/bin/nix-shell --command make
    '';

    serviceConfig = {
      User = "ryan";
    };

    wantedBy = [ "multi-user.target" ];
  };
}
