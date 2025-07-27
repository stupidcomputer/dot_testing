{ pkgs, config, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    aerc
  ];

  age = {
    secrets = {
      aerc-account-config = {
        file = ../../secrets/aerc-account-config.age;
        mode = "600";
        owner = "usr";
        group = "users";
      };
    };
  };

  system.userActivationScripts.copyAercConfiguration = {
    text = ''
      mkdir -p /home/usr/.config/aerc
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/aerc/binds.conf /home/usr/.config/aerc/binds.conf
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/aerc/aerc.conf /home/usr/.config/aerc/aerc.conf
      ${pkgs.coreutils}/bin/ln -sf ${config.age.secrets.aerc-account-config.path} /home/usr/.config/aerc/accounts.conf
    '';
    deps = [];
  };
}
