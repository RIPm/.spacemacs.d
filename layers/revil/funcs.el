(defun spacemacs//mc-spaceline-spacemacs-theme (&rest additional-segments)
  "Install the modeline used by Spacemacs.
ADDITIONAL-SEGMENTS are inserted on the right, between `global' and
`buffer-position'."

  (spaceline-define-segment emc
    "Show evil-mc cursor count in modeline"
    (when (> (evil-mc-get-cursor-count) 1)
      (format "EMC:%d" (evil-mc-get-cursor-count)))
    )

  (apply 'spaceline--theme
         '((persp-name
            workspace-number
            window-number
            emc)
           :fallback evil-state
           :face highlight-face
           :priority 0)
         '((buffer-modified buffer-size buffer-id remote-host)
           :priority 5)
         additional-segments))
