{ pkgs, ppkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/ryande.nix
    ../../common/bootstrap.nix
    ./agenix.nix
    ./sshd.nix
    ./tmux.nix
  ];

  virtualisation.virtualbox.guest.enable = true;
  services.ryande.enable = true;

  networking = {
    hostName = "descartes";
    networkmanager.enable = true;
    firewall.checkReversePath = false;
  };

  security.sudo.extraRules = [
    {
      users = [ "usr" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.ControllerMode = "dual";
    };
  };

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "usr";
    };
    defaultSession = "none+i3";
  };

  services.xserver.displayManager.sessionCommands = ''
    (
      i3msg() { ${pkgs.i3}/bin/i3-msg "$@"; }
      win_count() {
        i3msg -t get_tree \
          | ${pkgs.jq}/bin/jq '[recurse(.nodes[], .floating_nodes[]) | select(.window != null)] | length'
      }
      # Wait for the i3 IPC socket to be ready.
      for _ in $(seq 1 60); do
        i3msg -t get_version >/dev/null 2>&1 && break
        sleep 0.5
      done
      # launch_on WS CMD...: focus WS, run CMD via i3, wait for its window to map.
      launch_on() {
        ws="$1"; shift
        before="$(win_count)"
        i3msg "workspace number $ws" >/dev/null 2>&1
        i3msg "exec $*" >/dev/null 2>&1
        for _ in $(seq 1 100); do
          [ "$(win_count)" -gt "$before" ] && break
          sleep 0.2
        done
      }
      launch_on 1 "${ppkgs.st}/bin/st -e ${pkgs.tmux}/bin/tmux attach -t claude"
      launch_on 2 "${pkgs.brave}/bin/brave"
      i3msg "workspace number 1" >/dev/null 2>&1
    ) &
  '';

  # don't touch these
  system.stateVersion = "25.05";
  home-manager.users.usr.home.stateVersion = "25.05";
}
