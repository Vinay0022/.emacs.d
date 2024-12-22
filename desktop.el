(defun efs/exwm-update-class()
  (exwm-workspace-rename-buffer exwm-class-name))
  (use-package exwm

  :ensure t
  :config
  (setq exwm-workspace-number 5)
;; When window "class" updates, use it to set the buffer name
  (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)

  ;; Rebind CapsLock to Ctrl
;;  (start-process-shell-command "xmodmap" nil "xmodmap ~/.emacs.d/exwm/Xmodmap")

  ;; Set the screen resolution (update this to be the correct resolution for your screen!)
  (require 'exwm-randr)
  (setq exwm-systemtray-height 26)
  (exwm-randr-mode 1)
  ;; (start-process-shell-command "xrandr" nil "xrandr --output Virtual-1 --primary --mode 2048x1152 --pos 0x0 --rotate normal")

  ;; Load the system tray before exwm-init
  (require 'exwm-systemtray)
  (exwm-systemtray-mode 1)

  ;; These keys should always pass through to Emacs
  (setq exwm-input-prefix-keys
    '(?\C-x
      ?\C-u
      ?\C-h
      ?\M-x
      ?\M-`
      ?\M-&
      ?\M-:
      ?\C-\M-j  ;; Buffer list
      ?\C-\ ))  ;; Ctrl+Space

  ;; Ctrl+Q will enable the next key to be sent directly
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; Set up global key bindings.  These always work, no matter the input state!
  ;; Keep in mind that changing this list after EXWM initializes has no effect.
  (setq exwm-input-global-keys
	`(
	  ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
	  ([?\s-r] . exwm-reset)

	  ;; Move between windows
	  ([s-left] . windmove-left)
	  ([s-right] . windmove-right)
	  ([s-up] . windmove-up)
	  ([s-down] . windmove-down)

	  ;; Launch applications via shell command
	  ([?\s-&] . (lambda (command)
		       (interactive (list (read-shell-command "$ ")))
		       (start-process-shell-command command nil command)))

	  ;; Switch workspace
	  ([?\s-w] . exwm-workspace-switch)
	  ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

	  ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
	  ,@(mapcar (lambda (i)
		      `(,(kbd (format "s-%d" i)) .
			(lambda ()
			  (interactive)
			  (exwm-workspace-switch-create ,i))))
		    (number-sequence 0 9))))

  (exwm-enable))

(use-package desktop-environment
      :ensure t
      :after exwm
      :config (desktop-environment-mode)
      :custom
      (desktop-environment-brightness-small-increment "2%+")
      (desktop-environment-brightness-small-decrement "2%-")
      (desktop-environment-brightness-normal-increment "5%+")
      (desktop-environment-brightness-normal-decrement "5%-"))

  (defun efs/run-in-background (command)
    (let ((command-parts (split-string command "[ ]+")))
      (apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))


;; Launch apps that will run in the background
(efs/run-in-background "pasystray")
(efs/run-in-background "blueman-applet")
(efs/run-in-background "nm-applet")
(efs/run-in-background "dunst")

(defun efs/disable-desktop-notifications ()
  (interactive)
  (start-process-shell-command "dunstctl" nil "dunstctl set-paused true"))

(defun efs/enable-desktop-notifications ()
  (interactive)
  (start-process-shell-command "dunstctl" nil "dunstctl set-paused false"))

(defun efs/dunstctl (command)
(start-process-shell-command "dunstctl" nil (concat "dunstctl " command)))

(exwm-input-set-key (kbd "s-n") (lambda () (interactive) (efs/dunstctl "history-pop")))
