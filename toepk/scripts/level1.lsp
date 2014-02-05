;; Level 1
(setq si 0)
(setq posx -1)
(setq posy -1)
(setq spx 160)
(setq spy 120)

(defun loaded ()
    (log-message 0 "Loaded level 1")
    (place-image (0 0) "assets/images/bg/level1.jpg")
    (show-message "Welcome to the land of\vTest Game!" (dialog-icon "exclaim"))
    (set-sprite-pos "player" (spx spy))
    )

(defun tick ()
    (lock-screen)
    (clear-screen)
    (place-image (0 0) "assets/images/bg/level1.jpg")
    (display-sprite "player" si)
    (unlock-screen)
    (wait-ms 50)
    (setq si (+ si 1))
    (if (eq si 4)
        (setq si 0)
        (nil)
        )
    (if (eq spx posx)
        (log-message 0 "spx = posx")
        (and
            (log-message 0 "spx <> posx")
            (if (> -1 posx)
                (if (> posx spx)
                    (and
                        (update-sprite-pos "player" (1 0))
                        (setq spx (+ spx 1))
                        (log-message 0 spx)
                        )
                    (and
                        (update-sprite-pos "player" (-1 0))
                        (setq spx (- spx 1))
                        (log-message 0 spx)
                        )
                    )
                (log-message 0 "posx =< -1")
                )
            )
        )
    )

(defun click (x y b)
    (log-message 0 x)
    (log-message 0 y)
    (log-message 0 b)
    (if (eq 1 b)
        (and
            (setq posx x)
            (setq posy y)
            (log-message 0 "updated destination")
            (log-message 0 posx)
            (log-message 0 posy)
            )
        (nil)
        )
    )

(defun key-press (c)
    (if (eq (key-code "escape") c)
        (quit)
        (if (eq (key-code "left") c)
            (update-sprite-pos "player" (-1 0))
            (if (eq (key-code "right") c)
                (update-sprite-pos "player" (1 0))
                (if (eq (key-code "up") c)
                    (update-sprite-pos "player" (0 -1))
                    (if (eq (key-code "down") c)
                        (update-sprite-pos "player" (0 1))
                        (if (eq (key-code "window-close") c)
                            (and
                                (log-message 0 "user requested window close")
                                (quit)
                                )
                            (nil)
                            )
                        )
                    )
                )
            )
        )
    )
