{
  age.secrets = {
    gitea-postgres-password = {
      file = ../../secrets/gitea-postgres-password.age;
      mode = "0700";
      owner = "gitea";
      group = "gitea";
    };

    mailaccount = {
      file = ../../secrets/mailaccount.age;
    };

    netbox-wg-priv = {
      file = ../../secrets/netbox-wg-priv.age;
    };

    radicale-passwd = {
      file = ../../secrets/radicale-passwd.age;
      owner = "radicale";
      group = "radicale";
    };
  };
}
