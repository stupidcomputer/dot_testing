{ pkgs, inputs, ... }:

let
  claude = "${inputs.llm-agents.packages."x86_64-linux".claude-code}/bin/claude";
  tmux = "${pkgs.tmux}/bin/tmux";

  session = "claude";
  workdir = "/home/usr";

  startScript = pkgs.writeShellScript "start-tmux-session" ''
    if ${tmux} has-session -t ${session} 2>/dev/null; then
      if [ "$(${tmux} list-windows -t ${session}: 2>/dev/null | wc -l)" -ge 3 ]; then
        exit 0
      fi
      ${tmux} kill-session -t ${session} 2>/dev/null || true
    fi

    ${tmux} new-session -d -s ${session} -c ${workdir} -n anchor
    ${tmux} set-option -g remain-on-exit on
    ${tmux} set-option -g automatic-rename off
    ${tmux} set-option -g allow-rename off
    ${tmux} set-option -g renumber-windows on

    ${tmux} new-window -t ${session}: -c ${workdir} -n claude \
      '${claude} --dangerously-skip-permissions'
    ${tmux} new-window -t ${session}: -c ${workdir} -n remote-control \
      '${claude} remote-control --permission-mode bypassPermissions'
    ${tmux} new-window -t ${session}: -c ${workdir} -n bash \
      '${pkgs.bashInteractive}/bin/bash'

    ${tmux} kill-window -t ${session}:anchor
    ${tmux} select-window -t ${session}:claude 2>/dev/null || true
  '';

  stopScript = pkgs.writeShellScript "stop-tmux-session" ''
    ${tmux} kill-session -t ${session} 2>/dev/null || true
  '';
in
{
  systemd.services.claude-tmux = {
    description = "Detached tmux session with claude for usr";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "usr";
      WorkingDirectory = workdir;
      ExecStart = startScript;
      ExecStop = stopScript;
    };

    environment = {
      HOME = "/home/usr";
    };
  };
}
