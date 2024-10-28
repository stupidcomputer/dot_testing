{ lib, config, pkgs, ...}:

{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "10.100.0.2";
        http_port = 9802;
        domain = "grafana.beepboop.systems";
      };
    };
  };

  services.prometheus = {
    enable = true;
    listenAddress = "10.100.0.2";
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        listenAddress = "10.100.0.2";
        port = 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "copernicus";
        static_configs = [{
          targets = [ "10.100.0.2:9002" ];
        }];
      }
      {
        job_name = "netbox";
        static_configs = [{
          targets = [ "10.100.0.1:9002" ];
        }];
      }
    ];
  };
}
