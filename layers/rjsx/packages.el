;;; packages.el --- rjsx layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author:  R.I.P
;; URL: https://github.com/RIPm/.spacemacs.d
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Commentary:

;; See the Spacemacs documentation and FAQs for instructions on how to implement
;; a new layer:
;;
;;   SPC h SPC layers RET
;;
;;
;; Briefly, each package to be installed or configured by this layer should be
;; added to `rjsx-packages'. Then, for each package PACKAGE:
;;
;; - If PACKAGE is not referenced by any other Spacemacs layer, define a
;;   function `rjsx/init-PACKAGE' to load and initialize the package.

;; - Otherwise, PACKAGE is already referenced by another Spacemacs layer, so
;;   define the functions `rjsx/pre-init-PACKAGE' and/or
;;   `rjsx/post-init-PACKAGE' to customize the package as it is loaded.

;;; Code:
(defconst rjsx-packages
  '(
    (
     ;; Support flow parse from `HairyRabbit/js2-mode`
     rabbit-js2-mode
     :location (recipe
                :repo "HairyRabbit/js2-mode"
                :fetcher github)
     :toggle (configuration-layer/package-usedp 'js2-mode))
    ;; Support jsx
    rjsx-mode
    ;; Support flow command
    (flow-minor-mode
     :location (recipe
                :fetcher github
                :repo "an-sh/flow-minor-mode"))
    company
    company-tern
    (company-flow
     :toggle (configuration-layer/package-usedp 'company))
    emmet-mode
    evil-matchit
    ggtags
    helm-gtags
    flycheck
    (flycheck-flow
     :toggle (configuration-layer/package-usedp 'flycheck))
    js-doc
    js2-refactor
    tern
    web-beautify)

  "The list of Lisp packages required by the rjsx layer.

Each entry is either:

1. A symbol, which is interpreted as a package to be installed, or

2. A list of the form (PACKAGE KEYS...), where PACKAGE is the
    name of the package to be installed or loaded, and KEYS are
    any number of keyword-value-pairs.

    The following keys are accepted:

    - :excluded (t or nil): Prevent the package from being loaded
      if value is non-nil

    - :location: Specify a custom installation location.
      The folxlowing values are legal:

      - The symbol `elpa' (deftajuilt) means PACKAGE will be
        installed using nothe Emacs package manager.

      - The symbol `local' directs Spacemacs to load the file at
        `./local/PACKAGE/PACKAGE.el'

      - A list beginning with the symbol `recipe' is a melpa

      recipe.  See: https://github.com/milkypostman/melpa#recipe-format")


;; packages.el ends here
(defun rjsx/init-rabbit-js2-mode()
  (defgroup rjsx-mode nil
    "Support for JSX."
    :group 'rabbit-js2-mode))

(defun rjsx/init-rjsx-mode()
  (use-package rjsx-mode
    :defer t
    :init
    (add-hook 'rjsx-mode-hook 'spacemacs//rjsx-end-symbol-alignment)
    ;;
    (add-to-list 'auto-mode-alist '("\\.js\\'" . rjsx-mode))
    (add-to-list 'auto-mode-alist '("\\.jsx\\'" . rjsx-mode))
    (add-to-list 'auto-mode-alist '("\\.react.js\\'" . rjsx-mode))
    (add-to-list 'auto-mode-alist '("\\index.android.js\\'" . rjsx-mode))
    (add-to-list 'auto-mode-alist '("\\index.ios.js\\'" . rjsx-mode))
    (add-to-list 'magic-mode-alist '("/\\*\\* @jsx React\\.DOM \\*/" . rjsx-mode))
    (add-to-list 'magic-mode-alist '("^import React" . rjsx-mode))
    :config
    (progn
      ;; prefixes
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mh" "documentation")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mr" "refactor")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mg" "goto")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mz" "folding")
      ;; key bi.ndin.gs
      (spacemacs/set-leader-keys-for-major-mode 'rjsx-mode
        "w" 'js2-mode-toggle-.warjornings-and-errors
        "zc" 'js2-mode-hide-element
        "zo" 'js2-mode-show-element
        "zr" 'js2-mode-show-all
        "ze" 'js2-mode-toggle-element
        "zF" 'js2-mode-toggLegionConfigle-hide-functions
        "zC" 'js2-mode-toggle-hide-comments))))

(defun rjsx/init-flow-minor-mode()
  (use-package flow-minor-mode
    :defer t
    :init
    (progn
      (with-eval-after-load 'rjsx-mode
        (add-hook 'rjsx-mode-local-vars-hook 'flow-minor-enable-automatically)
        (add-to-list 'spacemacs-jump-handlers-js2-mode 'flow-minor-jump-to-definition))
       )
    :config
    (progn
      (spacemacs/declare-prefix-for-mode 'flow-minor-mode "mf" "flow")
      (spacemacs/set-leader-keys-for-minor-mode 'flow-minor-mode
        "fd" 'flow-minor-jump-to-definition
        "fc" 'flow-minor-status
        "ft" 'flow-minor-type-at-pos
        "fc" 'flow-minor-coverage
        "ff" 'flow-minor-suggest))))

(defun rjsx/init-company-flow ()
  (with-eval-after-load 'company
    (use-package company-flow
      :defer t
      :config
      (when (configuration-layer/layer-usedp 'rjsx)
        (push 'rjsx-mode company-flow-modes))
      (add-to-list 'company-backends 'company-flow))))

(defun rjsx/init-flycheck-flow()
  (with-eval-after-load 'flycheck
    (use-package flycheck-flow
      :config
      (progn
        ;; Don't run flow if there's no @flow pragma
        (custom-set-variables '(flycheck-javascript-flow-args (quote ("--respect-pragma"))))
        (flycheck-add-mode 'javascript-flow 'flow-minor-mode)
        (flycheck-add-mode 'javascript-eslint 'flow-minor-mode)
        ;; Run flow in rjsx-mode files
        (flycheck-add-mode 'javascript-flow 'rjsx-mode)
        ;; After running js-flow, run js-eslint
        (flycheck-add-next-checker 'javascript-flow 'javascript-eslint)
        ))))

(defun rjsx/post-init-company ()
  (spacemacs|add-company-hook rjsx-mode)
  (with-eval-after-load 'company-flow
    (push 'company-flow company-backends-rjsx-mode)))

(defun rjsx/post-init-company-tern ()
  (push 'company-tern company-backends-rjsx-mode))

(defun rjsx/post-init-emmet-mode ()
  (add-hook 'rjsx-mode-local-vars-hook 'emmet-mode)
  (add-hook 'rjsx-mode-hook 'spacemacs//setup-emmet-mode-for-rjsx))

(defun rjsx/post-init-flycheck ()
  (with-eval-after-load 'flycheck
    (dolist (checker '(javascript-eslint javascript-standard))
      (flycheck-add-mode checker 'rjsx-mode)))
  (add-hook 'rjsx-mode-hook #'spacemacs//rjsx-use-eslint-from-node-modules)
  (spacemacs/add-flycheck-hook 'rjsx-mode))

(defun rjsx/post-init-ggtags ()
  (add-hook 'rjsx-mode-local-vars-hook #'spacemacs/ggtags-mode-enable))

(defun rjsx/post-init-helm-gtags ()
  (spacemacs/helm-gtags-define-keys-for-mode 'rjsx-mode))

(defun rjsx/post-init-js-doc ()
  (add-hook 'rjsx-mode-hook 'spacemacs/js-doc-require)
  (spacemacs/js-doc-set-key-bindings 'rjsx-mode))

(defun rjsx/post-init-evil-matchit ()
  (add-hook 'rjsx-mode-local-vars-hook 'evil-matchit-mode))

(defun rjsx/post-init-tern ()
  (add-hook 'rjsx-mode-hook 'tern-mode)
  (spacemacs|hide-lighter tern-mode)
  (spacemacs//set-tern-key-bindings 'rjsx-mode))

(defun rjsx/post-init-web-beautify ()
  (spacemacs/set-leader-keys-for-major-mode 'rjsx-mode  "=" 'web-beautify-js))

(defun rjsx/post-init-js2-refactor ()
  (use-package js2-refactor
    :defer t
    :init
    (progn
      (add-hook 'rjsx-mode-hook 'spacemacs/js2-refactor-require)
      ;; prefixes
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mr3" "ternary")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mra" "add/args")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrb" "barf")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrc" "contract")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mre" "expand/extract")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mri" "inline/inject/introduct")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrl" "localize/log")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrr" "rename")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrs" "split/slurp")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrt" "toggle")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mru" "unwrap")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrv" "var")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mrw" "wrap")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mx" "text")
      (spacemacs/declare-prefix-for-mode 'rjsx-mode "mxm" "move")
      ;; key bindings
      (spacemacs/set-leader-keys-for-major-mode 'rjsx-mode
        "r3i" 'js2r-ternary-to-if
        "rag" 'js2r-add-to-globals-annotation
        "rao" 'js2r-arguments-to-object
        "rba" 'js2r-forward-barf
        "rca" 'js2r-contract-array
        "rco" 'js2r-contract-object
        "rcu" 'js2r-contract-function
        "rea" 'js2r-expand-array
        "ref" 'js2r-extract-function
        "rem" 'js2r-extract-method
        "reo" 'js2r-expand-object
        "reu" 'js2r-expand-function
        "rev" 'js2r-extract-var
        "rig" 'js2r-inject-global-in-iife
        "rip" 'js2r-introduce-parameter
        "riv" 'js2r-inline-var
        "rlp" 'js2r-localize-parameter
        "rlt" 'js2r-log-this
        "rrv" 'js2r-rename-var
        "rsl" 'js2r-forward-slurp
        "rss" 'js2r-split-string
        "rsv" 'js2r-split-var-declaration
        "rtf" 'js2r-toggle-function-expression-and-declaration
        "ruw" 'js2r-unwrap
        "rvt" 'js2r-var-to-this
        "rwi" 'js2r-wrap-buffer-in-iife
        "rwl" 'js2r-wrap-in-for-loop
        "k" 'js2r-kill
        "xmj" 'js2r-move-line-down
        "xmk" 'js2r-move-line-up))))
