;; Main Menu

(defun loaded ()
    (set-screen-size 320 240)
    (place-image 0 0 "assets/images/bg/menu.png")
    )

(defun onkey (c)
    (log-message 0 c)
    (if (eq (key-code "escape") c)
        (quit)
        ( )
        (princ c)
        )
    )

(defun clicked (x y but)
    (log-message 0 "clicked")
    (if (eq 1 but)
        (plot-pixel x y (make-rgb 255 0 0))
        ( )
        (plot-pixel x y (make-rgb 0 255 0))
        )
    )

(log-message 0 "Loaded menu.lsp")
