{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    kdePackages.kmail
    kdePackages.kgpg
    libsForQt5.kaccounts-integration
    libsForQt5.kaccounts-providers
    libsForQt5.krunner
    libsForQt5.kalarm
  ];

  programs.kdeconnect.enable = true;
  services = {
    displayManager.sddm.enable = true;
    xserver.desktopManager.plasma5.enable = true;
  };
}
