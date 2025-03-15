(require 'package)
(add-to-list 'package-archives
		'("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; use-package boilerplate
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-verbose t)

;; evil-mode
(setq evil-want-keybinding nil)
(setq evil-want-C-w-delete nil evil-want-C-w-in-emacs-state t) ;; make the C-W vim window movement bindings work
(use-package evil :ensure t)
(require 'evil)
(evil-mode 1)
(with-eval-after-load 'evil-maps ;; make evil trigger ex mode on ; and :
  (define-key evil-motion-state-map (kbd ":") 'evil-ex)
  (define-key evil-motion-state-map (kbd ";") 'evil-ex))
(setq evil-undo-system 'undo-redo)

;; evil-collection
(use-package evil-collection :ensure t)
(require 'evil-collection)
(evil-collection-init)

;; org-mode
(use-package org :ensure t)
(use-package org-drill :ensure t)
(use-package org-journal :ensure t)
(use-package gnuplot :ensure t)
(require 'org)
(require 'org-journal)
(setq org-directory "~/org")
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(setq org-agenda-files (directory-files-recursively "~/org/" "\\.org$"))
(setq org-journal-dir "~/org/journal")
(setq calendar-week-start-day 1)
;; define some sane maps
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)
(defun u:org:edit-main ()
  (interactive)
  (find-file "~/org/main.org"))
(define-key global-map "\C-co" 'u:org:edit-main)
(setq org-todo-keywords
      '((sequence "TODO(t)" "PLANNING(p)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" "DUE-PASSED(a@!)" )))
;; make executing bash blocks work
(org-babel-do-load-languages
    'org-babel-load-languages
        '(
            (shell . t)
	    (gnuplot . t)
        )
    )

;; latex
(use-package auctex
  :defer t
  :ensure t)

;; pdf-tools
(use-package pdf-tools :ensure t)
(pdf-tools-install)

(use-package latex-preview-pane
  :defer t
  :ensure t)
(latex-preview-pane-enable)

;; lang-specific mappings
(use-package nix-mode :ensure t)
(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

(use-package python-mode :ensure t)
(require 'python-mode)
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))

;; eye-candy and aesthetics
(use-package gruvbox-theme :ensure t)
(setq custom-file "~/.emacs.d/custom.el")
(setq make-backup-files nil)
(setq inhibit-splash-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)
(setq custom-safe-themes t)
(load-theme 'gruvbox)
(set-frame-font "Fantasque Sans Mono 14" nil t)
;; prevent the simulated terminal bell from ringing
(setq visible-bell t)
(setq ring-bell-function 'ignore)
;; display line numbers in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)
(setq linum-format "%d")

;; custom commands
(defun u:init:edit ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(defun u:init:eval ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))
(defun terminal ()
  (interactive)
  (term "/run/current-system/sw/bin/bash"))
