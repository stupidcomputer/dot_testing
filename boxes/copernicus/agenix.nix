{ machines, ... }:
{
  age = {
    secrets = {
      copernicus-wg-priv = {
        file = machines.copernicus.wg-privkey;
      };
    };
    identityPaths = [ "/home/usr/.ssh/id_ed25519" ];
  };
}
