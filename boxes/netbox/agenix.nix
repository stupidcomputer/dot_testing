{ machines, ... }:
{
  age.secrets = {
    mailaccount = {
      file = ../../secrets/mailaccount.age;
    };

    netbox-wg-priv = {
      file = machines.netbox.wg-privkey;
    };
  };
}
