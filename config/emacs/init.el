;; rndusr's init.el

;; configure the package manager
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
;; (package-refresh-contents)

; disable annoying ui features
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(defun keymap-symbol (keymap)
  "Return the symbol to which KEYMAP is bound, or nil if no such symbol exists."
  (catch 'gotit
    (mapatoms (lambda (sym)
                (and (boundp sym)
                     (eq (symbol-value sym) keymap)
                     (not (eq sym 'keymap))
                     (throw 'gotit sym))))))

(defun get-local-map () (interactive) (message "Current mapping: %S" (keymap-symbol (current-local-map))))

;; download packages
(unless (package-installed-p 'evil)
  (package-install 'evil))
(unless (package-installed-p 'org)
  (package-install 'org))
(unless (package-installed-p 'org-drill)
  (package-install 'org-drill))
(unless (package-installed-p 'accent)
  (package-install 'accent))
(unless (package-installed-p 'elfeed)
  (package-install 'elfeed))
(unless (package-installed-p 'hackernews)
  (package-install 'hackernews))
(unless (package-installed-p 'emms)
  (package-install 'emms))
(unless (package-installed-p 'company)
  (package-install 'company))
(unless (package-installed-p 'anaconda-mode)
  (package-install 'anaconda-mode))
(unless (package-installed-p 'company-anaconda)
  (package-install 'company-anaconda))

;; activate packages
(require 'evil)
(require 'org)
(require 'org-drill)
(require 'accent)
(require 'elfeed)
(require 'hackernews)
(require 'emms)
(require 'company)
(require 'anaconda-mode)
(require 'company-anaconda)

;; configure packages

;; - evil-mode
(evil-set-initial-state 'elfeed-search 'emacs)

;; swap ; and :
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd ";") 'evil-ex))

(evil-set-leader 'normal (kbd "<SPC>"))
(defun configreload () (interactive) (load "~/.config/emacs/init.el"))

(evil-define-key 'normal 'global (kbd "<leader>rr") 'configreload)
(evil-ex-define-cmd "get-current-mapping" 'get-local-map)
(evil-mode 1)

;; company-mode
(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 1
      company-tooltip-idle-delay 10
      company-require-match nil
      company-frontends
      '(company-pseudo-tooltip-unless-just-one-frontend-with-delay
        company-preview-frontend
        company-echo-metadata-frontend)
      company-backends '(company-capf))
(setq company-tooltip-align-annotations t)
(add-to-list 'company-backends 'company-anaconda)
(add-hook 'python-mode-hook 'anaconda-mode)



;; org
(setq org-agenda-files '("~/org"))
(setq calendar-week-start-day 1)
(setq org-todo-keywords '((type "MEETING" "CLASS" "TODO" "REHERSAL" "|" "DONE")))
(setq org-return-follows-link t)

;; emms
(require 'emms-player-simple)
(require 'emms-source-file)
(require 'emms-source-playlist)

(emms-all)
(emms-default-players)

(evil-define-key 'normal 'emms-browser-mode-map (kbd "z") 'emms-browser-expand-one-level)
(evil-define-key 'normal 'emms-browser-mode-map (kbd "RET") 'emms-browser-add-tracks-and-play)
(evil-define-key 'normal 'emms-browser-mode-map (kbd "e") 'emms-browser-add-tracks)

;; - elfeed
(global-set-key (kbd "C-x w") 'elfeed)

(setq elfeed-feeds
      '("http://nullprogram.com/feed/"
	"https://drewdevault.com/blog/index.xml"
	"https://digitallibrary.un.org/rss?ln=en&p=libya&rg=50&c=Resource%20Type&c=UN%20Bodies"
        "https://planet.emacslife.com/atom.xml"))

;; - accent.el
(evil-define-key 'insert 'global (kbd "C-k") 'accent-menu)



;; fonts
(set-face-attribute 'default nil
		    :font "Fantasque Sans Mono 10"
		    :foreground "white" :background "gray8")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(company-anaconda anaconda-mode company emms bongo accent org-drill hackernews evil elfeed)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
