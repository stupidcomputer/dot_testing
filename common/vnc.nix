{ lib, pkgs, ... }:

let
  secretFile = ../secrets/vnc-passwd.age;
  haveSecret = builtins.pathExists secretFile;
  # where agenix decrypts secretFile
  passwdFile = "/run/agenix/vnc-passwd";
in
{
  # shares the logged-in X session over ssh. systemd listens on loopback while
  # a graphical session is active, and starts one x11vnc per connection.
  #
  # connect with: vncviewer -via <host> -passwd /run/agenix/vnc-passwd localhost:0
  #
  # the password is created once, by secrets/gen-vnc-passwd
  warnings = lib.optional (!haveSecret)
    "secrets/vnc-passwd.age doesn't exist, so x11vnc won't listen";

  age.secrets = lib.mkIf haveSecret {
    vnc-passwd = {
      file = secretFile;
      path = passwdFile;
      owner = "usr";
      mode = "0400";
    };
  };

  systemd.user.sockets.x11vnc = {
    description = "x11vnc socket for the current X session";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    unitConfig = {
      ConditionUser = "usr";
      # never listen without a password
      ConditionPathExists = passwdFile;
    };
    # loopback only; ssh is the way in
    listenStreams = [ "127.0.0.1:5900" ];
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
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -inetd -rfbauth ${passwdFile} -repeat -noxrecord";
      StandardInput = "socket";
      StandardOutput = "socket";
      StandardError = "journal";
    };
  };
}
