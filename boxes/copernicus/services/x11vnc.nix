{ pkgs, ... }:
{
  systemd.services.x11vnc = {
    description = "start x11vnc automatically";
    serviceConfig = {
      ExecStartPre = "${pkgs.bash}/bin/bash -c '${pkgs.systemd}/bin/systemctl set-environment SDDMXAUTH=$(${pkgs.findutils}/bin/find /var/run/sddm/ -type f)'";
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -auth \${SDDMXAUTH} -listen 127.0.0.1 -rfbport 5900 -repeat -forever";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
