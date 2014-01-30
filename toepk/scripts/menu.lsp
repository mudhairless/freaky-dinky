;; Main Menu
(defun loaded ()
    (princ "Hi there")
    (set-screen-size 320 240)
    (place-image 0 0 "assets/images/bg/menu.png")
    )

(defun onkey (code)
    (quit)
    )
