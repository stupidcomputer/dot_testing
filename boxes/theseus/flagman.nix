{ inputs, config, ... }:
{
  imports = [
    inputs.flagman.nixosModules.flagman
  ];

  age.secrets.flagman = {
    file = ../../secrets/flagman-env.age;
    owner = "flagman";
  };

  services.flagman = {
    enable = true;
    domain = "flagmanager.net";
    settingsFile = config.age.secrets.flagman.path;
    enablePostgres = true;
    databaseName = "flagman";
    databaseUser = "flagman";
    internalPort = 3032;
    acmeEmail = "nickforanick@protonmail.com";
    enableSignups = false;
  };
}
