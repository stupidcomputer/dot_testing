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
  };
  phone = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILuVT5W3kzjzsuMIWk1oeGtL8jZGtAhRSx8dK8oBJQcG u0_a291";
    ip-addrs = {
      localnet = "192.168.1.203";
    };
  };
  aristotle = {
    pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTDyKneaM44I5to883ghEnnPonedCKDbCX+OnrQ9vO5 usr";
    wg-pubkey = "Sw2yyMhyS8GOCWm1VuGn3Y7cfx606dXOGK5mux8ckQU=";
    ip-addrs = {
      localnet = "192.168.1.202";
      wgnet = "10.100.0.3";
    };
  };
  netbox = {
    wg-privkey = ../secrets/netbox-wg-priv.age;
    wg-pubkey = "0fOqAfsYO4HvshMPnlkKL7Z1RChq98hjDr0Q8o7OJFE=";
    ip-addrs = {
      internet = "beepboop.systems";
      wgnet = "10.100.0.1";
    };
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
