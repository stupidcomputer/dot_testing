{ lib, pkgs, config, ... }:
let
  cfg = config.services.gmail_mail_bridge;
  appEnv = pkgs.python3.withPackages (p: with p; [ waitress (callPackage ./gmail_mail_bridge/default.nix {}) ]);
in {
  options.services.gmail_mail_bridge = {
    enable = lib.mkEnableOption "Enable the gmail_mail_bridge";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.gmail_mail_bridge = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${appEnv}/bin/waitress-serve --port=8041 gmail_mail_bridge:app";
	StandardOutput = "journal";
      };
    };
  };
}
