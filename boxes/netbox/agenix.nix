{ machines, ... }:
{
  age.secrets = {
    mailaccount = {
      file = ../../secrets/mailaccount.age;
    };

    netbox-wg-priv = {
      file = machines.netbox.wg-privkey;
    };

    radicale-passwd = {
      file = ../../secrets/radicale-passwd.age;
      owner = "radicale";
      group = "radicale";
    };
  };
}
