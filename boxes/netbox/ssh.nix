{ lib, config, pkgs, machines, ... }:

{
  services.openssh = {
    enable = true;
    ports = [55555];
    settings = {
      X11Forwarding = false;
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  users.users.ryan.openssh.authorizedKeys.keys = [
    machines.copernicus.pubkey
    machines.aristotle.pubkey
    machines.phone.pubkey
  ];

  # save ip addresses in cache from repeat logins
  services.nginx.virtualHosts."localhost" = {
    listen = [{ addr = "127.0.0.1"; port = 9414; }];
    extraConfig = ''
      location / {
        proxy_pass_request_headers off;
        proxy_pass https://ipinfo.io/;
        proxy_cache_key $scheme://$host$uri$is_args$query_string;
        proxy_cache_valid 203 1d;
      }
    '';
  };

  environment.etc."ssh/sshrc".text = ''
    login_ip="''${SSH_CLIENT%% *}"
    is_in_ignored=$(grep "$login_ip" /etc/ssh/ignored_ips -c)
    if [ "$is_in_ignored" -gt 0 ]; then
      echo "Your login has been ignored based on your IP address."
      exit
    fi
    time=$(date "+%T%:z")
    geodata=$(
      curl -s 127.0.0.1:9414/$login_ip |
      sed '1d;$d;/readme/d;s/^  //g'
    )
    ${pkgs.mailutils}/bin/mail \
      ryan@beepboop.systems -r "ssh" \
      -s "ssh login from $login_ip at $time" \
    <<EOF
    Hi there,

    \`netbox\` was just logged into from $login_ip at $time (America/Chicago).
    It was not in /etc/ssh/ignored_ips.

    If this is you, that's great! If not, there is most certainly
    an unauthorized user connected to the machine -- in which case, the
    prudent course of action is to shut the machine down.

    For your information, here is geolocation data from $login_ip.

    $geodata
    EOF
  '';
}
