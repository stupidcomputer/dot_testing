(require 'use-package)
(setq use-package-verbose t
      gc-cons-threshold (* 50 1024 1024))

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil
	evil-undo-system 'undo-redo
	evil-want-C-w-delete nil
	evil-want-C-w-in-emacs-state t)
  :config
  (evil-mode 1)
  (define-key evil-motion-state-map (kbd ":") 'evil-ex)
  (define-key evil-motion-state-map (kbd ";") 'evil-ex))

;; evil-collection
(use-package evil-collection
  :ensure t
  :config
  (evil-collection-init))

;; htmlize
(use-package htmlize :ensure t)

;; vterm
(use-package vterm :ensure t)
(defun u:new-frame-with-vterm ()
  "Create a new frame and immediately open vterm in it."
  (interactive)
  (require 'vterm)
  (let ((new-frame (make-frame '((explicit-vterm . t)))))
    (select-frame new-frame)
    (delete-other-windows)
    ;; Force vterm to take full window
    (let ((default-directory "~"))
      (let ((vterm-buffer (vterm (format "vterm (emacs)" (frame-parameter new-frame 'name)))))
	(switch-to-buffer vterm-buffer)
	(delete-other-windows)))))

(defun u:vterm-run-command (command)
  "Execute string COMMAND in a new vterm buffer."
  (interactive "sCommand: ")
  (let ((buffer (vterm (concat "*" command "*"))))
    (with-current-buffer buffer
      (vterm-send-string command)
      (vterm-send-return))))

;; lsps and friends
(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0.1
	company-minimum-prefix-length 1)
  (global-company-mode t))

(use-package lsp-mode
  :ensure t
  :hook ((python-mode . lsp)
	 (nix-mode . lsp)
	 (tex-mode . lsp))
  :commands (lsp lsp-deferred))

;; org-mode
(use-package org
  :ensure t
  :init
  (setq org-directory "~/org"
	org-default-notes-file (concat org-directory "/inbox.org")
	org-journal-dir "~/org/journal"
	org-treat-insert-todo-heading-as-state-change t
	org-log-into-drawer t
	org-agenda-span 14
	org-agenda-sticky t
	org-agenda-show-future-repeats 'next
	org-agenda-dim-blocked-tasks nil
	org-agenda-inhibit-startup t
	org-agenda-ignore-properties '(stats)
	org-todo-keywords '((sequence "TODO(t!)" "PLANNING(p!)" "IN-PROGRESS(i@/!)"
				      "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)"
				      "OBE(o@!)" "WONT-DO(w@/!)" "DUE-PASSED(a@!)" ))
	org-confirm-babel-evaluate nil
	org-element-use-cache t
	org-read-date-force-compatible-dates nil)
  :config
  (add-to-list 'org-modules 'org-habit)
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" 'org-agenda)
  (define-key global-map "\C-cc" 'org-capture)
  (define-key global-map "\C-cc" 'org-capture)
  (define-key global-map "\C-cs" 'org-todo-yesterday)
  (define-key global-map "\C-cS" (lambda () (interactive) (org-agenda-schedule nil "+1d")))
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (gnuplot . t)
     (python . t)))
  ;; org-agenda doesn't show that annoying dialog
  (custom-set-variables '(safe-local-variable-values '((type . org))))
  ;; Don't show line numbers, wrap lines
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)
			     (setq truncate-lines t)
			     (company-mode -1)))
  ;; see https://emacs.stackexchange.com/questions/13360/org-habit-graph-on-todo-list-agenda-view
  ;; show consistency graphs for org-habits
  (defun u:org-agenda-mark-habits ()
      "Mark all habits in current agenda for graph display."
        (let ((cursor (point))
                item data) 
	    (while (setq cursor (next-single-property-change cursor 'org-marker))
                (setq item (get-text-property cursor 'org-marker))
		  (when (and item (org-is-habit-p item)) 
		      (with-current-buffer (marker-buffer item)
			  (setq data (org-habit-parse-todo item))) 
		        (put-text-property cursor
					     (next-single-property-change cursor 'org-marker)
					       'org-habit-p data)))))

  (advice-add #'org-agenda-finalize :before #'u:org-agenda-mark-habits)
  (add-hook 'org-mode-hook 'visual-line-mode)

  (defun u:helm-org-jump ()
    "Jump to an Org-mode heading in the current buffer using Helm."
    (interactive)
    (unless (derived-mode-p 'org-mode)
      (user-error "This function only works in Org-mode buffers."))
    (let ((candidates (org-map-entries
                       (lambda ()
			 (let ((hl-title (org-get-heading t t t t)))
                           (cons hl-title (point)))))))
      (helm :sources (helm-build-sync-source "Org Headings"
                       :candidates candidates
                       :action (lambda (candidate)
				 (goto-char candidate)
				 (org-show-entry)
				 (recenter)))
            :buffer "*helm org jump*")))
  
  :bind
   (("C-c o" . (lambda () (interactive) (find-file "~/org/main.org")))
    (:map org-mode-map ("<C-tab>" . u:helm-org-jump))))

(use-package org-drill :ensure t)
(use-package org-journal :ensure t)
(use-package evil-org
  :ensure t
  :config
  ;; this seems hacky but there doesn't seem to be a better solution
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar)))
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'org-mode-hook (lambda () (company-mode -1)))
(use-package gnuplot :ensure t)
(use-package org-contacts
  :ensure t
  :after org
  :custom (org-contacts-files '("~/org/contacts.org")))
(setq calendar-week-start-day 1)

;; elfeed
(use-package elfeed :ensure t)

;; latex
(use-package auctex
  :defer t
  :ensure t)

;; pdf-tools
(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))

(use-package latex-preview-pane
  :defer t
  :ensure t
  :config
  (latex-preview-pane-enable))

;; lang-specific mappings
(use-package nix-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode)))

(use-package python-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode)))

(use-package ledger-mode
  :ensure t
  :init
  (setq ledger-binary-path "hledger"
	ledger-mode-should-check-version nil
	ledger-report-links-in-register nil
	ledger-report-auto-width nil
	ledger-default-date-format "%Y-%m-%d")
  (defun u:start-hledger-web-interface ()
    "Start the hledger web interface in a vterm."
    (interactive)
    (u:vterm-run-command "hledger-web -f /home/usr/org/ledger/main.ledger --serve"))
  :config
  (add-to-list 'auto-mode-alist '("\\.ledger\\'" . ledger-mode))
  :bind
  (:map ledger-mode-map
	("C-c h" . u:start-hledger-web-interface)))

(use-package magit :ensure t)
(use-package helm
  :ensure t
  :config
  (helm-mode 1)
  (setq helm-M-x-fuzzy-match 1
	helm-buffers-fuzzy-matching 1)
  (defun u:helm-multi-configs ()
    "Bring up a Helm menu for important files"
    (interactive)
    (let ((config-dirs '("~/org/" 
			 "~/dots/")))
      (helm :sources (helm-build-sync-source "Multi-Repo Configs"
                       :candidates (lambda () 
                                     (mapcan (lambda (dir) 
                                               (directory-files-recursively dir "")) 
                                             config-dirs))
                       :fuzzy-match t
                       :action (helm-make-actions
				"Open file" #'find-file
				"Open in other window" #'find-file-other-window))
            :buffer "*helm-multi-configs*")))
  :bind
  (("C-<SPC>" . helm-buffers-list)
   ("M-<SPC>" . u:helm-multi-configs)
   ("C-x C-f" . helm-find-files)))

(use-package projectile
  :ensure t
  :init
  (setq projectile-project-search-path '("~/git/" "~/dots/"))
  :config
  (global-set-key (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1))

(use-package helm-projectile
  :ensure t
  :config
  (define-key projectile-mode-map (kbd "C-c p f") 'helm-projectile-find-file)
  (define-key projectile-mode-map (kbd "C-c p p") 'helm-projectile-switch-project))

;; eye-candy and aesthetics
(use-package gruvbox-theme :ensure t)
(setq custom-file "~/.emacs.d/custom.el")
(setq make-backup-files nil)
(setq inhibit-splash-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(setq custom-safe-themes t)
(load-theme 'gruvbox)
;; make warnings not force the warning box open
(add-to-list 'warning-suppress-types '(t))
(setq warning-minimum-level :error)

(add-to-list 'default-frame-alist '(font . "Fantasque Sans Mono-13"))
(set-frame-font "Fantasque Sans Mono" nil t)
(cond
 ((string-equal (system-name) "copernicus")
  (set-face-attribute 'default nil :height 100))
 ((string-equal (system-name) "hammurabi")
  (set-face-attribute 'default nil :height 110))
 (t
  (set-face-attribute 'default nil :height 130)))
;; prevent the simulated terminal bell from ringing
(setq visible-bell t)
(setq ring-bell-function 'ignore)
;; display line numbers in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)
;; I don't want line numbers in org-mode, though
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
(setq linum-format "%d")
(defun u:disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'u:disable-scroll-bars)
(which-key-mode)

;; custom commands
(defun u:init:edit ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(defun u:init:eval ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))

;; load private additions in org directory
;; (but if we fail -- it's no problem; that's
;; what all the t symbols are for)
(load "~/org/private.el" t t t)
