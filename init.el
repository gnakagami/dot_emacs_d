;;; init.el --- My init.el  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Naoya Yamashita

;; Author: Naoya Yamashita <conao3@gmail.com>

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; My init.el.

;;; Code:

;; this enables this running method
;;   emacs -q -l ~/.debug.emacs.d/{{pkg}}/init.el
(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("org"   . "https://orgmode.org/elpa/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)
    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; -----
(leaf leaf
  :config
  (leaf leaf-convert :ensure t)
  (leaf leaf-tree
    :ensure t
    :custom ((imenu-list-size . 30)
             (imenu-list-position . 'left))))

(leaf macrostep
  :ensure t
  :bind (("C-c e" . macrostep-expand)))

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

;; ---------------------------------------------------------
;;  My Setting / 個人設定
;;   after edit, re byte-compile
;;   $ emacs --batch -f batch-byte-compile init.el

;; (leaf leaf-convert
;;   :setq ((my-system-type . "wsl")) ; linux or darwin
;; )

(leaf my-settings
  :doc "基本設定"
  :load-path "~/.emacs.d/site-lisp"
  :custom
  ((make-backup-files . nil)         ; バックアップファイルを作成しない
   (indent-tabs-mode  . nil)         ; TabはSpaceに
   (tab-width         . 4)           ; Tab幅
   (line-spacing      . 0))          ; row-space
  :config
  (set-language-environment "UTF-8") ;
  (electric-indent-mode -1)          ; invert C-j and Return key
  (show-paren-mode t)                ; hi-light bracket((), {}...)
  (icomplete-mode 1)                 ;
  (fset 'yes-or-no-p 'y-or-n-p)      ; Yes/No to y/n
)

(leaf my-key-bindings
  :doc "キー設定"
  :config
  (global-set-key   "\C-h"        'delete-backward-char)
  (global-set-key   "\M-g"        'goto-line)
  (global-set-key   "\C-x\C-b"    'buffer-menu)
  (global-set-key   (kbd "<f12>") 'eshell)
  (global-unset-key "\C-z")
)

(leaf my-disp-settings
  :doc "表示関連"
  :custom
  ((inhibit-startup-screen . t)
   (line-number-mode       . t)       ; 行位置表示
   (column-number-mode     . t))      ; 列位置表示
  :config
  (tool-bar-mode  -1)                 ; Toolバー無効
  (menu-bar-mode  -1)                 ; Menuバー無効
  (setcar mode-line-position
          '(:eval (format "%d" (count-lines (point-max) (point-min)))))
  (set-scroll-bar-mode nil)
  (setq frame-title-format (format "%%f - Emacs@%s" (system-name)))
)

(leaf exec-path-from-shell
  :doc "環境設定PATHをEmacsに引き継ぐ"
  :req "emacs-24.1" "cl-lib-0.6"
  :ensure t
  :when (eq system-type 'gnu/linux)
  :custom
  ((exec-path-from-shell-arguments . '("-l")))
  :config
  (exec-path-from-shell-initialize)
)

(leaf windmove
  :doc "Alt+CursorでWindow移動"
  :custom
  ((windmove-wrap-around . t))
  :config
  (windmove-default-keybindings)
)

(leaf cua-mode
  :doc "矩形選択"
  :init
  (cua-mode t)
  :custom
  ((cua-enable-cua-keys . nil))
  :config
  (define-key global-map (kbd "C-x SPC") 'cua-set-rectangle-mark)
)

(leaf uniquify
  :doc "unique buffer names dependent on file name"
  :require t
  :custom
  ((uniquify-buffer-name-style . 'post-forward-angle-brackets)
   (uniquify-ignore-buffers-re . "*[^*]+*") ;; correspond to change the buffername.
   (uniquify-min-dir-content   . 1))        ;; display if the same file is not opned.
)

(leaf elscreen
  :doc "仮想Window"
  :ensure t
  :init
  (elscreen-start)
  :custom
  ((elscreen-display-tab . nil))
)

(leaf wgrep
  :doc "Writable grep buffer and apply the changes to files"
  :init
  (require 'wgrep nil t)
  :custom
  ((wgrep-auto-save-buffer     . t)
   (wgrep-change-readonly-file . t)
   (wgrep-enable-key           . "e"))
)

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :req "emacs-25.1" "dash-20210330" "git-commit-20210806" "magit-section-20210806" "transient-20210701" "with-editor-20210524"
  :ensure t
  :require t
  :after git-commit magit-section with-editor
)

(leaf open-junk-file
  :doc "Open a junk (memo) file to try-and-error"
  :ensure t
  :require t
  :config
  (if (eq system-type 'gnu/linux)
      (setq junk-dir-root "~/win_home/docs/Notes/junks")
      (setq junk-dir-root "~/works/notes/junk"))
  (setq open-junk-file-format (concat junk-dir-root "/%y%m%d-%H%M%S."))
  (global-set-key "\C-xj" 'open-junk-file)
)

(leaf tramp
  :doc "SSH接続"
  :require t
  :custom
  ((tramp-default-method . "ssh"))
)

(leaf insert-date-time
  :doc "日時の挿入"
  :preface
  (defun my-insert-date nil
    (interactive)
    (setq system-time-locale "C")
    (insert
     (concat
      (format-time-string "%Y-%m-%d %a"))))

  (defun my-insert-time nil
    (interactive)
    (setq system-time-locale "C")
    (insert
     (concat
      (format-time-string "%H:%M:%S"))))
  :config
  (global-set-key [(control ?\;)] 'my-insert-date)
  (global-set-key [(control ?\:)] 'my-insert-time)
)

(leaf helm-settings
  :when (eq system-type 'gnu/linux)
  :config
  (leaf helm
    :doc "Helm is an Emacs incremental and narrowing framework"
    :req "emacs-25.1" "async-1.9.4" "popup-0.5.3" "helm-core-3.8.2"
    :ensure t
    :require t
    :after helm-core)

  (leaf helm-config
    :doc "Applications library for `helm.el'"
    :require t)

  (leaf helm-gtags
    :doc "GNU GLOBAL helm interface"
    :ensure t
    :after helm
    :require t
    :config
    (setq helm-gtags-path-style 'root)
    (setq helm-gtags-auto-update t)
    (add-hook 'helm-gtags-mode-hook
              '(lambda ()
                 (local-set-key (kbd "M-t") 'helm-gtags-find-tag)
                 (local-set-key (kbd "M-r") 'helm-gtags-find-rtag)
                 (local-set-key (kbd "M-s") 'helm-gtags-find-symbol)
                 (local-set-key (kbd "C-t") 'helm-gtags-pop-stack)))
    (add-hook 'c-mode-hook      'helm-gtags-mode)
    (add-hook 'c++-mode-hook    'helm-gtags-mode)
    (add-hook 'ruby-mode-hook   'helm-gtags-mode)
    (add-hook 'csharp-mode-hook 'helm-gtags-mode)
    (add-hook 'python-mode-hook 'helm-gtags-mode))

  (global-set-key (kbd "M-x")     'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-c i")   'helm-imenu)
  (global-set-key (kbd "C-x b")   'helm-buffers-list)

  (helm-mode 1)

  (define-key helm-map            (kbd "C-h")   'delete-backward-char)            ;; C-h to delete
  (define-key helm-map            (kbd "<tab>") 'helm-execute-persistent-action)
 ;(define-key helm-M-x-map        (kbd "<tab>") 'helm-execute-persistent-action)
  (define-key helm-read-file-map  (kbd "<tab>") 'helm-execute-persistent-action)
  (define-key helm-find-files-map (kbd "<tab>") 'helm-execute-persistent-action)  ;;
  (define-key helm-find-files-map (kbd "C-h")   'delete-backward-char)            ;; C-h to delete

  (setq ad-redefinition-action 'accept)
)

(leaf company
  :ensure t
  :leaf-defer nil
  :blackout company-mode
  :bind
  ((company-active-map
    ("M-n" . nil)
    ("M-p" . nil)
    ("C-s" . company-filter-candidates)
    ("C-n" . company-select-next)
    ("C-p" . company-select-previous)
    ("C-i" . company-complete-selection))
   (company-search-map
    ("C-n" . company-select-next)
    ("C-p" . company-select-previous)))
  :custom
  ((company-tooltip-limit         . 12)
   (company-idle-delay            . 0) ;; 補完の遅延なし
   (company-minimum-prefix-length . 1) ;; 1文字から補完開始
   (company-transformers          . '(company-sort-by-occurrence))
   ;(global-company-mode           . t)
   (company-selection-wrap-around . t)
   (company-require-match         . 'never))
  ;; :config
  ;; (global-set-key (kbd "TAB") 'company-complete-common-or-cycle)
  ;; (push 'company-preview-common-frontend company-frontends)
)

(leaf dired
  :doc "dired-x"
  :init
  (load "dired-x")
  :config
  (defvar my-dired-before-buffer nil)
  (defadvice dired-advertised-find-file
    (before kill-dired-buffer activate)
    (setq my-dired-before-buffer (current-buffer)))
  (defadvice dired-advertised-find-file
    (after kill-dired-buffer-after activate)
    (if (eq major-mode 'dired-mode)
        (kill-buffer my-dired-before-buffer)))
  (defadvice dired-up-directory
    (before kill-up-dired-buffer activate)
    (setq my-dired-before-buffer (current-buffer)))
  (defadvice dired-up-directory
    (after kill-up-dired-buffer-after activate)
    (if (eq major-mode 'dired-mode)
        (kill-buffer my-dired-before-buffer)))
  ;; Customize Date/Time format
  ;;   -L : シンボリックリンクをディレクトリとして表示
  ;; (setq dired-listing-switches
  ;;       "-alh --group-directories-first --time-style \"+%y-%m-%d %H:%M:%S\"")
  ;; 表示項目を指定
  ;; (require 'dired-details-s)
  ;; (setq dired-details-s-types
  ;;       '((size-time  . (user group size time))
  ;;         (all        . (perms links user group size time))
  ;;         (no-details . ())))
)

;; --------------------
;; User Windows Shortcuts
(leaf ls-lisp
  :doc "emulate insert-directory completely in Emacs Lisp"
  :tag "builtin" "dired" "unix"
  :added "2021-11-10"
  :require t
  :config
  ;; ls-lisp を使う
  ;; (setq ls-lisp-use-insert-directory-program nil)
  ;; dired の並び順を Explorer と同じにする
  ;; (setq ls-lisp-ignore-case t)          ; ファイル名の大文字小文字無視でソート
  ;; (setq ls-lisp-dirs-first t)           ; ディレクトリとファイルを分けて表示
  ;; (setq dired-listing-switches "-alG")  ; グループ表示なし
  ;; (setq ls-lisp-UCA-like-collation nil) ; for 25.1 or later
)

(leaf noflet
  :doc "locally override functions"
  :added "2021-11-10"
  :ensure t
  :require t
  :config
  ;; dired でショートカットのターゲット名を表示するように対策する
  ;; (advice-add 'ls-lisp-insert-directory
  ;;             :around
  ;;             (lambda (orig-fun &rest args)
  ;;               (noflet ((directory-files-and-attributes
  ;;                         (&rest args2)
  ;;                         (mapcar (lambda (x) (set-attr-symlink x) x)
  ;;                                 (apply this-fn args2))))
  ;;                       (apply orig-fun args))))

  ;; (advice-add  'ls-lisp-format
  ;;              :before
  ;;              (lambda (&rest args)
  ;;                (set-attr-symlink (cons (nth 0 args) (nth 1 args)))))

  ;; dired でファイル名を取得する際、ショートカットのターゲット名を返すように対策する
  ;; (advice-add 'dired-get-file-for-visit
  ;;             :filter-return
  ;;             (lambda (return-value)
  ;;               (let ((file-name (w32-symlinks-parse-symlink return-value)))
  ;;                 (if file-name
  ;;                     (expand-file-name file-name)
  ;;                   return-value))))
)

(leaf yasnippet
  :doc "Yet another snippet extension for Emacs"
  :req "cl-lib-0.5"
  :tag "emulation" "convenience"
  :url "http://github.com/joaotavora/yasnippet"
  :added "2021-09-15"
  :ensure t
  :require t
  :custom
  ((yas-snippet-dirs . '("~/.emacs.d/mysnippets"
                         "~/.emacs.d/yasnippets")))
  :config
  (define-key yas-minor-mode-map (kbd "C-x i i") 'yas-insert-snippet)     ;; insert snippet
  (define-key yas-minor-mode-map (kbd "C-x i n") 'yas-new-snippet)        ;; create new snippet
  (define-key yas-minor-mode-map (kbd "C-x i v") 'yas-visit-snippet-file) ;; view/edit snippet file
  (yas-global-mode 1)
)

(leaf org-settings
  :doc "Export Framework for Org Mode"
  :tag "builtin"
  :added "2021-09-15"
  :config
   (setq org-hide-leading-stars         t)      ;; 見出しの余分な*を消す
   (setq org-startup-with-inline-images t)      ;; 画像をインラインで表示
   (setq org-directory "~/win_home/docs/Notes") ;; org-directory内のファイルすべてからagendaを作成する
   (setq org-agenda-files '("~/win_home/docs/Notes"))
   (setq org-agenda-start-day "-1d")
   ;(setq org-agenda-span 5)
   (setq org-agenda-start-on-weekday nil)
   ;; TODO
   (setq org-todo-keywords  '((sequence "TODO(t)"
                                        "WORK(w)"
                                        "WAIT"
                                        "|"
                                        "DONE(d)"
                                        "CANCELED(c)" )))
   ;; DONEの時刻を記録
   (setq org-log-done 'time)
   (setq org-capture-templates
         '(("i" "Info"
            entry (file+datetree "~/win_home/docs/Notes/logs.org")
            "* %?\n  Entered on %U"
            :unnarrowed 1)
           ("t" "Task"
            entry (file+datetree "~/win_home/docs/Notes/todo.org")
            "** TODO %?\n   SCHEDULED: %^t")
           ("S" "Scheduler"
            entry (file+datetree "~/win_home/docs/Notes/logs_scheduler.org")
            "* %?\n  Entered on %U"
            :unnarrowed 1)
           ("Q" "QDS"
            entry (file+datetree "~/win_home/docs/Notes/logs_qds.org")
            "* %?\n  Entered on %U"
            :unnarrowed 1)
           ("O" "OEE"
            entry (file+datetree "~/win_home/docs/Notes/logs_oee.org")
            "* %?\n  Entered on %U"
            :unnarrowed 1)
           ("v" "View"
            plain (file+datetree "~/win_home/docs/Notes/logs.org")
            nil
            :jump-to-captured 1
            :unnarrowed 1)
           ))
   ;; .orgファイルは自動的にorg-mode
   (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
   (global-set-key "\C-cl" 'org-store-link)
   (global-set-key "\C-cc" 'org-capture)
   (global-set-key "\C-ca" 'org-agenda)
   (global-set-key "\C-cb" 'org-iswitchb)
   ;; color
   ;; (custom-set-faces
   ;;  '(org-level-1 ((t (:foreground "#2980B9")))) ; BELIZE HOLE
   ;;  '(org-level-2 ((t (:foreground "#16A085")))) ; GREEN SEA
   ;;  '(org-level-3 ((t (:foreground "#F39C12")))) ; ORANGE
   ;;  '(org-level-4 ((t (:foreground "#ECF0F1")))) ; CLOUD
   ;;  ;; org-level-3,4,5..と指定可能
   ;;  )
   (leaf org-superstar
     :doc "Prettify headings and plain lists in Org mode"
     :req "org-9.1.9" "emacs-26.1"
     :tag "outlines" "faces" "emacs>=26.1"
     :url "https://github.com/integral-dw/org-superstar-mode"
     :added "2021-12-29"
     :emacs>= 26.1
     :ensure t
     :after org
     :require t
     :hook
     (org-mode-hook . (lambda () (org-superstar-mode 1)))
     :config
     ;;(set-face-attribute 'org-superstar-header-bullet nil :inherit 'fixed-pitched :height 180)
     (setq org-superstar-headline-bullets-list '("○" "◼" "⚫" "▸" "･"))
     ;; (setq org-superstar-item-bullet-alist
     ;;       '((?* . ?•)
     ;;         (?* . ?➤)
     ;;         (?- . ?➖)))
     (setq org-superstar-todo-bullet-alist
           ;; '(("TODO" . ?☐) ("WORK" . ?✰) ("CANCELED" . ?✘) ("WAIT" . ?☕) ("DONE" . ?✔)))
           '(("TODO" . ?☐)
             ("WORK" . ?✍)
             ("CANCELED" . ?✘)
             ("WAIT" . ?☕)
             ("DONE" . ?✔)))
     (setq org-superstar-special-todo-items t)
   )
)

(leaf markdown-settings
  :config
  (leaf markdown-mode
    :doc "Major mode for Markdown-formatted text"
    ;; ------------------------------
    ;;   key-bind
    ;;     TAB:          見出しやツリーの折り畳み
    ;;     C-c C-n:      次の見出しに移動
    ;;     C-c C-p:      前の見出しに移動
    ;;     C-c ← →:    見出しレベルの上げ下げ
    ;;     C-c ↑ ↓:    見出しの移動
    ;;     M-S-Enter:    見出しの追加
    ;;     M-Enter:      リストの追加
    ;;     C-c C-d:      TODOの追加(トグル)
    ;;     C-c ':        コードブロックでmode編集
    ;;     C-c C-x ENTER バッファ内で整形表示
    ;;     C-c C-c p     ブラウザで表示
    ;; ------------------------------
    :req "emacs-25.1"
    :tag "itex" "github flavored markdown" "markdown" "emacs>=25.1"
    :url "https://jblevins.org/projects/markdown-mode/"
    :added "2021-09-15"
    :emacs>= 25.1
    :ensure t
    :leaf-defer t
    :mode ("\\.md\\'" . gfm-mode)
    :custom
    (markdown-command . "github-markup")
    (markdown-command-needs-filename . t)
    (markdown-preview-stylesheets . '(list "~/.emacs.d/css/github.css"))
    :config
    (autoload 'markdown-mode "markdown-mode" "Major mode for editing Markdown files" t)
  )
  (leaf markdown-preview-mode
    :ensure t)
)

(leaf yaml-mode
  :ensure t
  :leaf-defer t
  :mode ("\\.yaml\\'" . yaml-mode)
)

(leaf flycheck
  :doc "On-the-fly syntax checking"
  :req "dash-2.12.1" "pkg-info-0.4" "let-alist-1.0.4" "seq-1.11" "emacs-24.3"
  :tag "tools" "languages" "convenience" "emacs>=24.3"
  :url "http://www.flycheck.org"
  :added "2021-09-22"
  :emacs>= 24.3
  :ensure t
  :custom
  ((flycheck-display-errors-delay . 1.0))
  :hook
  (prog-mode-hook . flycheck-mode)
  :config
  (leaf flycheck-inline
    :ensure t
    :hook (flycheck-mode-hook . flycheck-inline-mode))
  (leaf flycheck-color-mode-line
    :ensure t
    :hook (flycheck-mode-hook . flycheck-color-mode-line-mode))
)

;; (leaf highlight-indent-guides
;;   ;; インデントの位置を強調表示
;;   :doc "Minor mode to highlight indentation"
;;   :req "emacs-24.1"
;;   :tag "emacs>=24.1"
;;   :url "https://github.com/DarthFennec/highlight-indent-guides"
;;   :added "2021-12-14"
;;   :emacs>= 24.1
;;   :ensure t
;;   :require t
;;   :hook
;;   (prog-mode-hook . highlight-indent-guides-mode)
;;   :custom
;;   ((highlight-indent-guides-method . 'bitmap)
;;    (highlight-indent-guides-auto-enabled . t)
;;    (highlight-indent-guides-responsive . t)
;;    (highlight-indent-guides-character . ?\|))
;; )

(leaf csharp-mode
  :doc "C# mode derived mode"
  :req "emacs-26.1"
  :tag "mode" "oop" "languages" "c#" "emacs>=26.1"
  :url "https://github.com/emacs-csharp/csharp-mode"
  :added "2021-12-27"
  :emacs>= 26.1
  :ensure t
  :config
  ;; 文字コードをSJISにする
  (modify-coding-system-alist 'file "\\.cs\\'" 'sjis-dos)
  (defun my-cs-mode-hook ()
    ""
    (setq tab-witdh 4)
    (setq indent-tabs-mode nil))

  ;; char-mode is sjis
  (add-hook 'csharp-mode-hook 'my-cs-mode-hook)
  (autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
  (setq auto-mode-alist (append '(("\\.cs$" . csharp-mode)) auto-mode-alist))
)

(leaf python
  :when (eq system-type 'gnu/linux)
  :config
  (setq python-indent-guess-indent-offset-verbose nil)

  ;; (leaf python-mode
  ;;   :doc "Python major mode"
  ;;   :tag "oop" "python" "processes" "languages"
  ;;   :url "https://gitlab.com/groups/python-mode-devs"
  ;;   :added "2021-12-14"
  ;;   :ensure t
  ;;   :require t
  ;; )

  (leaf elpy
    :doc "Emacs Python Development Environment"
    :req "company-0.9.2" "emacs-24.4" "highlight-indentation-0.5.0" "pyvenv-1.3" "yasnippet-0.8.0" "s-1.11.0"
    :tag "tools" "languages" "ide" "python" "emacs>=24.4"
    :url "https://github.com/jorgenschaefer/elpy"
    :added "2021-12-14"
    :emacs>= 24.4
    :ensure t
    :after company highlight-indentation pyvenv yasnippet
    :init
    (elpy-enable)
    :hook
    ((python-mode . elpy-enable)
     (elpy-mode-hook . flycheck-mode)
     (elpy-mode-hook . (lambda ()
                         (auto-complete-mode -1)
                         ;(py-yapf-enable-on-save)
                         (define-key elpy-mode-map "\C-c\C-c" 'exec-python)
                         (highlight-indentation-mode -1)))
    )
    :custom
    ((elpy-rpc-backend . "jedi")) ; or 'jedi')
    :config
    (elpy-enable)
    (remove-hook 'elpy-modules 'elpy-module-highlight-indentation) ;; インデントハイライトの無効化
    (remove-hook 'elpy-modules 'elpy-module-flymake) ;; flymakeの無効化
  )

  ;(setq debug-on-error t) ;; for debug
  ;; (setenv "PYTHONIOENCODING" "utf-8")
  ;; (add-to-list 'process-coding-system-alist '("python" . (utf-8 . utf-8)))
  ;; (add-to-list 'process-coding-system-alist '("elpy"   . (utf-8 . utf-8)))
  ;; (add-to-list 'process-coding-system-alist '("flake8" . (utf-8 . utf-8)))
  ;; (leaf elpy
  ;;   :preface
  ;;   (defun exec-python nil
  ;;     "Use compile to run python programs"
  ;;     (interactive)
  ;;   (compile (concat "python " (buffer-file-name))))
  ;;   :hook
  ;;   ((python-mode . elpy-enable)
  ;;    ;(elpy-mode-hook . flycheck-mode)
  ;;   )
  ;;   :config
  ;;   ;; (add-hook 'elpy-mode-hook (lambda ()
  ;;   ;;                            ;(auto-complete-mode -1)
  ;;   ;;                            ;(py-yapf-enable-on-save)
  ;;   ;;                            ;(define-key elpy-mode-map "\C-c\C-c" 'exec-python)
  ;;   ;;                            ;(highlight-indentation-mode -1))
  ;;   ;;                             ))
  ;; )

  (leaf pipenv
    :doc "A Pipenv porcelain"
    :req "emacs-25.1" "s-1.12.0" "pyvenv-1.20"
    :tag "emacs>=25.1"
    :url "https://github.com/pwalsh/pipenv.el"
    :added "2021-09-22"
    :emacs>= 25.1
    :ensure t
    :after pyvenv python
    :require t
    :defvar python-shell-interpreter python-shell-interpreter-args python-shell-virtualenv-root pyvenv-activate
    :defun pipenv--force-wait pipenv-deactivate pipenv-projectile-after-switch-extended pipenv-venv
    :custom
    (pipenv-projectile-after-switch-function . #'pipenv-projectile-after-switch-extended)
    :init
    (defun pipenv-auto-activate ()
      (pipenv-deactivate)
      (pipenv--force-wait (pipenv-venv))
      (when python-shell-virtualenv-root
        (setq-local pyvenv-activate (directory-file-name python-shell-virtualenv-root))
        (setq-local python-shell-interpreter "pipenv")
        (setq-local python-shell-interpreter-args "run python")
      ))
    :hook (elpy-mode-hook . pipenv-auto-activate)
    :config
    (pyvenv-tracking-mode)
    (add-to-list 'python-shell-completion-native-disabled-interpreters "pipenv")
  )

  (leaf ein
    :doc "Emacs IPython Notebook"
    :req "emacs-25" "websocket-1.12" "anaphora-1.0.4" "request-0.3.3" "deferred-0.5" "polymode-0.2.2" "dash-2.13.0" "with-editor-0.-1"
    :tag "reproducible research" "literate programming" "jupyter" "emacs>=25"
    :url "https://github.com/dickmao/emacs-ipython-notebook"
    :added "2022-03-17"
    :emacs>= 25
    :ensure t
    :after websocket anaphora deferred polymode with-editor
    :require t
    :config
    (require 'ein-notebook)
    (require 'ein-notebooklist)
    (require 'ein-subpackages)
    (require 'ein-markdown-mode)

    (setq ein:worksheet-enable-undo t)
    (setq ein:output-area-inlined-images t)

    (require 'smartrep)
    (declare-function smartrep-define-key "smartrep")
    (with-eval-after-load "ein-notebook"
      (smartrep-define-key ein:notebook-mode-map "C-c"
                           '(("C-n" . 'ein:worksheet-goto-next-input-km)
                             ("C-p" . 'ein:worksheet-goto-prev-input-km))))
  )
)

;; (leaf py-yapf
;;   :doc "Use yapf to beautify a Python buffer"
;;   :url "https://github.com/paetzke/py-yapf.el"
;;   :added "2021-09-15"
;;   :ensure t
;;   :require t
;;   :config
;;   (add-hook 'python-mode-hook 'py-yapf-enable-on-save)
;; )

(leaf ruby-settings
  :when (eq system-type 'gnu/linux)
  :config
  (defun my-ruby-mode-hook ()
    ""
    (setq ruby-insert-encoding-magic-comment nil) ; not insert coding: utf-8
  )
  (add-hook 'ruby-mode-hook 'my-ruby-mode-hook)
)

(leaf gui-settings
  :if window-system
  :config
  (modify-frame-parameters nil '((sticky . t) (width . 100) (height . 40)))
  ;(set-face-attribute 'default nil :family "RobotoJ Mono" :height 140) ; font
  (set-face-attribute 'default nil :family "RobotoJ Mono" :height 120) ; font

  ;; hl-line-mode
  (global-hl-line-mode 1)
  (set-face-background 'highlight "#333")
  (set-face-foreground 'highlight nil)
  (set-face-underline  'highlight t)
)

(leaf mozc-settings
  ;; for flicker in bellow
  ;; -> xset -r 49
  :doc "minor mode to input Japanese with Mozc"
  :tag "input method" "multilingual" "mule"
  :added "2021-09-15"
  :ensure t
  :when (eq system-type 'gnu/linux)
  :require t
  ;; disabled.
  ;; :custom
  ;; ((default-input-method . "japanese-mozc")
  ;; )
  ;; for GoogleIME
  :config
  (global-set-key (kbd "<zenkaku-hankaku>") 'toggle-input-method)

  (leaf mozc-im
    :doc "Mozc with input-method-function interface."
    :req "mozc-0"
    :tag "extentions" "i18n"
    :added "2021-12-09"
    :ensure t
  :after mozc)

  (leaf mozc-popup
    :doc "Mozc with popup"
    :req "popup-0.5.2" "mozc-0"
    :tag "extentions" "i18n"
    :added "2021-12-09"
    :ensure t
    :after mozc)

  (require 'mozc-im)
  (require 'mozc-popup)
  (require 'mozc-cursor-color)
  (require 'wdired)
  (setq default-input-method "japanese-mozc-im")
  ;; popupスタイル を使用する
  (setq mozc-candidate-style 'popup)
  ;; カーソルカラーを設定する
  (setq mozc-cursor-color-alist '((direct        . "red")
                                  (read-only     . "yellow")
                                  (hiragana      . "green")
                                  (full-katakana . "goldenrod")
                                  (half-ascii    . "dark orchid")
                                  (full-ascii    . "orchid")
                                  (half-katakana . "dark goldenrod")))

  ;; カーソルの点滅を OFF にする
  (blink-cursor-mode 0)
  (defun enable-input-method (&optional arg interactive)
    (interactive "P\np")
    (if (not current-input-method)
        (toggle-input-method arg interactive)))

  (defun disable-input-method (&optional arg interactive)
    (interactive "P\np")
    (if current-input-method
        (toggle-input-method arg interactive)))

  (defun isearch-enable-input-method ()
    (interactive)
    (if (not current-input-method)
        (isearch-toggle-input-method)
      (cl-letf (((symbol-function 'toggle-input-method)
                 (symbol-function 'ignore)))
        (isearch-toggle-input-method))))

  (defun isearch-disable-input-method ()
    (interactive)
    (if current-input-method
        (isearch-toggle-input-method)
      (cl-letf (((symbol-function 'toggle-input-method)
                 (symbol-function 'ignore)))
        (isearch-toggle-input-method))))

  ;; IME をトグルするキー設定
  (global-set-key (kbd "C-o") 'toggle-input-method)
  (define-key isearch-mode-map (kbd "C-o") 'isearch-toggle-input-method)
  (define-key wdired-mode-map (kbd "C-o") 'toggle-input-method)

  ;; IME を無効にするキー設定
  ;; (global-set-key (kbd "C-<f1>") 'disable-input-method)
  ;; (define-key isearch-mode-map (kbd "C-<f1>") 'isearch-disable-input-method)
  ;; (define-key wdired-mode-map (kbd "C-<f1>") 'disable-input-method)

  ;; (global-set-key (kbd "C-j") 'disable-input-method)
  ;; (define-key isearch-mode-map (kbd "C-j") 'isearch-disable-input-method)
  ;; (define-key wdired-mode-map (kbd "C-j") 'disable-input-method)

  ;; IME を有効にするキー設定
  ;; (global-set-key (kbd "C-<f2>") 'enable-input-method)
  ;; (define-key isearch-mode-map (kbd "C-<f2>") 'isearch-enable-input-method)
  ;; (define-key wdired-mode-map (kbd "C-<f2>") 'enable-input-method)

  ;; (global-set-key (kbd "C-o") 'enable-input-method)
  ;; (define-key isearch-mode-map (kbd "C-o") 'isearch-enable-input-method)
  ;; (define-key wdired-mode-map (kbd "C-o") 'enable-input-method)

  ;; mozc-cursor-color を利用するための対策
  (defvar-local mozc-im-mode nil)
  (add-hook 'mozc-im-activate-hook (lambda () (setq mozc-im-mode t)))
  (add-hook 'mozc-im-deactivate-hook (lambda () (setq mozc-im-mode nil)))
  (advice-add 'mozc-cursor-color-update
              :around (lambda (orig-fun &rest args)
                        (let ((mozc-mode mozc-im-mode))
                          (apply orig-fun args))))

  ;; isearch を利用する前後で IME の状態を維持するための対策
  (add-hook 'isearch-mode-hook (lambda () (setq im-state mozc-im-mode)))
  (add-hook 'isearch-mode-end-hook
            (lambda ()
              (unless (eq im-state mozc-im-mode)
                (if im-state
                    (activate-input-method default-input-method)
                  (deactivate-input-method)))))

  ;; wdired 終了時に IME を OFF にする
  (advice-add 'wdired-finish-edit
              :after (lambda (&rest args)
                       (deactivate-input-method)))

  (advice-add 'mozc-session-execute-command
              :after (lambda (&rest args)
                       (when (eq (nth 0 args) 'CreateSession)
                         ;; (mozc-session-sendkey '(hiragana)))))
                         (mozc-session-sendkey '(Hankaku/Zenkaku)))))

  (setq mozc-helper-program-name "mozc_emacs_helper.sh")
)

(leaf rainbow-delimiters
  :doc "Highlight brackets according to their depth"
  :tag "tools" "lisp" "convenience" "faces"
  :url "https://github.com/Fanael/rainbow-delimiters"
  :added "2021-09-15"
  :ensure t
  :leaf-defer t
  :hook
  (prog-mode-hook . rainbow-delimiters-mode)
)

(leaf fontawesome
  :doc "fontawesome utility"
  :req "emacs-24.4"
  :tag "emacs>=24.4"
  :url "https://github.com/syohex/emacs-fontawesome"
  :added "2021-09-15"
  :emacs>= 24.4
  :ensure t)

(leaf codic
  :doc "Search Codic (codic.jp) naming dictionaries"
  :req "emacs-24" "cl-lib-0.5"
  :tag "emacs>=24"
  :url "https://github.com/syohex/emacs-codic"
  :added "2021-09-15"
  :emacs>= 24
  :ensure t
  :leaf-defer t)

(leaf whitespace
  :doc "minor mode to visualize TAB, (HARD) SPACE, NEWLINE"
  :tag "builtin"
  :added "2021-09-15"
  :require t
  :custom
  ((whitespace-style . '(face           ; faceで可視化
                         trailing       ; 行末
                         tabs           ; タブ
                         spaces         ; スペース
                         ;empty         ; 先頭/末尾の空行
                         space-mark     ; 表示のマッピング
                         tab-mark))

   (whitespace-display-mappings . '((space-mark ?\u3000 [?\u25a1])
                                    ;; WARNING: the mapping below has a problem.
                                    ;; When a TAB occupies exactly one column, it will display the
                                    ;; character ?\xBB at that column followed by a TAB which goes to
                                    ;; the next TAB column.
                                    ;; If this is a problem for you, please, comment the line below.
                                    (tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))
   (whitespace-space-regexp . "\\(\u3000+\\)")
  )
  :config
  (global-whitespace-mode 1)
  (defvar my/bg-color "#282a36")
  (set-face-attribute 'whitespace-trailing nil
                      :background my/bg-color
                      :foreground "DeepPink"
                      :underline t)
  (set-face-attribute 'whitespace-tab nil
                      :background my/bg-color
                                        ;:foreground "LightSkyBlue"
                      :underline t)
  (set-face-attribute 'whitespace-space nil
                      :background my/bg-color
                      :foreground "GreenYellow"
                      :weight 'bold)
  (set-face-attribute 'whitespace-empty nil
                      :background my/bg-color)
)

(leaf color-theme
  :config
  ;; (leaf badger-theme
  ;;   :doc "A dark theme for Emacs 24."
  ;;   :url "https://github.com/ccann/badger-theme"
  ;;   :added "2021-12-29"
  ;;   :ensure t
  ;;   :config
  ;;   (load-theme 'badger t)
  ;;   (setq org-fontify-done-headline t)
  ;;   (set-face-attribute 'region nil                    :background "#F5D658")
  ;; )

  ;; (leaf afternoon-theme
  ;;   :doc "Dark color theme with a deep blue background"
  ;;   :req "emacs-24.1"
  ;;   :tag "themes" "emacs>=24.1"
  ;;   :url "http://github.com/osener/emacs-afternoon-theme"
  ;;   :added "2022-02-15"
  ;;   :emacs>= 24.1
  ;;   :ensure t
  ;;   :require t
  ;;   :config
  ;;   (load-theme 'afternoon t)
  ;; )

  ;; (leaf color-theme-sanityinc-tomorrow
  ;;   :doc "A version of Chris Kempson's \"tomorrow\" themes"
  ;;   :tag "themes" "faces"
  ;;   :url "https://github.com/purcell/color-theme-sanityinc-tomorrow"
  ;;   :added "2022-02-16"
  ;;   :ensure t
  ;;   :require
  ;;   :config
  ;;   (load-theme 'sanityinc-tomorrow-night t)
  ;; )

  ;; (leaf modus-themes
  ;;   :doc "Highly accessible themes (WCAG AAA)"
  ;;   :req "emacs-27.1"
  ;;   :tag "accessibility" "theme" "faces" "emacs>=27.1"
  ;;   :url "https://gitlab.com/protesilaos/modus-themes"
  ;;   :added "2021-09-14"
  ;;   :emacs>= 27.1
  ;;   :ensure t
  ;;   :require t
  ;;   :custom
  ;;   ((modus-themes-slanted-constructs . t)
  ;;    (modus-themes-no-mixed-fonts . t)
  ;;    (modus-themes-subtle-line-numbers . t)
  ;;    (modus-themes-mode-line . '(moody borderless))
  ;;    (modus-themes-syntax . 'faint)
  ;;    (modus-themes-paren-match . 'intense-bold)
  ;;    (modus-themes-region . 'bg-only)
  ;;    (modus-themes-diffs . 'deuteranopia)
  ;;    (modus-themes-org-blocks . 'gray-background)
  ;;    ;; (modus-themes-variable-pitch-ui . t)
  ;;    ;; (modus-themes-variable-pitch-headings . t)
  ;;    (modus-themes-scale-headings . t)

  ;;    ;; (modus-themes-scale-1 . 1.1)
  ;;    ;; (modus-themes-scale-2 . 1.15)
  ;;    ;; (modus-themes-scale-3 . 1.21)
  ;;    ;; (modus-themes-scale-4 . 1.27)
  ;;    ;; (modus-themes-scale-title . 1.33)
  ;;    )
  ;;   :config
  ;;   (modus-themes-load-themes)
  ;;   (modus-themes-load-vivendi)
  ;;   )

  (leaf dracula-theme
    :doc "Dracula Theme"
    :req "emacs-24.3"
    :tag "emacs>=24.3"
    :url "https://github.com/dracula/emacs"
    :added "2023-01-12"
    :emacs>= 24.3
    :ensure t
    :require t
    :config
    (load-theme 'dracula t))
)

;; (leaf doom-modeline
;;   :doc "A minimal and modern mode-line"
;;   :req "emacs-25.1" "all-the-icons-2.2.0" "shrink-path-0.2.0" "dash-2.11.0"
;;   :tag "mode-line" "faces" "emacs>=25.1"
;;   :url "https://github.com/seagle0128/doom-modeline"
;;   :added "2021-09-16"
;;   :emacs>= 25.1
;;   :ensure t
;;   :require t
;;   :after all-the-icons shrink-path
;;   :config
;;   (doom-modeline-mode 1)
;; )

;; (leaf moody
;;   :doc "Tabs and ribbons for the mode line"
;;   :req "emacs-25.3"
;;   :tag "emacs>=25.3"
;;   :url "https://github.com/tarsius/moody"
;;   :added "2021-09-16"
;;   :emacs>= 25.3
;;   :ensure t
;;   :custom
;;   ((x-underline-at-descent-line . t))
;;   :config
;;   (moody-replace-mode-line-buffer-identification)
;;   (moody-replace-vc-mode)
;;   )

(leaf minions
  :doc "A minor-mode menu for the mode line"
  :req "emacs-25.2"
  :tag "emacs>=25.2"
  :url "https://github.com/tarsius/minions"
  :added "2021-09-16"
  :emacs>= 25.2
  :ensure t
  :require t
  :init
  (minions-mode)
  :custom
  ((minions-mode-line-lighter . "[+]")))

(leaf windows-path
  :doc "Can use winsows format path."
  :when (eq system-type 'gnu/linux)
  :config
  (require 'cl-lib)
  (defun set-drvfs-alist ()
    (interactive)
    (setq drvfs-alist
          (mapcar (lambda (x)
                    (when (string-match "\\(.*\\)|\\(.*?\\)/?$" x)
                      (cons (match-string 1 x) (match-string 2 x))))
                  (split-string (concat
                                 ;; //wsl$ or //wsl.localhost パス情報の追加
                                 (when (or (not (string-match "Microsoft" (shell-command-to-string "uname -v")))
                                           (>= (string-to-number (nth 1 (split-string operating-system-release "-"))) 18362))
                                   (concat "/|" (shell-command-to-string "wslpath -m /")))
                                 (shell-command-to-string
                                  (concat
                                   "mount | grep -E 'type (drvfs|cifs)' | sed -r 's/(.*) on (.*) type (drvfs|cifs) .*/\\2\\|\\1/' | sed 's!\\\\!/!g';"
                                   "mount | grep 'aname=drvfs;' | sed -r 's/.* on (.*) type 9p .*;path=([^;]*);.*/\\1|\\2/' | sed 's!\\\\!/!g' | sed 's!|UNC/!|//!' | sed \"s!|UNC\\(.\\)!|//\\$(printf '%o' \\\\\\'\\1)!\" | sed 's/.*/echo \"&\"/' | sh")))
                                "\n" t))))

  (set-drvfs-alist)

  (defconst windows-path-style-regexp "\\`\\(.*/\\)?\\([a-zA-Z]:\\\\.*\\|[a-zA-Z]:/.*\\|\\\\\\\\.*\\|//.*\\)")

  (defun windows-path-convert-file-name (name)
    (setq name (replace-regexp-in-string windows-path-style-regexp "\\2" name t nil))
    (setq name (replace-regexp-in-string "\\\\" "/" name))
    (let ((case-fold-search t))
      (cl-loop for (mountpoint . source) in drvfs-alist
               if (string-match (concat "^\\(" (regexp-quote source) "\\)\\($\\|/\\)") name)
               return (replace-regexp-in-string "^//" "/" (replace-match mountpoint t t name 1))
               finally return name)))

  (defun windows-path-run-real-handler (operation args)
    "Run OPERATION with ARGS."
    (let ((inhibit-file-name-handlers
           (cons 'windows-path-map-drive-hook-function
                 (and (eq inhibit-file-name-operation operation)
                      inhibit-file-name-handlers)))
          (inhibit-file-name-operation operation))
      (apply operation args)))

  (defun windows-path-map-drive-hook-function (operation name &rest args)
    "Run OPERATION on cygwin NAME with ARGS."
    (windows-path-run-real-handler
     operation
     (cons (windows-path-convert-file-name name)
           (if (stringp (car args))
               (cons (windows-path-convert-file-name (car args))
                     (cdr args))
             args))))

  (add-to-list 'file-name-handler-alist
               (cons windows-path-style-regexp
                     'windows-path-map-drive-hook-function))
  )

(leaf vscode-open
  :doc "Open vscode from emacs"
  :when (eq system-type 'gnu/linux)
  :config
  (defun vscode-cmd-escape (arg)
    (replace-regexp-in-string "[&|<>^\"%]" "^\\&" arg))

  (defun vscode-open-command (filename &optional keep-position)
    (interactive)
    (let* ((filename (expand-file-name filename))
           (default-directory "/mnt/c/")
           authority
           target
           command
           filepath)
      (cond ((file-remote-p filename)
             (setq command "cmd.exe /c code")
             (if (file-directory-p filename)
                 (setq command (format "%s --folder-uri" command))
               (setq command (format "%s --file-uri" command)))
             (let* ((vec (tramp-dissect-file-name filename))
                    (method (tramp-file-name-method vec))
                    (host (tramp-file-name-host vec))
                    (user (tramp-file-name-user vec))
                    (localname (tramp-file-name-localname vec)))
               (cond ((or (string= method "scp")
                          (string= method "ssh"))
                      (setq authority "ssh-remote")
                      (setq target (if user
                                       (format "%s@%s" user host)
                                     host))
                      (setq filepath (format "vscode-remote://%s+%s%s" authority target localname)))
                     ((string= method "docker")
                      (setq authority "attached-container")
                      (setq dockerid (shell-command-to-string
                                      (format "cmd.exe /c docker container ls --filter 'name=%s' --format '{{.ID}}'"
                                              host)))
                      (when (not (string= dockerid ""))
                        (setq dockerid (substring dockerid 0 -1))
                        (setq target (mapconcat (lambda (x)
                                                  (format "%02x" (aref x 0)))
                                                (split-string dockerid "" t) ""))
                        (setq filepath (format "vscode-remote://%s+%s%s" authority target localname))
                        (setq filepath (vscode-cmd-escape filepath))
                        (setq filepath (vscode-cmd-escape filepath)))))))
            (t
             (cond (current-prefix-arg
                    (setq command "cmd.exe /c code")
                    (let ((winpath (shell-command-to-string
                                    (format "wslpath2 -w %s 2> /dev/null"
                                            (shell-quote-argument (file-truename filename))))))
                      (when (not (string= winpath ""))
                        (setq filepath (substring winpath 0 -1))
                        (setq filepath (vscode-cmd-escape filepath))
                        (setq filepath (vscode-cmd-escape filepath)))))
                   (t
                    (setq command "code")
                    (setq filepath filename)))
             (when keep-position
               (setq command (format "%s -g" command))
               (setq filepath (format "%s:%d:%d" filepath (line-number-at-pos) (+ (- (point)
                                                                                     (save-excursion
                                                                                       (beginning-of-line)
                                                                                       (point)))
                                                                                  1))))))
      (if (null filepath)
          (message "VSCodeで開くことができません")
        (setq filepath (replace-regexp-in-string "/home/gnakagami/win_home" "/home/gnakagami" filepath))
        (message (format "%s %s" command filepath))
        (shell-command-to-string (format "%s %s" command (shell-quote-argument filepath))))))

  ;; dired で開いているディレクトリを開く
  (define-key dired-mode-map (kbd "V")
    (lambda ()
      (interactive)
      (save-some-buffers)
      (vscode-open-command (dired-current-directory) nil)))

  ;; dired でカーソルがある位置のファイルを開く
  (define-key dired-mode-map (kbd "C-c v")
    (lambda ()
      (interactive)
      (save-some-buffers)
      (vscode-open-command (dired-get-file-for-visit))))

  ;; 開いているファイルをカーソルの位置を維持して開く
  (global-set-key (kbd "C-c v")
                  (lambda ()
                    (interactive)
                    (save-some-buffers)
                    (vscode-open-command buffer-file-name t)))
)

(leaf sql
  :doc "specialized comint.el for SQL interpreters"
  :tag "builtin"
  :added "2022-01-28"
  ;; :require t
  :config
  (modify-coding-system-alist 'file "\\.sql\\'" 'sjis-dos)
  (defun my-sql-mode-hook ()
    ""
    (setq indent-tabs-mode nil) ; t or nil
    (setq sql-indent-offset 4)
  )
  (add-hook 'sql-mode-hook 'my-sql-mode-hook)

  (setq auto-mode-alist (cons '("\\.sql$" . sql-mode) auto-mode-alist))
  (add-hook 'sql-interactive-mode-hook
            '(lambda ()
               (set-buffer-process-coding-system 'sjis-unix 'sjis-unix)
               (setq show-trailing-whitespace nil)))

  (leaf sql-indent
    :doc "Support for indenting code in SQL files."
    :req "cl-lib-0.5"
    :tag "sql" "languages"
    :url "https://github.com/alex-hhh/emacs-sql-indent"
    :added "2022-01-28"
    :ensure t
    :require t
  )
)

(leaf powershell
  :doc "Mode for editing PowerShell scripts"
  :req "emacs-24"
  :tag "languages" "powershell" "emacs>=24"
  :url "http://github.com/jschaf/powershell.el"
  :added "2022-06-21"
  :emacs>= 24
  :ensure t
  :require t
  :config
  ;; 文字コードをSJISにする
  (modify-coding-system-alist 'file "\\.ps1\\'" 'sjis-dos)
)

(leaf dockerfile-mode
  :doc "Major mode for editing Docker's Dockerfiles"
  :req "emacs-24"
  :tag "docker" "emacs>=24"
  :url "https://github.com/spotify/dockerfile-mode"
  :added "2022-04-19"
  :emacs>= 24
  :ensure t
  :require t
  :when (eq system-type 'gnu/linux)
)


;; My Settings ends
;; ----

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; Init.el ends here
