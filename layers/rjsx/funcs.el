;; flycheck
(defun spacemacs//rjsx-use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (global-eslint (executable-find "eslint"))
         (local-eslint (expand-file-name "node_modules/.bin/eslint"
                                         root))
         (eslint (if (file-executable-p local-eslint)
                     local-eslint
                   global-eslint)))
    (setq-local flycheck-javascript-eslint-executable eslint)))

;; emmet-mode
(defun spacemacs//setup-emmet-mode-for-rjsx ()
  (emmet-mode 0)
  (setq-local emmet-expand-jsx-className? t))

;; rjsx-mode
(defun spacemacs//rjsx-end-symbol-alignment ()
  (defun react-tag-fix ()
    (define-key evil-insert-state-map (kdb "C-d") nil))
  (add-hook 'rjsx-mode-hook 'react-tag-fix)
  (defadvice js-jsx-indent-line (after js-jsx-indent-line-after-hack activate)
    "Workaround sgml-mode and follow airbnb component style."
    rjsx-mode  (save-excursion
                 (beginning-of-line)
                 (if (looking-at-p "^ +\/?> *$")
                     (delete-char sgml-basic-offset)))))
