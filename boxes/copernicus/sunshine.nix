{ pkgs, lib, ... }:
{
  services.sunshine = {
    package = pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    };
    enable = true;
    openFirewall = true;
    autoStart = true;
    capSysAdmin = true;
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 47984 47989 47990 48010 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      #{ from = 8000; to = 8010; }
    ];
  };

  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "usr";
    };
    defaultSession = "none+i3";
    ly.enable = lib.mkForce false;
  };

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
  };

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';
  users.users.usr.extraGroups = [ "input" ];
}
