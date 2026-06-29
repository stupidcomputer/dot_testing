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
	org-log-redeadline 'time
	org-log-reschedule 'time
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
  (define-key global-map "\C-ca" (lambda () (interactive) (org-agenda nil "a")))
  (define-key global-map "\C-cA" (lambda () (interactive) (org-agenda nil "w")))
  (define-key global-map "\C-c\C-a" (lambda () (interactive) (org-ql-view "Daily agenda")))
  (define-key global-map "\C-c\C-A" (lambda () (interactive) (org-ql-view "Weekly agenda")))
  (define-key global-map "\C-ch" (lambda () (interactive) (org-ql-view "Habits")))
  (define-key global-map "\C-cc" 'org-capture)
  (define-key global-map "\C-cc" 'org-capture)
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

  (defun u:helm-org-jump ()
    "Jump to an Org-mode heading or Babel source block in the current buffer."
    (interactive)
    (unless (derived-mode-p 'org-mode)
      (user-error "This function only works in Org-mode buffers."))
    (let* ((ast (org-element-parse-buffer))
           (candidates
            (org-element-map ast '(headline src-block)
              (lambda (el)
		(let* ((type (org-element-type el))
                       (pos (org-element-property :begin el))
                       (title (cond
                               ((eq type 'headline)
				(org-element-property :raw-value el))
                               ((eq type 'src-block)
				(let ((name (org-element-property :name el))
                                      (lang (org-element-property :language el)))
                                  (if name 
                                      (format "SRC: %s [%s]" name lang)
                                    (format "SRC: (%s block)" lang)))))))
                  (cons title pos))))))
      (helm :sources (helm-build-sync-source "Org Jump"
                       :candidates candidates
                       :action (lambda (candidate)
				 (goto-char candidate)
				 (org-show-entry)
				 (recenter)))
            :buffer "*helm org jump*")))

  :bind
   (("C-c o" . (lambda () (interactive) (find-file "~/org/main.org")))
    ("M-x" . 'helm-M-x)
    (:map org-mode-map
	  ("<C-tab>" . u:helm-org-jump))))

;; thanks: https://macowners.club/posts/org-capture-from-everywhere-macos/
(defun u:make-capture-frame ()
  "Create a new frame and run `org-capture'."
  (interactive)
  (make-frame '((name . "org-capture-frame")
                (top . 300)
                (left . 700)
                (width . 80)
                (height . 25)))
  (select-frame-by-name "org-capture-frame")
  (delete-other-windows)
  (cl-letf (((symbol-function 'switch-to-buffer-other-window)
	     (lambda (buf) (switch-to-buffer buf))))
    (org-capture)))

(defadvice org-capture-finalize
    (after delete-capture-frame activate)
  "Advise capture-finalize to close the frame."
  (if (equal "capture" (frame-parameter nil 'name))
      (delete-frame)))

(defadvice org-capture-destroy
    (after delete-capture-frame activate)
  "Advise capture-destroy to close the frame."
  (if (equal "capture" (frame-parameter nil 'name))
      (delete-frame)))

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

(defun u:write-clock-status ()
  "write the current clock status to u:clock-status-file"
  (with-temp-file u:clock-status-file
    (insert (if (org-clocking-p)
		(org-clock-get-clock-string)
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

;; elfeed
(use-package elfeed :ensure t)
(defun u:elfeed-download-with-ytdlp (&optional watch adb)
  "download the current elfeed entry with yt-dlp"
  (interactive "P")
  (let* ((entry (if (eq major-mode 'elfeed-show-mode)
		    elfeed-show-entry
		  (elfeed-search-selected :ignore-region)))
	 (url (elfeed-entry-link entry))
	 (outdir (expand-file-name "~/down/youtube"))
	 (template (concat outdir "/%(title)s.%(ext)s"))
	 (proc (start-process
		"yt-dlp" "*yt-dlp*"
		"yt-dlp"
		"--format" "bestvideo[height<=720]+bestaudio[abr<=120]/best[height<=720]"
		"--audio-quality" "5"
		"--merge-output-format" "mp4"
		"--newline" "--embed-metadata"
		"--print" "after_move:filepath"
		"-o" template
		url)))
    (unless (file-directory-p outdir)
      (make-directory outdir :parents))
    (message "downloading: %s" url)
    (when watch
      (set-process-filter
       proc
       (lambda (_proc output)
	 (with-current-buffer "*yt-dlp*"
	   (insert output))
	 (when (string-match "^\\/.*\\.mp4$" (string-trim output))
	   (start-process "mpv" "*mpv*" "mpv" (string-trim output))
	   (message "opening in mpv: %s" (string-trim output))))))
    (when adb
      (set-process-filter
       proc
       (lambda (_proc output)
	 (with-current-buffer "*yt-dlp*"
	   (insert output))
	 (when (string-match "^\\/.*\\.mp4$" (string-trim output))
	   (start-process "adb" "*adb-transfer*" "adb" "push" (string-trim output) "/storage/emulated/0/Movies/youtube-transfers")
	   (message "transfering via adb: %s" (string-trim output))))))
    (message "progress in *yt-dlp* buffer")))
	 

(define-key elfeed-show-mode-map (kbd "C-c d") #'u:elfeed-download-with-ytdlp)
(define-key elfeed-show-mode-map (kbd "C-c D") (lambda () (interactive) (u:elfeed-download-with-ytdlp t)))
(define-key elfeed-show-mode-map (kbd "C-c f") (lambda () (interactive) (u:elfeed-download-with-ytdlp nil t)))

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
;; make warnings not force the warning box open
(add-to-list 'warning-suppress-types '(t))
(setq warning-minimum-level :error)

(defun u:apply-system-fonts (&optional frame)
  "Apply fonts based on system name. Optional FRAME is passed by hooks."
  (let ((target-frame (or frame (selected-frame))))
    (with-selected-frame target-frame
      (set-frame-font "Fantasque Sans Mono-13" nil t)
      (cond
       ((string-equal (system-name) "copernicus")
        (set-face-attribute 'default nil :height 140))
       ((string-equal (system-name) "hammurabi")
        (set-face-attribute 'default nil :height 110))
       (t
        (set-face-attribute 'default nil :height 130))))))

(u:apply-system-fonts)
(add-hook 'after-make-frame-functions #'u:apply-system-fonts)
(advice-add 'load-theme :after #'u:apply-system-fonts)

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
(setq frame-title-format '("emacs(" mode-name ") - %b - %f"))

;; custom commands
(defun u:init:edit ()
  (interactive)
  (find-file "~/.emacs.d/init.el"))
(defun u:init:eval ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))

(let ((private-config "~/org/private.org"))
  (when (file-exists-p private-config)
    (org-babel-load-file private-config)))
