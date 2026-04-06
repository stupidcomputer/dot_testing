{
  router = {
    ip-addrs = {
      localnet = "192.168.1.1";
    };
  };
  copernicus = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBGh1FHPneg7PCDkhMs2BCJPTIRVJkRTKpOj1w02ydD usr";
    wg-privkey = ../secrets/copernicus.privkey.age;
    wg-pubkey = "1dOlQWwviuWYxnYEWFO20Cb4aO9y1eeqBLlag7p8kFw=";
    ip-addrs = {
      localnet = "192.168.1.201";
      intnet = "10.100.0.2";
    };
    syncthing-id = "M7DSXSL-FRPZQ2Z-32XEIE2-T4XPU76-OL4AMXS-UPM3R2L-WRIHWUO-2RNMEAQ";
    description = ''
      The main desktop PC.
    '';
  };
  phone = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAImPZp8/B6taPvrOgrodVbc7WbWoQWnrwV+1DlV/vgi u0_a340";
    ip-addrs = {
      localnet = "192.168.1.203";
    };
    syncthing-id = "WR2IVGD-7XKTMTR-FDI74B4-PLDNIXR-TV5OEAJ-ESB75H7-RADC4NR-DGSWDAU";
    description = ''
      A Pixel 8a running termux and some other things.
    '';
  };
  aristotle = {
    description = ''
      A Lenovo Thinkpad Yoga 260. Power supply seems to have died.
    '';
  };
  netbox = {
    syncthing-id = "O7K4VBQ-N5ENCDW-YMGMQP7-MADCKHK-T5OBSNH-4B3BE7W-Z3DK2G5-DH22NQQ";
    description = ''
      Just a tiny VPS, nothing much.
    '';
  };
  theseus = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNOmlULaILeL5QOAuKqMbhV6vXOWjxgsN3wpvFRvarz usr";
    wg-privkey = ../secrets/theseus.privkey.age;
    wg-pubkey = "IMCkYrhYgki6Qjo7SLlU2yNWqo7qCGVwLGs7nv7ZyVI=";
    ip-addrs = {
      intnet = "10.100.0.1";
    };
  };
  plato = {
    description = ''
      A Lenovo Thinkpad X230.
    '';
  };
  hammurabi = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaUHLYuEgmNWQTQUB9nZA3L2QCOaQyqrcRv+8xGkdAM usr";
    syncthing-id = "MTWVSQK-A7BYY7G-I35WEPP-O7MFMTD-CB4CIEN-7ZBUJ5C-LVGMPQ3-JACXNQK";
    wg-privkey = ../secrets/hammurabi.privkey.age;
    wg-pubkey = "64JyhmL+SpPFN/XL579hGyNUP0jE3BRfHHn7H1ypoAQ=";
    ip-addrs = {
      intnet = "10.100.0.3";
    };
    description = ''
      A Lenovo Thinkpad L13 Yoga.
    '';
  };

  mkHosts = machines: hostname: network:
    builtins.listToAttrs [
      {
        "name" = (
          builtins.getAttr network (
            builtins.getAttr hostname machines
          ).ip-addrs
        );
        "value" = [ hostname ];
      }
    ];
}
