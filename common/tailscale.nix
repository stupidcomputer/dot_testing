{
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # sshd and nginx bind to the tailnet address, which may not exist yet at boot
  boot.kernel.sysctl."net.ipv4.ip_nonlocal_bind" = 1;
}
