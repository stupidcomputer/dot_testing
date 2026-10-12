(require 'use-package)
(setq use-package-verbose t
      gc-cons-threshold (* 50 1024 1024))

(defvar on-phone-p
  (or (getenv "TERMUX_VERSION")
      (getenv "ANDROID_ROOT"))
  "non-nil in termux/android")

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
	org-log-redeadline 'time
	org-log-reschedule 'time
	org-agenda-ignore-properties '(stats)
	org-todo-keywords '((sequence "TODO(t!)" "PLANNING(p!)" "IN-PROGRESS(i@/!)"
				      "VERIFYING(v!)" "BLOCKED(b@)"  "|" "DONE(d!)"
				      "OBE(o@!)" "WONT-DO(w@/!)" "DUE-PASSED(a@!)" ))
        org-tags-exclude-from-inheritance '("project" "monolith")

	org-confirm-babel-evaluate nil
	org-element-use-cache t
	org-read-date-force-compatible-dates nil)
  :config
  (add-to-list 'org-modules 'org-habit)
  (define-key global-map "\C-cl" 'org-store-link)
  (define-key global-map "\C-ca" (lambda () (interactive) (org-agenda nil "a")))
  (define-key global-map "\C-cA" (lambda () (interactive) (org-agenda nil "w")))
  (define-key global-map "\C-c\C-a" (lambda () (interactive) (org-ql-view "Daily agenda")))
  (define-key global-map "\C-c\C-A" (lambda () (interactive) (org-ql-view "Weekly agenda")))
  (define-key global-map "\C-ch" (lambda () (interactive) (org-ql-view "Habits")))
  (define-key global-map "\C-cc" 'org-capture)
  (define-key global-map "\C-cL" 'org-capture)
  (define-key global-map "\C-cs" (lambda () (interactive) (org-agenda-schedule nil "+1d")))
  (define-key global-map "\C-cy" 'org-todo-yesterday)
  (define-key global-map "\C-cO" 'org-journal-open-current-journal-file)
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

  :bind
   (("C-c o" . (lambda () (interactive) (find-file "~/org/main.org")))
    ("M-x" . 'helm-M-x)
    (:map org-mode-map
	  ("<C-tab>" . u:helm-org-jump))))

(use-package org-drill :ensure t)
(use-package anki-editor
  :ensure t
  :config
  (setq anki-editor-create-decks t))
(use-package org-journal :ensure t)
(use-package evil-org
  :ensure t
  :config
  ;; this seems hacky but there doesn't seem to be a better solution
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (evil-org-set-key-theme '(navigation insert textobjects additional calendar)))
  (add-hook 'org-mode-hook (lambda () 
                           (unless noninteractive 
                             (evil-org-mode))))
  (add-hook 'org-mode-hook (lambda () (company-mode -1)))
(use-package gnuplot :ensure t)
(use-package org-contacts
  :ensure t
  :after org
  :custom (org-contacts-files '("~/org/contacts.org")))
(setq calendar-week-start-day 1)

;; org-clock status -> i3 statusbar
(defvar u:clock-status-file "~/.cache/emacs-clock-status"
  "file i3pystatus reads to display the current org-clock task")

(defvar u:clock-status-timer nil
  "timer that periodically refreshes u:clock-status-file when clocked in")

(defun u:clock-status-string ()
  "session/today/total minutes on the clocked-in task, plus its heading.
org-clock-sum skips the running CLOCK line, so the current session is
added to today and total by hand."
  (let* ((midnight (float-time (apply #'encode-time
					     (append '(0 0 0) (nthcdr 3 (decode-time))))))
	 (session (floor (float-time (time-since org-clock-start-time)) 60))
	 (since-midnight (floor (- (float-time) midnight) 60))
	 (sums (with-current-buffer (marker-buffer org-clock-hd-marker)
		 (org-with-wide-buffer
		  (goto-char org-clock-hd-marker)
		  (cons (org-clock-sum-current-item midnight)
			(org-clock-sum-current-item)))))
	 (today (+ (car sums) (min session since-midnight)))
	 (total (+ (cdr sums) session)))
    (format "%s/%s/%s (%s)"
	    (org-duration-from-minutes session)
	    (org-duration-from-minutes today)
	    (org-duration-from-minutes total)
	    org-clock-current-task)))

(defun u:write-clock-status ()
  "write the current clock status to u:clock-status-file"
  (with-temp-file u:clock-status-file
    (insert (if (org-clocking-p)
		(u:clock-status-string)
	      ""))))

(defun u:start-clock-status-timer ()
  "start refreshing the clock status file every 30 seconds"
  (u:write-clock-status)
  (unless u:clock-status-timer
    (setq u:clock-status-timer
	  (run-with-timer 30 30 #'u:write-clock-status))))

(defun u:stop-clock-status-timer ()
  "stop refreshing the timer; clear clock status file"
  (when u:clock-status-timer
    (cancel-timer u:clock-status-timer)
    (setq u:clock-status-timer nil))
  (u:write-clock-status))

(add-hook 'org-clock-in-hook #'u:start-clock-status-timer)
(add-hook 'org-clock-out-hook #'u:stop-clock-status-timer)
(add-hook 'org-clock-cancel-hook #'u:stop-clock-status-timer)
(add-hook 'org-clock-after-resume-hook #'u:start-clock-status-timer)

(setq-default indent-tabs-mode nil)

;; latex
(use-package auctex
  :defer t
  :ensure t)

;; pdf-tools
(use-package pdf-tools
  :ensure t
  :if (not on-phone-p)
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
  :config
  (add-to-list 'auto-mode-alist '("\\.ledger\\'" . ledger-mode)))

(use-package magit :ensure t)
(use-package helm
  :ensure t
  :config
  (helm-mode 1)
  (setq helm-M-x-fuzzy-match 1
	helm-input-idle-delay 0.01
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

;; eye-candy and aesthetics
(use-package gruvbox-theme :ensure t)
(setq custom-file "~/.emacs.d/custom.el"
      make-backup-files nil
      inhibit-splash-screen t
      custom-safe-themes t
      warning-minimum-level :error
      visible-bell t
      ring-bell-function 'ignore
      linum-format "%d"
      frame-title-format '("emacs(" mode-name ") - %b - %f"))
(menu-bar-mode -1)
(tool-bar-mode -1)
(add-to-list 'warning-suppress-types '(t))

(add-to-list 'default-frame-alist '(font . "Fantasque Sans Mono-13"))

;; prevent the simulated terminal bell from ringing
;; display line numbers in programming modes
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)
;; I don't want line numbers in org-mode, though
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode -1)))
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))
(defun u:disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'u:disable-scroll-bars)
(which-key-mode)

(let ((private-config "~/org/private.org"))
  (when (file-exists-p private-config)
    (org-babel-load-file private-config)))
