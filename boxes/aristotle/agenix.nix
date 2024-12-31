{ machines, ... }:
{
  age = {
    secrets = {
      nm-home-net-config = {
        file = ../../secrets/nm-home-net-config.age;
        path = "/etc/NetworkManager/system-connections/main.nmconnection";
      };
    };
    identityPaths = [ "/home/usr/.ssh/id_ed25519" ];
  };
}
