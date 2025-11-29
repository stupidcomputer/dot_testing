{ pkgs, ...}:
{
#  environment.systemPackages = with pkgs; [
#    emacsPackages.pdf-tools
#
#    # for pdf export of org-agenda
#    ghostscript
#
#    # plot stuff in org-mode
#    gnuplot
#
#    # import ical files from other sources
#    ical2orgpy
#
#    # latex support
#    texliveFull
#  ];

  system.userActivationScripts.copyEmacsConfiguration = {
    text = ''
      mkdir -p /home/usr/.emacs.d
      ${pkgs.coreutils}/bin/ln -sf /home/usr/dots/config/emacs/init.el /home/usr/.emacs.d/init.el
    '';
    deps = [];
  };
}
