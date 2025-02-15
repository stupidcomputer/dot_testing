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

    nextcloud-passwd = {
      file = ../../secrets/nextcloud-admin-passwd.age;
      owner = "nextcloud";
      group = "nextcloud";
    };

    pcomon-secrets-file = {
      file = ../../secrets/pcomon-secrets-file.age;
      owner = "pcomon";
      group = "pcomon";
    };
  };
}
