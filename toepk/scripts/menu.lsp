;; Main Menu

(defun loaded ()
    (set-screen-size (320 240))
    (set-window-title "Test Game")
    (place-image (0 0) "assets/images/bg/menu.png")
    )

(defun onkey (c)
    (if (eq (key-code "escape") c)
        (quit)
        (nil)
        )
    )

(defun clicked (x y but)
    (if (eq 1 but)
        (if (< 200 y)
            (if (< 160 x)
                (and
                    (ask "Are you sure you\vwant to exit?" (dialog-icon "exclaim"))
                    (quit)
                    )
                (chain-to "levels/00001.json")
                )
            (nil))
        (nil)
        )
    )

(log-message 0 "Loaded menu.lsp")
