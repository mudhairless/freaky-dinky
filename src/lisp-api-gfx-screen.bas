#include once "game-defs.bi"
#include once "lisp_runtime.bi"

using LISP

define_lisp_function(drawline,args)

    if screenptr = 0 then
        return _NIL_
    else

        _OBJ(p1) = _EVAL(_CAR(_CAR(args)))
        _OBJ(p2) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(p3) = _EVAL(_CAR(_CAR(_CDR(args))))
        _OBJ(p4) = _EVAL(_CAR(_CDR(_CAR(_CDR(args)))))
        _OBJ(p5) = _EVAL(_CAR(_CDR(_CDR((args)))))

        screenlock
                line (*p1,*p2)-(*p3,*p4), *p5
                print cast(integer,*p4)
        screenunlock

        return _T_
    end if
        
end_lisp_function()

define_lisp_function(paint,args)

    if screenptr = 0 then
        return _NIL_
    else
        _OBJ(x) = _EVAL(_CAR(_CAR(args)))
        _OBJ(y) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(pc) = _EVAL(_CAR(_CDR(args)))
        _OBJ(ec) = _EVAL(_CAR(_CDR(_CDR(args))))

        screenlock
                paint (*x,*y), *pc, *ec
        screenunlock

        return _T_
    end if
    
end_lisp_function()

define_lisp_function(drawbox,args)

    if screenptr = 0 then
        return _NIL_
    else
        _OBJ(p1) = _EVAL(_CAR(_CAR(args)))
        _OBJ(p2) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(p3) = _EVAL(_CAR(_CAR(_CDR(args))))
        _OBJ(p4) = _EVAL(_CAR(_CDR(_CAR(_CDR(args)))))
        _OBJ(p5) = _EVAL(_CAR(_CDR(_CDR((args)))))
    
        screenlock
                line (*p1,*p2)-(*p3,*p4), *p5, B
        screenunlock
    
        return _T_
    end if
    
end_lisp_function()

define_lisp_function(drawfbox,args)

    if screenptr = 0 then
        return _NIL_
    else
        _OBJ(p1) = _EVAL(_CAR(_CAR(args)))
        _OBJ(p2) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(p3) = _EVAL(_CAR(_CAR(_CDR(args))))
        _OBJ(p4) = _EVAL(_CAR(_CDR(_CAR(_CDR(args)))))
        _OBJ(p5) = _EVAL(_CAR(_CDR(_CDR((args)))))
    
        screenlock
                line (*p1,*p2)-(*p3,*p4), *p5, BF
        screenunlock
    
        return _T_
    end if
    
end_lisp_function()

define_lisp_function(drawcircle,args)

    if screenptr = 0 then
        return _NIL_
    else
        _OBJ(x) = _EVAL(_CAR(_CAR(args)))
        _OBJ(y) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(r) = _EVAL(_CAR(_CDR(args)))
        _OBJ(c) = _EVAL(_CAR(_CDR(_CDR(args))))
    
        screenlock
                circle (*x,*y), *r, *c
        screenunlock
    
        return _T_
    end if
    
end_lisp_function()

define_lisp_function(drawfcircle,args)

    if screenptr = 0 then
        return _NIL_
    else
        _OBJ(x) = _EVAL(_CAR(_CAR(args)))
        _OBJ(y) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(r) = _EVAL(_CAR(_CDR(args)))
        _OBJ(c) = _EVAL(_CAR(_CDR(_CDR(args))))
    
        screenlock
                circle (*x,*y), *r, *c
                paint (*x,*y),*c, *c
        screenunlock
    
        return _T_
    end if
    
end_lisp_function()

define_lisp_function(plotpixel,args)

    if screenptr = 0 then
        return _NIL_
    else
        if( _LENGTH(args) <> 2 ) then
                _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
        end if
        
        _OBJ(p1) = _EVAL(_CAR(_CAR(args)))
        _OBJ(p2) = _EVAL(_CAR(_CDR(_CAR(args))))
        _OBJ(p3) = _EVAL(_CAR(_CDR(args)))

        screenlock
            pset (*p1,*p2),*p3
        screenunlock

        return _T_
    end if
    
end_lisp_function()


sub registerGfxScreenApi

    var ctx = lm->Functions

    BIND_FUNC(ctx,"plot-pixel",plotpixel)
    BIND_FUNC(ctx,"draw-line",drawline)
    BIND_FUNC(ctx,"draw-box",drawbox)
    BIND_FUNC(ctx,"draw-filled-box",drawfbox)
    BIND_FUNC(ctx,"draw-circle",drawcircle)
    BIND_FUNC(ctx,"draw-filled-circle",drawfcircle)
    BIND_FUNC(ctx,"paint",paint)

end sub
