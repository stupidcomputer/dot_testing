{
  router = {
    ip-addrs = {
      localnet = "192.168.1.1";
    };
  };
  copernicus = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBGh1FHPneg7PCDkhMs2BCJPTIRVJkRTKpOj1w02ydD usr";
    wg-privkey = ../secrets/copernicus-wg-priv.age;
    wg-pubkey = "JlH1X4KRT+B8Uau+qTLtBqyapkbGClIj1db7znU77kc=";
    ip-addrs = {
      localnet = "192.168.1.201";
      wgnet = "10.100.0.2";
    };
    syncthing-id = "M7DSXSL-FRPZQ2Z-32XEIE2-T4XPU76-OL4AMXS-UPM3R2L-WRIHWUO-2RNMEAQ";
    description = ''
      The main desktop PC.
    '';
  };
  phone = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5f9Cg3m/cp9nSb+lfEx/8a/p2xi90s8hZnSwT6NDEw u0_a336";
    ip-addrs = {
      localnet = "192.168.1.203";
    };
    syncthing-id = "WR2IVGD-7XKTMTR-FDI74B4-PLDNIXR-TV5OEAJ-ESB75H7-RADC4NR-DGSWDAU";
    description = ''
      A Pixel 8a running termux and some other things.
    '';
  };
  aristotle = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTDyKneaM44I5to883ghEnnPonedCKDbCX+OnrQ9vO5 usr";
    wg-pubkey = "Sw2yyMhyS8GOCWm1VuGn3Y7cfx606dXOGK5mux8ckQU=";
    ip-addrs = {
      localnet = "192.168.1.202";
      wgnet = "10.100.0.3";
    };
    description = ''
      A Lenovo Thinkpad Yoga 260. Power supply seems to have died.
    '';
  };
  netbox = {
    wg-privkey = ../secrets/netbox-wg-priv.age;
    wg-pubkey = "0fOqAfsYO4HvshMPnlkKL7Z1RChq98hjDr0Q8o7OJFE=";
    ip-addrs = {
      internet = "beepboop.systems";
      wgnet = "10.100.0.1";
    };
    syncthing-id = "O7K4VBQ-N5ENCDW-YMGMQP7-MADCKHK-T5OBSNH-4B3BE7W-Z3DK2G5-DH22NQQ";
    description = ''
      Just a tiny VPS, nothing much.
    '';
  };
  plato = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIABAuisY7QufTrcPkBvHcPTtCLg4/SY+r4nCh3fqdua7 usr";
    syncthing-id = "A6LQULQ-AVUHHN5-EAT3JWW-O6VZATV-LAHQB6X-RLEGWMD-NQJKT6L-WUAOJAZ";
    description = ''
      A Lenovo Thinkpad X230.
    '';
  };
  hammurabi = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaUHLYuEgmNWQTQUB9nZA3L2QCOaQyqrcRv+8xGkdAM usr";
    syncthing-id = "MTWVSQK-A7BYY7G-I35WEPP-O7MFMTD-CB4CIEN-7ZBUJ5C-LVGMPQ3-JACXNQK";
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
