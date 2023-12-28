{ lib, config, pkgs, ...}:

{
  home.packages = with pkgs; [
    cmus # music player
    ncpamixer # audio mixer
    yt-dlp # youtube downloader
    tmux # (t)erminal (mu)ltiple(x)er
    elinks # tty web browser
    ledger # accounting
    neomutt # mail
    curl
    tree
    dig
    python3 # nice interactive calculator and shell
  ];
}
