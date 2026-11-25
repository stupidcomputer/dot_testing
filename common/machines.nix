rec {
  router = {
    ip-addrs = {
      localnet = "192.168.1.1";
    };
    description = ''
      Router for home network.
    '';
  };
  hue = {
    ip-addrs = {
      localnet = "192.168.1.210";
    };
    description = ''
      Hue bridge
    '';
  };
  copernicus = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBGh1FHPneg7PCDkhMs2BCJPTIRVJkRTKpOj1w02ydD usr";
    ip-addrs = {
      localnet = "192.168.1.201";
      intnet = "100.64.0.2";
    };
    syncthing-id = "M7DSXSL-FRPZQ2Z-32XEIE2-T4XPU76-OL4AMXS-UPM3R2L-WRIHWUO-2RNMEAQ";
    description = ''
      The main desktop PC.
    '';
    allowed-ssh-access = [
      copernicus.pubkey
      hammurabi.pubkey
      phone.pubkey
      theseus.pubkey
    ];
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
  homepage-android = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJwUQDNM7RGl6MZ3rehiK2he3VyEhOZEaTrsmcFBg/R homepage-android";
  };
  aristotle = {
    description = ''
      A Lenovo Thinkpad Yoga 260. Power supply seems to have died.
    '';
  };
  theseus = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNOmlULaILeL5QOAuKqMbhV6vXOWjxgsN3wpvFRvarz usr";
    syncthing-id = "O7K4VBQ-N5ENCDW-YMGMQP7-MADCKHK-T5OBSNH-4B3BE7W-Z3DK2G5-DH22NQQ";
    ip-addrs = {
      intnet = "100.64.0.1";
    };
    allowed-ssh-access = [
      copernicus.pubkey
      hammurabi.pubkey
      phone.pubkey
      homepage-android.pubkey
    ];
    description = ''
      Just a tiny VPS, nothing much.
    '';
  };
  plato = {
    description = ''
      A Lenovo Thinkpad X230.
    '';
  };
  hammurabi = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaUHLYuEgmNWQTQUB9nZA3L2QCOaQyqrcRv+8xGkdAM usr";
    syncthing-id = "MTWVSQK-A7BYY7G-I35WEPP-O7MFMTD-CB4CIEN-7ZBUJ5C-LVGMPQ3-JACXNQK";
    ip-addrs = {
      intnet = "100.64.0.3";
    };
    allowed-ssh-access = [
      copernicus.pubkey
      hammurabi.pubkey
      phone.pubkey
      theseus.pubkey
    ];
    description = ''
      A Lenovo Thinkpad L13 Yoga.
    '';
  };
  descartes = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOdic7JAVd69kQ1PjjDNu7ZRghBIj7Uh/ongNAxsddbh usr";
    description = ''
      A VirtualBox guest running NixOS.
    '';
    allowed-ssh-access = [
      copernicus.pubkey
      hammurabi.pubkey
      theseus.pubkey
    ];
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
