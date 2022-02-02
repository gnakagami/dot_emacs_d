;; ========================================
;; Vertice関連
;; 2022-01-26 Web: 補完がキャンセルしにくい
;; ========================================
(leaf vertico
  ;; 入力補完
  :doc "VERTical Interactive COmpletion"
  :req "emacs-27.1"
  :tag "emacs>=27.1"
  :url "https://github.com/minad/vertico"
  :added "2021-09-15"
  :emacs>= 27.1
  :ensure t
  :custom
  ((vertico-count . 20))
)

(leaf consult
  ;; 補完コマンドの提供
  :doc "Consulting completing-read"
  :req "emacs-26.1"
  :tag "emacs>=26.1"
  :url "https://github.com/minad/consult"
  :added "2021-09-15"
  :emacs>= 26.1
  :ensure t
  :after t embark
  :require embark-consult
)

(leaf marginalia
  ;; 項目情報の提供
  :doc "Enrich existing commands with completion annotations"
  :req "emacs-26.1"
  :tag "emacs>=26.1"
  :url "https://github.com/minad/marginalia"
  :added "2021-09-15"
  :emacs>= 26.1
  :ensure t)

(leaf orderless
  ;; 補完スタイルの提供
  :doc "Completion style for matching regexps in any order"
  :req "emacs-26.1"
  :tag "extensions" "emacs>=26.1"
  :url "https://github.com/oantolin/orderless"
  :added "2021-09-15"
  :emacs>= 26.1
  :ensure t
  ;; :config
  ;; (with-eval-after-load 'orderless
  ;;   (setq completion-styles '(orderless)))
  :after t
  :setq ((completion-styles quote (orderless)))
)

(leaf enable-vertico-and-marginalia
  :preface
  (defun after-init-hook ()
    (vertico-mode)
    (marginalia-mode)
    (savehist-mode))
  :config
  (add-hook 'after-init-hook #'after-init-hook)
)

(leaf embark
  :doc "Conveniently act on minibuffer completions"
  :req "emacs-26.1"
  :tag "convenience" "emacs>=26.1"
  :url "https://github.com/oantolin/embark"
  :added "2021-09-15"
  :emacs>= 26.1
  :ensure t)

;; ========================================
;; auto-complete
;; ========================================
;; 2022-01-26 Wed : companyに変更
(leaf auto-complete
  :doc "Auto Completion for GNU Emacs"
  :req "popup-0.5.0" "cl-lib-0.5"
  :tag "convenience" "completion"
  :url "https://github.com/auto-complete/auto-complete"
  :added "2021-09-15"
  :ensure t
  :require t
  :config
  (global-auto-complete-mode t)
)

(leaf auto-complete-config
  :require t
  :after auto-complete
  :config
  (add-to-list 'ac-modes 'text-mode)         ;; enable text-mode by auto
  (add-to-list 'ac-modes 'fundamental-mode)  ;; fundamental-mode
  (add-to-list 'ac-modes 'org-mode)
  (ac-set-trigger-key "TAB")
  :custom
  ((ac-use-menu-map . t)                   ;; display candidate on menu by C-n/C-p
   (ac-use-fuzzy . t))                      ;; match vague
)

(leaf fuzzy
  ;; Helmの代替
  :doc "Fuzzy Matching"
  :req "emacs-24.3"
  :tag "convenience" "emacs>=24.3"
  :url "https://github.com/auto-complete/fuzzy-el"
  :added "2021-09-22"
  :emacs>= 24.3
  :ensure t
  :require t
)
