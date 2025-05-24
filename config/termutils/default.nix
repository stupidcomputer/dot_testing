{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tmux
    jq
    peaclock
    usbutils
    pciutils
    unzip
    mdadm
    cryptsetup
    ranger
    dig
    nmap
    yt-dlp
    ffmpeg
    qpdf
    poppler_utils
    kjv
  ];
}
