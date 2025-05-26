{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tmux
    jq
    curl
    tree
    rsync
    man-pages
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
    fzy
    imagemagick
    unzip
  ];
}
