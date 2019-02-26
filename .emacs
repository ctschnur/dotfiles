(package-initialize)

(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(custom-safe-themes
   (quote
    ("43c1a8090ed19ab3c0b1490ce412f78f157d69a29828aa977dae941b994b4147" default)))
 '(org-startup-truncated t)
 '(package-selected-packages
   (quote
    (neotree dired-sidebar py-autopep8 flycheck elpy material-theme multi-term centered-window org-ref org-download transpose-frame evil-collection evil org-pdfview pdf-tools auctex-lua auctex-latexmk auctex yasnippet linum-relative exec-path-from-shell projectile desktop+))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(fringe ((t (:background "#263238")))))

;; ---- use-package initialization, make sure use-package.el is cloned into ~/.emacs.d
;; This is only needed once, near the top of the file
(eval-when-compile
  ;; Following line is not needed if use-package.el is in ~/.emacs.d
  ;; (add-to-list 'load-path "<path where use-package is installed>")
  (require 'use-package))

;; use-package
(setq use-package-always-ensure t)


" ---- BEGIN general emacs settings "

(defun kill-non-visible-buffers ()
  "Kill all buffers not currently shown in a window somewhere."
  (interactive)
  (dolist (buf  (buffer-list))
    (unless (get-buffer-window buf 'visible) (kill-buffer buf))))

(defun kill-all-but-shown ()
  (interactive)
  (delete-other-frames)
  (kill-non-visible-buffers))

(require 'cl)
(require 'ox)

(defun kill-other-buffers ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer 
          (delq (current-buffer) 
                (remove-if-not 'buffer-file-name (buffer-list)))))

(setq ring-bell-function 'ignore)

(global-auto-revert-mode 1)

(add-hook 'prog-mode-hook 'visual-line-mode)

;; googling quickly
(defun prelude-google ()
  "Googles a query or region if any."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (if mark-active
        (buffer-substring (region-beginning) (region-end))
      (read-string "Google: ")))))

 (global-set-key (kbd "C-x g") 'prelude-google)

(tool-bar-mode -1)

(savehist-mode 1)

;; disable startup screen when opening a file
(defun my-inhibit-startup-screen-always ()
  ;; Startup screen inhibitor for `command-line-functions`.
  ;; Inhibits startup screen on the first unrecognised option.
  (ignore (setq inhibit-startup-screen t)))

(add-hook 'command-line-functions #'my-inhibit-startup-screen-always)

;; insert current buffers file path into minibuffer 
(define-key minibuffer-local-map [f3]
  (lambda () (interactive) 
     (insert (buffer-name (window-buffer (minibuffer-selected-window))))))

" ---- END general emacs settings "


" --- BEGIN packages + package-specific settings "

(setq my-cloud-dir "~/Dropbox/")

(let ((default-directory my-cloud-dir))
  (setq my-cloud-linkedapps-dir (expand-file-name "1LinkedApps/")))

(let ((default-directory my-cloud-linkedapps-dir))
  (setq my-cloud-emacs-dir (expand-file-name "emacs/")))

(let ((default-directory my-cloud-emacs-dir))
  (setq my-cloud-emacs-desktops-dir (expand-file-name "desktops/")))

(use-package desktop+
  :config
  ;; the given directory should be a link to dropbox
  ;; with a central managed git repository

  (setq emacsd-desktops-dir "~/.emacs.d/desktops/")
  (if (file-directory-p emacsd-desktops-dir)
      (progn (message (format "%s exists" emacsd-desktops-dir)))
    (progn (message (format "%s doesn't exit, linking it to %s" emacsd-desktops-dir my-cloud-emacs-desktops-dir))
	   (shell-command-to-string
	    (format "ln -s %s %s" my-cloud-emacs-desktops-dir (file-name-directory (directory-file-name emacsd-desktops-dir))))))

  (setq desktop+-base-dir emacsd-desktops-dir)

  ;; ;; BEGIN remember last session 
  ;; (defun read-lines (filePath)
  ;;   "Return a list of lines of a file at filePath."
  ;;   (with-temp-buffer
  ;;     (insert-file-contents filePath)
  ;;     (split-string (buffer-string) "\n" t)))
  ;; 
  ;; (setq last-session-file-name ".lastsessionname")
  ;; 
  ;; (defun load-last-session ()
  ;;   (interactive)
  ;;   (desktop+-load (nth 0 (read-lines last-session-file-name)))
  ;;   )

  ;; ;; (add-hook 'kill-emacs-hook
  ;; ;; 	  '(lambda ()
  ;; ;; 	     (write-region (file-name-nondirectory (directory-file-name desktop-dirname)) nil last-session-file-name))
  ;; ;; 	  )
  ;; ;; 
  ;; ;; (global-set-key (kbd "C-c C-l C-l") 'load-last-session)
  ;; ;; ;; END remember last session 

  )

(use-package transpose-frame)

(use-package winner
  :config
    (when (fboundp 'winner-mode)
      (winner-mode 1))
    (define-key winner-mode-map (kbd "C-c h") 'winner-undo)
    (define-key winner-mode-map (kbd "C-c l") 'winner-redo)
    )

(use-package org
  :config
  (setq org-export-async-debug nil)

    (add-hook 'org-mode-hook 'visual-line-mode)

    (defun my-org-latex-pdf-export-async ()
    	(interactive)
    	    (org-latex-export-to-pdf t))

    ;; (global-set-key (kbd "C-c i")
    ;; 	     'my-org-latex-pdf-export-async)

    ;; (global-set-key (kbd "C-c t i")
    ;; 	     'toggle-pdf-export-on-save)

    ;; (defun toggle-pdf-export-on-save ()
    ;; "Enable or disable export latex+pdf when saving current buffer."
    ;; 	(interactive)
    ;; 	(when (not (eq major-mode 'org-mode))
    ;; 	    (error "Not an org-mode file!"))
    ;; 	(if (memq 'my-org-latex-pdf-export-async after-save-hook)
    ;; 	    (progn (remove-hook 'after-save-hook  'my-org-latex-pdf-export-async)
    ;; 		    (message "Disabled org pdf export on save"))
    ;; 	    (add-hook 'after-save-hook 'my-org-latex-pdf-export-async)
    ;; 	    (set-buffer-modified-p t)
    ;; 	    (message "Enabled org pdf export on save")))

    ;; (defun my-org-latex-export-to-latex ()
    ;;   (interactive)
    ;;   (org-latex-export-to-latex nil nil nil t nil)
    ;;   )

    ;; (defun toggle-org-latex-export-to-latex-on-save ()
    ;; 	(interactive)
    ;; 	(when (not (eq major-mode 'org-mode))
    ;; 	    (error "Not an org-mode file!"))
    ;; 	(if (memq 'my-org-latex-export-to-latex after-save-hook)
    ;; 	    (progn (remove-hook 'after-save-hook  'my-org-latex-export-to-latex)
    ;; 		    (message "Disabled my-org-latex-export-to-latex on save"))
    ;; 	    (add-hook 'after-save-hook 'my-org-latex-export-to-latex)
    ;; 	    (set-buffer-modified-p t)
    ;; 	    (message "Enabled my-org-latex-export-to-latex on save")))

    (fset 'bll-export
    (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ("ll" 0 "%d")) arg)))
    
    (defun my-org-latex-export-and-save ()
      (interactive)
      (bll-export)
      (save-buffer) 
      )

    (global-set-key (kbd "C-c w")
	     'my-org-latex-export-and-save)

    ;; org-mode leuven theme
    ;;(add-to-list 'custom-theme-load-path "~/.emacs.d/elpa/emacs-leuven-theme")
    ;;(add-hook 'after-init-hook (lambda () (load-theme 'leuven t)))
    (defun org-archive-done-tasks-subtree ()
      (interactive)
      (org-map-entries
      (lambda ()
      (org-archive-subtree)
      (setq org-map-continue-from (outline-previous-heading)))
      "/DONE" 'tree))
    
    (defun org-archive-done-tasks-file ()
      (interactive)
      (org-map-entries
      (lambda ()
      (org-archive-subtree)

      (setq org-map-continue-from (outline-previous-heading)))
      "/DONE" 'file))

    ;; make sure that python and elisp code
    ;; blocks can be evaluated in org-mode
    (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
        (python . t)
        (shell . t)
        (haskell . t))
      )

    ;; add koma-article to org-mode
    (with-eval-after-load "ox-latex"
      (add-to-list 'org-latex-classes
                   '("koma-article" "\\documentclass{scrartcl}"
                     ("\\section{%s}" . "\\section*{%s}")
                     ("\\subsection{%s}" . "\\subsection*{%s}")
                     ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                     ("\\paragraph{%s}" . "\\paragraph*{%s}")
                     ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))
    
    (setq org-latex-pdf-process 
	  '("latexmk -pdf -pdflatex=lualatex -bibtex %f"))

    ;; (setq org-latex-create-formula-image-program 'imagemagick)

    (require 'org-inlinetask)  ;; new inline-todo with C-c C-x t

    (setq org-startup-indented t) ; Enable `org-indent-mode' by default

    ;; (setq org-export-async-init-file
    ;;   (expand-file-name "init-org-async.el" (file-name-directory user-init-file)))
    (setq org-export-async-init-file "~/.emacs")

    ;; bigger latex fragments
    (plist-put org-format-latex-options :scale 1.1)

    (defvar org-latex-fragment-last nil
      "Holds last fragment/environment you were on.")

     ;; READ: Better just get used to reading latex.
     ;; Because in a proper latex-fragment-preview configuration
     ;; together with org-mode lies madness
    (defun org-latex-fragment-toggle ()
      (interactive)
       "Toggle a latex fragment image "
       (and (eq 'org-mode major-mode)
            (let* ((el (org-element-context))
                   (el-type (car el)))
              (cond
               ;; were on a fragment and now on a new fragment
               ((and
                 ;; fragment we were on
                 org-latex-fragment-last
                 ;; and are on a fragment now
                 (or
                  (eq 'latex-fragment el-type)
                  (eq 'latex-environment el-type))
                 ;; but not on the last one this is a little tricky. as you edit the
                 ;; fragment, it is not equal to the last one. We use the begin
                 ;; property which is less likely to change for the comparison.
                 (not (= (org-element-property :begin el)
                         (org-element-property :begin org-latex-fragment-last))))
                ;; go back to last one and put image back
                (save-excursion
                  (goto-char (org-element-property :begin org-latex-fragment-last))
                  (org-preview-latex-fragment))
                ;; now remove current image
                (goto-char (org-element-property :begin el))
                (let ((ov (loop for ov in (org--list-latex-overlays)
                                if
                                (and
                                 (<= (overlay-start ov) (point))
                                 (>= (overlay-end ov) (point)))
                                return ov)))
                  (when ov
                    (delete-overlay ov)))
                ;; and save new fragment
                (setq org-latex-fragment-last el))
     
               ;; were on a fragment and now are not on a fragment
               ((and
                 ;; not on a fragment now
                 (not (or
                       (eq 'latex-fragment el-type)
                       (eq 'latex-environment el-type)))
                 ;; but we were on one
                 org-latex-fragment-last)
                ;; put image back on
                (save-excursion
                  (goto-char (org-element-property :begin org-latex-fragment-last))
                  (org-preview-latex-fragment))
                ;; unset last fragment
                (setq org-latex-fragment-last nil))
     
               ;; were not on a fragment, and now are
               ((and
                 ;; we were not one one
                 (not org-latex-fragment-last)
                 ;; but now we are
                 (or
                  (eq 'latex-fragment el-type)
                  (eq 'latex-environment el-type)))
                (goto-char (org-element-property :begin el))
                ;; remove image
                (let ((ov (loop for ov in (org--list-latex-overlays)
                                if
                                (and
                                 (<= (overlay-start ov) (point))
                                 (>= (overlay-end ov) (point)))
                                return ov)))
                  (when ov
                    (delete-overlay ov)))
                (setq org-latex-fragment-last el))))))

     (setq latex-is-on 0)

     (defun toggle-latex ()
       (interactive)
	 (if (eq latex-is-on 0)
	     (progn
	       (add-hook 'post-command-hook 'org-latex-fragment-toggle)
	       (setq latex-is-on 1)
	       )
	   (progn
	     (remove-hook 'post-command-hook 'org-latex-fragment-toggle)
	     (setq latex-is-on 0)
	     )
	   )
	 
       (print latex-is-on)
	 )

    ;; (toggle-latex)

    ;; (local-set-key (kbd "C-c t l")
    ;; 		    'toggle-latex)


    ;; (local-set-key (kbd "C-c t f")
    ;; 	     'org-latex-fragment-toggle)
)

(use-package evil
  :init 
    (setq evil-want-C-u-scroll t) ;; do this before you require evil
    (add-to-list 'load-path "~/.emacs.d/evil")

    ;; evil-collection, see https://github.com/emacs-evil/evil-collection#installation
    (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
    (setq evil-want-keybinding nil)
  :config
    (evil-mode 1)
    (add-to-list 'evil-emacs-state-modes 'nav-mode)
    (add-to-list 'evil-emacs-state-modes 'pdf-occur-buffer-mode)

    ;; only ever go up/down visual lines
    (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
    (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
)

(use-package evil-collection
  :after evil
  :ensure t
  :config 
  (evil-collection-init)

  (defun mysethistoryforwardbackward ()
    (interactive)
    (evil-define-key 'normal pdf-view-mode-map (kbd "B") 'pdf-history-backward)
    (evil-define-key 'normal pdf-view-mode-map (kbd "F") 'pdf-history-forward)
    (add-hook 'pdf-view-mode-hook #'evil-normalize-keymaps)
    )
 
    (add-hook 'pdf-view-mode-hook #'mysethistoryforwardbackward)
  )

(use-package linum-relative
  :config
    (add-hook 'prog-mode-hook 'linum-on)
    (setq linum-relative-current-symbol "")
    (linum-relative-mode)
    ;; only for files, not for regular other buffers
    ;; (add-hook 'find-file-hook 'linum-mode)
)

(use-package tex
  :defer t
  :ensure auctex
  :config
    (setq TeX-auto-save t)
    ;; in latex-mode with auctex, don't use fancy fontification for math
    (setq tex-fontify-script nil)
    (setq font-latex-fontify-script nil)
    
    ;; also don't use big ugly headings
    (setq font-latex-fontify-sectioning 'color)
    (setq font-latex-fontify-sectioning 1.0)
)

(use-package yasnippet
  :config
    (yas-global-mode)
    (defun my-org-latex-yas ()
      ;; Activate org and LaTeX yas expansion in org-mode buffers.
      (yas-minor-mode)
      (yas-activate-extra-mode 'latex-mode)

      ;; hacky: let yasnippet expand with no whitespace in between
      ;; key and dollar sign (add $ to whitespace syntax class),
      ;; meaning that when it is looking for a key to expand, it skips
      ;; backwards and ends at $, then it searches the keys for all
      ;; that is between the point and the next non-word char,
      ;; e.g. now $ (ascii 36))
      (modify-syntax-entry 36 " " org-mode-syntax-table)
      ;; also, move \ (ascii 92) from the symbol to the word syntax class
      ;; so that no snippet that ends with it's own key (e.g. \delta)
      ;; is accidentally expanded twice like \\delta
      (modify-syntax-entry 92 "w" org-mode-syntax-table)
      )
    
    (add-hook 'org-mode-hook #'my-org-latex-yas)
    (setq yas-triggers-in-field t)

    )

(defun mymessage ()
    (interactive)
    (message "HEY")
    (org-mode)
    (org-toggle-latex-fragment)
    )

(with-eval-after-load "pdf-annot"
  (add-hook 'pdf-annot-edit-contents-minor-mode-hook 'mymessage)
  )

(use-package pdf-tools
  :config
  (define-key pdf-view-mode-map (kbd "C-c C-l") 'org-store-link)
  (define-key pdf-view-mode-map (kbd "C-c C-s") 'pdf-view-auto-slice-minor-mode)
  ;; (add-hook 'pdf-tools-enabled-hook 'pdf-view-midnight-minor-mode)
)


(use-package org-pdfview
  ;; org-pdfview: it's not a minor-mode, just a few functions that adapt
  ;; orgs behavior if pdf-view-mode is enabled, e.g. for storing links,
  ;; a special function is called
  :config
    (pdf-tools-install)
    ;; (pdf-loader-install)
    
    ;; override a function in org-pdfview so that the description is not the whole file path
    (eval-after-load "org-pdfview"
      (defun org-pdfview-store-link ()
        "  Store a link to a pdfview buffer."
        (when (eq major-mode 'pdf-view-mode)
          ;; This buffer is in pdf-view-mode
          (let* ((path buffer-file-name)
         	  (page (pdf-view-current-page))
         	  (link (concat "pdfview:" path "::" (number-to-string page))))
            (org-store-link-props
             :type "pdfview"
             :link link
             :description (concat (nth 0 (split-string (file-name-nondirectory buffer-file-name) "-")) "::" (number-to-string (pdf-view-current-page)))
             ))))
    )
)

(use-package org-download
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))

(use-package org-ref
  :after org)

(use-package centered-window :ensure t)


;; I don't use org-noter right now. The concept is good though.
;; I find pure org-mode with links a to be more versatile,
;; unfortunately it doesn't (yet) have the syncing feature that org-noter has.
;; (use-package org-noter)

(defun my-terminal-with-tmux ()
  (interactive)
  (shell-command "gnome-terminal -e 'tmux new' >/dev/null")
  )

(global-set-key (kbd "C-x C-m C-t") 'my-terminal-with-tmux)

(defun my-explorer ()
  (interactive)
  (setq s (concat "nautilus " (file-name-directory buffer-file-name) " & "))
  (message s)
  (call-process-shell-command s nil 0)
  )

(global-set-key (kbd "C-x C-m C-f") 'my-explorer)  ; open gui file explorer

(defun my-browser ()
  (interactive)
  (setq s (concat "chromium-browser " (file-name-directory buffer-file-name) " & "))
  (message s)
  (call-process-shell-command s nil 0)
  )

(global-set-key (kbd "C-x C-m C-b") 'my-browser)  ; open browser at that file

(use-package multi-term
  :config
  (setq multi-term-program "/usr/local/bin/zsh")
  
  (add-hook 'term-mode-hook
            (lambda ()
              (setq term-buffer-maximum-size 10000)))
  
  (add-hook 'term-mode-hook
            (lambda ()
              (setq show-trailing-whitespace nil)))
  
  (defcustom term-unbind-key-list
    '("C-z" "C-x" "C-c" "C-h" "C-y" "<ESC>")
    "The key list that will need to be unbind."
    :type 'list
    :group 'multi-term)
  
  (defcustom term-bind-key-alist
    '(
      ("C-c C-c" . term-interrupt-subjob)
      ("C-p" . previous-line)
      ("C-n" . next-line)
      ("C-s" . isearch-forward)
      ("C-r" . isearch-backward)
      ("C-m" . term-send-raw)
      ("M-f" . term-send-forward-word)
      ("M-b" . term-send-backward-word)
      ("M-o" . term-send-backspace)
      ("M-p" . term-send-up)
      ("M-n" . term-send-down)
      ("M-M" . term-send-forward-kill-word)
      ("M-N" . term-send-backward-kill-word)
      ("M-r" . term-send-reverse-search-history)
      ("M-," . term-send-input)
      ("M-." . comint-dynamic-complete))
    "The key alist that will need to be bind.
  If you do not like default setup, modify it, with (KEY . COMMAND) format."
    :type 'alist
    :group 'multi-term)
  
  (add-hook 'term-mode-hook
            (lambda ()
              (add-to-list 'term-bind-key-alist '("M-[" . multi-term-prev))
              (add-to-list 'term-bind-key-alist '("M-]" . Multi-term-next))))
  
  (add-hook 'term-mode-hook
            (lambda ()
              (define-key term-raw-map (kbd "C-y") 'term-paste)))
  

  )

(global-set-key (kbd "C-x C-m C-m") 'multi-term)  ; open multi-terminal

(setq inhibit-startup-message t) ;; hide the startup message

(use-package material-theme
  :ensure t)
(load-theme 'material t) ;; load material theme

(use-package flycheck)
(use-package py-autopep8)

(use-package elpy
  :config
  (elpy-enable)

  ;; switch out flymake for flycheck (less troubleshooting, real-time syntax checking)
  (when (require 'flycheck nil t)
    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
    (add-hook 'elpy-mode-hook 'flycheck-mode))

  (add-hook 'python-mode-hook 'elpy-mode)
  (with-eval-after-load 'elpy
  (remove-hook 'elpy-modules 'elpy-module-flymake)
  (add-hook 'elpy-mode-hook 'flycheck-mode))
  ;; (add-hook 'elpy-mode-hook 'elpy-use-ipython)
  ;; (add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

  ;; ;; switch out the standard python interpreter with jupyter 
  ;; (setq python-shell-interpreter "jupyter"
  ;;       python-shell-interpreter-args "console --simple-prompt"
  ;;       python-shell-prompt-detect-failure-warning nil)
  ;; (add-to-list 'python-shell-completion-native-disabled-interpreters
  ;;              "jupyter")

    (global-set-key (kbd "C-, d") 'elpy-goto-definition)
  )

(defun printbreakpoint ()
	  (interactive)
	  (insert "import ipdb; ipdb.set_trace()  # noqa BREAKPOINT<C-c>"))
(global-set-key (kbd "C-, b") 'printbreakpoint)

(if (display-graphic-p)
  (progn
    (setq frame-resize-pixelwise t)
    (set-frame-position (selected-frame) 0 0)
    ;; (set-frame-size (selected-frame) (truncate (/ 1920 2.053)) 600 t)
    (set-frame-size (selected-frame) 905 600 t))
  (progn
    (menu-bar-mode -1))
  )

(use-package projectile
  :config
  (projectile-mode +1)
  (define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  )

;; it caused an annoying warning, and has an ugly seperator
;; (use-package dired-sidebar
;;   :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
;;   :ensure t
;;   :commands (dired-sidebar-toggle-sidebar)
;;   :init
;;   (add-hook 'dired-sidebar-mode-hook
;;             (lambda ()
;;               (unless (file-remote-p default-directory)
;;                 (auto-revert-mode))))
;;   :config
;;   (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
;;   (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
;; 
;;   (setq dired-sidebar-subtree-line-prefix "__")
;;   (setq dired-sidebar-theme 'vscode)
;;   (setq dired-sidebar-use-term-integration t)
;;   (setq dired-sidebar-use-custom-font t))


(use-package neotree
  :config 
  (global-set-key (kbd "C-, t") 'neotree-toggle)
  )

(scroll-bar-mode -1)

(defun halve-other-window-height ()
  "Expand current window to use half of the other window's lines."
  (interactive)
  (enlarge-window (/ (window-height (next-window)) 2)))

(global-set-key (kbd "C-, h") 'halve-other-window-height)

;; A Cool functionality would be to
;; Have a function associated with the project folder, that
;; when having a file of the project open,
;; on keypress:
;; - activates the associated virtualenv using pyvenv-activate (saved in e.g. .local-vars.el)
;; - opens a term window with a specific name in a small split (project name, e.g. saved in .local-vars.el) and makes sure the venv is in fact activated
;; - sends the execution command (python main.py) to the term buffer and runs it

(use-package pyvenv
        :ensure t
        :init
        (setenv "WORKON_HOME" "~/venvs")
        (pyvenv-mode 1)
        (pyvenv-tracking-mode 1))

(defun my-echo ()
  (interactive)
  (switch-to-buffer "*terminal*")
  (end-of-buffer)
  (insert "echo hello")
  (term-send-input))

(defun visit-project-term-buffer ()
  "Create or visit a terminal buffer."
  (interactive)
  (if (not (get-buffer (persp-ansi-buffer-name)))
  (progn
    (split-window-sensibly (selected-window))
    (other-window 1)
    (ansi-term (getenv "SHELL"))
    (rename-buffer (persp-ansi-buffer-name))
    (end-of-buffer)
    (insert (format "cd %s" (projectile-project-root)))
    (term-send-input))
  (switch-to-buffer-other-window (persp-ansi-buffer-name))))

(defun python-execute-main-in-terminal()
  (interactive)
  (comint-send-string "*terminal*" "python main.py\n"))

(global-set-key (kbd "C-, z") 'python-execute-main-in-terminal)
