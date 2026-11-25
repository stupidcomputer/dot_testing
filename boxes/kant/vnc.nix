{ pkgs, ... }:

{
  # shares the logged-in X session over tailscale. systemd listens on the port
  # and starts one x11vnc per connection.
  # FIXME: password auth is temporary; go back to listening on 127.0.0.1 and
  # vncviewer -via (ssh keys)
  #
  # the password has to be created by hand:
  #   mkdir -p -m 700 ~/.vnc && x11vnc -storepasswd ~/.vnc/passwd
  systemd.user.sockets.x11vnc = {
    description = "x11vnc socket for the current X session";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    unitConfig = {
      ConditionUser = "usr";
      # never listen without a password
      ConditionPathExists = "%h/.vnc/passwd";
    };
    listenStreams = [ "0.0.0.0:5900" ];
    socketConfig = {
      Accept = true;
      MaxConnections = 8;
    };
  };

  systemd.user.services."x11vnc@" = {
    description = "x11vnc connection";
    partOf = [ "graphical-session.target" ];

    # don't keep failed connections (bad passwords, etc) around
    unitConfig.CollectMode = "inactive-or-failed";
    serviceConfig = {
      # DISPLAY and XAUTHORITY come from the session environment
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -inetd -rfbauth %h/.vnc/passwd -repeat -noxrecord";
      StandardInput = "socket";
      StandardOutput = "socket";
      StandardError = "journal";
    };
  };

  # only reachable over tailscale
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 5900 ];
  };
}
