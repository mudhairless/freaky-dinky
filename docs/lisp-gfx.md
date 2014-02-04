Available graphics functions:

(set-screen-size (width height))

(set-window-title "title")

(place-image (x y) "image-name")

(clear-screen)

(make-rgb r g b)

(plot-pixel (x y) color)

(draw-line (x1 y1) (x2 y2) color)

(draw-box (x1 y1) (x2 y2) color)

(draw-filled-box (x1 y1) (x2 y2) color)

(draw-circle (x y) radius color)

(draw-filled-circle (x y) radius color)

(paint (x y) fill-color stop-color)

(dialog-icon ["none"|"exclaim"|"warning"|"question"])

(show-message "message" [icon])

(get-string "message" [icon])

(get-integer "message" [icon])

(get-double "message" [icon])

(ask "message" [icon])

(ask-okcancel "message" [icon])
