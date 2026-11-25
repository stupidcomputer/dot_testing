{ pkgs, ppkgs, inputs, ... }:
let
  claude = "${inputs.llm-agents.packages."x86_64-linux".claude-code}/bin/claude";
  # own socket, so this doesn't mix with tmux servers started by hand
  tmux = "${pkgs.tmux}/bin/tmux -L claude";

  # bring claude back if it exits
  loop = pkgs.writeShellScript "claude-loop" ''
    while true; do
      ${claude} --dangerously-skip-permissions --chrome --remote-control kant
      sleep 10
    done
  '';

  attach = pkgs.writeShellScriptBin "claude-attach" ''
    exec ${tmux} attach -t claude
  '';
in
{
  environment.systemPackages = [ attach ];

  # make claude the only extension in brave. "blocked" disables any others that
  # are already installed
  environment.etc."brave/policies/managed/claude.json".text = builtins.toJSON {
    ExtensionSettings = {
      "*".installation_mode = "blocked";
      fcoeoabgfenejglbffodgkkbkcdhcgfn = {
        installation_mode = "force_installed";
        update_url = "https://clients2.google.com/service/update2/crx";
      };
    };
  };

  # show claude on workspace 1, and start brave on 2 for --chrome to connect to
  services.xserver.displayManager.sessionCommands = ''
    (
      i3msg() { ${pkgs.i3}/bin/i3-msg "$@" >/dev/null 2>&1; }
      win_count() {
        ${pkgs.i3}/bin/i3-msg -t get_tree \
          | ${pkgs.jq}/bin/jq '[recurse(.nodes[], .floating_nodes[]) | select(.window != null)] | length'
      }
      # launch_on WS CMD: focus WS, run CMD, wait for its window to map
      launch_on() {
        before="$(win_count)"
        i3msg "workspace number $1; exec $2"
        for _ in $(seq 1 100); do
          [ "$(win_count)" -gt "$before" ] && break
          sleep 0.2
        done
      }
      # wait for i3, and for the tmux session (which waits for the network)
      for _ in $(seq 1 240); do
        i3msg -t get_version && ${tmux} has-session -t claude 2>/dev/null && break
        sleep 0.5
      done
      launch_on 1 "${ppkgs.st}/bin/st -e ${attach}/bin/claude-attach"
      launch_on 2 "${pkgs.brave}/bin/brave"
      i3msg "workspace number 1"
    ) &
  '';

  systemd.services.claude-tmux = {
    description = "tmux session with claude for usr";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    # a rebuild run from within claude shouldn't kill it
    restartIfChanged = false;

    serviceConfig = {
      Type = "forking";
      User = "usr";
      # has to be a directory that claude already trusts
      WorkingDirectory = "/home/usr/dots";
      # the login shell sets up the usual PATH
      ExecStart = "${tmux} new-session -d -s claude -n claude '${pkgs.bashInteractive}/bin/bash -lc ${loop}'";
      ExecStop = "${tmux} kill-server";
      Restart = "on-failure";
      RestartSec = 10;
    };
  };
}
