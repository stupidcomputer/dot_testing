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

;; htmlize
(use-package htmlize :ensure t)

;; org-mode
(use-package org :ensure t)
(use-package org-drill :ensure t)
(use-package org-journal :ensure t)
(use-package evil-org :ensure t)
(use-package gnuplot :ensure t)
(use-package org-ql :ensure t)
(use-package ox-json :ensure t)
(use-package org-contacts
  :ensure t
  :after org
  :custom (org-contacts-files '("~/org/contacts.org")))
(require 'org)
(require 'org-journal)
(require 'ox-json)
; see https://emacs.stackexchange.com/questions/13360/org-habit-graph-on-todo-list-agenda-view
(defvar u:org-habit-show-graphs-everywhere nil
  "If non-nil, show habit graphs in all types of agenda buffers.

Normally, habits display consistency graphs only in
\"agenda\"-type agenda buffers, not in other types of agenda
buffers.  Set this variable to any non-nil variable to show
consistency graphs in all Org mode agendas.")

(defun u:org-agenda-mark-habits ()
  "Mark all habits in current agenda for graph display.

This function enforces `u:org-habit-show-graphs-everywhere' by
marking all habits in the current agenda as such.  When run just
before `org-agenda-finalize' (such as by advice; unfortunately,
`org-agenda-finalize-hook' is run too late), this has the effect
of displaying consistency graphs for these habits.

When `u:org-habit-show-graphs-everywhere' is nil, this function
has no effect."
  (when (and u:org-habit-show-graphs-everywhere
         (not (get-text-property (point) 'org-series)))
    (let ((cursor (point))
          item data) 
      (while (setq cursor (next-single-property-change cursor 'org-marker))
        (setq item (get-text-property cursor 'org-marker))
        (when (and item (org-is-habit-p item)) 
          (with-current-buffer (marker-buffer item)
            (setq data (org-habit-parse-todo item))) 
          (put-text-property cursor
                             (next-single-property-change cursor 'org-marker)
                             'org-habit-p data))))))

(advice-add #'org-agenda-finalize :before #'u:org-agenda-mark-habits)
(setq u:org-habit-show-graphs-everywhere 1)
(setq org-directory "~/org")
(setq org-default-notes-file (concat org-directory "/inbox.org"))
(setq org-agenda-files '("~/org/agenda.org" "~/org/body.org" "~/org/inbox.org" "~/org/main.org" "~/org/pco.org" "~/org/tfb.org" "~/org/school-calendar.org"))
(setq org-journal-dir "~/org/journal")
(setq calendar-week-start-day 1)
(setq org-treat-insert-todo-heading-as-state-change t)
(setq org-log-into-drawer t)
(setq org-agenda-span 14)
(setq org-agenda-sticky t)
(setq org-agenda-show-future-repeats 'next)
(setq org-read-date-force-compatible-dates nil)
(setq org-agenda-custom-commands
      '(("p" "Generate PDF agenda page" agenda ""
         ((ps-number-of-columns 2)
          (ps-landscape-mode t)
          (org-agenda-prefix-format " [ ] ")
          (org-agenda-with-colors nil)
          (org-agenda-remove-tags t))
         ("agenda.ps"))
        ("h" "Habits" tags-todo "STYLE=\"habit\"")))
(add-to-list 'org-modules 'org-habit t)
;; define some sane maps
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(define-key global-map "\C-cc" 'org-capture)
(defun u:org:edit-main ()
  (interactive)
  (find-file "~/org/main.org"))
(define-key global-map "\C-co" 'u:org:edit-main)
(setq org-todo-keywords
      '((sequence "TODO(t!)" "PLANNING(p!)" "IN-PROGRESS(i@/!)" "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)" "OBE(o@!)" "WONT-DO(w@/!)" "DUE-PASSED(a@!)" )))
;; make executing bash blocks work
(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
    'org-babel-load-languages
        '(
            (shell . t)
	    (gnuplot . t)
	    (python . t)
        )
    )
;; org-agenda doesn't show that annoying dialog
(custom-set-variables
 '(safe-local-variable-values '((type . org))))
;; evil-org-mode
(require 'evil-org)
(add-hook 'org-mode-hook 'evil-org-mode)
(evil-org-set-key-theme '(navigation insert textobjects additional calendar))
(require 'evil-org-agenda)
(evil-org-agenda-set-keys)

;; elfeed
(use-package elfeed :ensure t)
(require 'elfeed)

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
;; plato and aristotle have low-dpi displays, so we need to
;; ;reduce font size accordingly
(set-frame-font "Fantasque Sans Mono" nil t)
(cond
 ((string-equal (system-name) "plato")
  (set-face-attribute 'default nil :height 100))
 ((string-equal (system-name) "copernicus")
  (set-face-attribute 'default nil :height 100))
 (t
  (set-face-attribute 'default nil :height 130)))
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

;; load private additions in org directory
;; (but if we fail -- it's no problem; that's
;; what all the t symbols are for)
(load "~/org/private.el" t t t)
