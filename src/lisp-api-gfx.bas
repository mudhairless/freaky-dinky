#include once "game-defs.bi"
#define FBEXT_BUILD_NO_GFX_LOADERS
#include once "ext/graphics/image.bi"
#include once "lisp_runtime.bi"
#include once "ext/log.bi"
#include once "dialogs.bi"
#include once "ext/algorithms/detail/common.bi"

using LISP

define_lisp_function(setscreensize,args)

    if( _LENGTH(args) <> 1 ) then
        _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
    end if

    _OBJ(p1) = _EVAL(_CAR(_CAR(args)))
    _OBJ(p2) = _EVAL(_CAR(_CDR(_CAR(args))))

    if _IS_INTEGER(p1) andalso _IS_INTEGER(p2) then
        screenres *p1, *p2, 32
    else
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    if screenptr = 0 then
        return _NIL_
    else
        return _T_
    end if

end_lisp_function()

define_lisp_function(placeimage,args)

    if( _LENGTH(args) <> 2 ) then
        _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
    end if
    
    _OBJ(p1) = _EVAL(_CAR(_CAR(args)))                                        '' 1st arg
    _OBJ(p2) = _EVAL(_CAR(_CDR(_CAR(args))))                          '' 2nd arg
    _OBJ(p3) = _EVAL(_CAR(_CDR(args)))            '' 3rd arg

    if _IS_INTEGER(p1) andalso _IS_INTEGER(p2) andalso _IS_STRING(p3) then
        dim as AssetType att
        var a = cast(ext.gfx.Image ptr,am->lookup(*(p3->value.str),att))
        if a = 0 then
            _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
            return _NIL_
        end if
        screenlock
        a->Display(*p1,*p2,ext.gfx.TRANS_)
        screenunlock
        return _T_
    else
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    return _NIL_

end_lisp_function()

define_lisp_function(clearscreen,args)
    screenlock
    cls
    screenunlock
    return _T_
end_lisp_function()

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

define_lisp_function(makergb,args)

        if( _LENGTH(args) < 3 ) then
                _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
        end if

        _OBJ(p1) = _EVAL(_CAR(args))                                    '' 1st arg
        _OBJ(p2) = _EVAL(_CAR(_CDR(args)))                              '' 2nd arg
        _OBJ(p3) = _EVAL(_CAR(_CDR(_CDR(args))))                '' 3rd arg

        _OBJ(res) = _NEW(OBJECT_TYPE_INTEGER)
        res->value.int = rgb(*p1,*p2,*p3)

        return res
        
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

define_lisp_function(createimage,args)

    if( _LENGTH(args) <> 3 ) then
        _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
        return _NIL_
    end if

    dim as integer _w = *_EVAL(_CAR(args))
    dim as integer _h = *_EVAL(_CAR(_CDR(args)))                              '' 2nd arg
    dim as string _n = *(_EVAL(_CAR(_CDR(_CDR(args))))->value.str)

    var ni = new ext.gfx.Image(_w,_h)
    if ni = 0 then return _NIL_

    if am = 0 then return _NIL_

    am->add(_n,image_asset,0,ni)
    return _T_

end_lisp_function()

define_lisp_function(setwintitle,args)

    _OBJ(wt) = _EVAL(_CAR(args))

    if not _IS_STRING(wt) then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    windowtitle *(wt->value.str)

    return _T_
end_lisp_function()

define_lisp_function(dialogicon,args)

    if _LENGTH(args) <> 1 then
        _RAISEERROR(LISP_ERR_TOO_FEW_ARGUMENTS)
        return _NIL_
    end if

    _OBJ(ret)

    _OBJ(tp) = _EVAL(_CAR(args))
    var tps = *(tp->value.str)

    select case tps
    case "exclaim"
        ret = _NEW_INTEGER(1)
    case "warning"
        ret = _NEW_INTEGER(2)
    case "question"
        ret = _NEW_INTEGER(3)
    case else
        ret = _NEW_INTEGER(0)
    end select

    return ret

end_lisp_function()

define_lisp_function(dialogmsg,args)

    if _LENGTH(args) > 2 orelse _LENGTH(args) = 0 then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    if _LENGTH(args) = 2 then
    
        _OBJ(msg) = _EVAL(_CAR(args))
        _OBJ(icon) = _EVAL(_CAR(_CDR(args)))
    
        dialog.message(*(msg->value.str),*icon)
    
        return _T_
    else
        _OBJ(msg) = _EVAL(_CAR(args))
        dialog.message(*(msg->value.str))
        return _T_
    end if

end_lisp_function()

define_lisp_function(dialoggetstr,args)

    if _LENGTH(args) > 2 orelse _LENGTH(args) = 0 then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    if _LENGTH(args) = 2 then
    
        _OBJ(msg) = _EVAL(_CAR(args))
        _OBJ(icon) = _EVAL(_CAR(_CDR(args)))
    
        var ret = dialog.input_str(*(msg->value.str),,*icon)

        dim as zstring ptr retz = allocate(len(ret)+1)

        ext.memcpy(retz,@(ret[0]),len(ret))
        retz[len(ret)] = 0
        _OBJ(reto) = _NEW(OBJECT_TYPE_STRING)

        reto->value.str = retz
    
        return reto
    else
        _OBJ(msg) = _EVAL(_CAR(args))

        var ret = dialog.input_str(*(msg->value.str))

        dim as zstring ptr retz = allocate(len(ret)+1)

        ext.memcpy(retz,@(ret[0]),len(ret))
        retz[len(ret)] = 0
        _OBJ(reto) = _NEW(OBJECT_TYPE_STRING)

        reto->value.str = retz

        return reto
        
    end if

end_lisp_function()

define_lisp_function(dialoggetdbl,args)

    if _LENGTH(args) > 2 orelse _LENGTH(args) = 0 then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    if _LENGTH(args) = 2 then
    
        _OBJ(msg) = _EVAL(_CAR(args))
        _OBJ(icon) = _EVAL(_CAR(_CDR(args)))
        var nu = 0.0
        var ret = dialog.input_dbl(*(msg->value.str),@nu,*icon)

        _OBJ(reto) = _NEW(OBJECT_TYPE_REAL)
        reto->value.flt = ret
    
        return reto
    else
        _OBJ(msg) = _EVAL(_CAR(args))
        var nu = 0.0
        var ret = dialog.input_dbl(*(msg->value.str),@nu)

        _OBJ(reto) = _NEW(OBJECT_TYPE_REAL)
        reto->value.flt = ret
        return reto
        
    end if

end_lisp_function()


define_lisp_function(dialoggetint,args)

    if _LENGTH(args) > 2 orelse _LENGTH(args) = 0 then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    if _LENGTH(args) = 2 then
    
        _OBJ(msg) = _EVAL(_CAR(args))
        _OBJ(icon) = _EVAL(_CAR(_CDR(args)))
        var nu = 0
        var ret = dialog.input_int(*(msg->value.str),@nu,*icon)

        _OBJ(reto) = _NEW_INTEGER(ret)
    
        return reto
    else
        _OBJ(msg) = _EVAL(_CAR(args))
        var nu = 0
        var ret = dialog.input_int(*(msg->value.str),@nu)

        _OBJ(reto) = _NEW_INTEGER(ret)

        return reto
        
    end if

end_lisp_function()

define_lisp_function(dialogyesno,args)

    if _LENGTH(args) > 2 orelse _LENGTH(args) = 0 then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    if _LENGTH(args) = 2 then
    
        _OBJ(msg) = _EVAL(_CAR(args))
        _OBJ(icon) = _EVAL(_CAR(_CDR(args)))
    
        var ret = dialog.question(*(msg->value.str),,*icon)

        if ret = dialog.response.yes then return _T_

    else
        _OBJ(msg) = _EVAL(_CAR(args))

        var ret = dialog.question(*(msg->value.str))

        if ret = dialog.response.yes then return _T_

    end if

    return _NIL_

end_lisp_function()

define_lisp_function(dialogokcancel,args)

    if _LENGTH(args) > 2 orelse _LENGTH(args) = 0 then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
        return _NIL_
    end if

    if _LENGTH(args) = 2 then
    
        _OBJ(msg) = _EVAL(_CAR(args))
        _OBJ(icon) = _EVAL(_CAR(_CDR(args)))
    
        var ret = dialog.question(*(msg->value.str),,*icon)

        if ret = dialog.response.ok then return _T_

    else
        _OBJ(msg) = _EVAL(_CAR(args))

        var ret = dialog.question(*(msg->value.str))

        if ret = dialog.response.ok then return _T_

    end if

    return _NIL_

end_lisp_function()

sub registerGfxApi
    var ctx = lm->Functions
    BIND_FUNC(ctx,"set-screen-size",setscreensize)
    BIND_FUNC(ctx,"set-window-title",setwintitle)
    BIND_FUNC(ctx,"create-image",createimage)
    BIND_FUNC(ctx,"place-image",placeimage)
    BIND_FUNC(ctx,"clear-screen",clearscreen)
    BIND_FUNC(ctx,"make-rgb",makergb)
    BIND_FUNC(ctx,"plot-pixel",plotpixel)
    BIND_FUNC(ctx,"draw-line",drawline)
    BIND_FUNC(ctx,"draw-box",drawbox)
    BIND_FUNC(ctx,"draw-filled-box",drawfbox)
    BIND_FUNC(ctx,"draw-circle",drawcircle)
    BIND_FUNC(ctx,"draw-filled-circle",drawfcircle)
    BIND_FUNC(ctx,"paint",paint)
    BIND_FUNC(ctx,"dialog-icon",dialogicon)
    BIND_FUNC(ctx,"show-message",dialogmsg)
    BIND_FUNC(ctx,"get-string",dialoggetstr)
    BIND_FUNC(ctx,"get-integer",dialoggetint)
    BIND_FUNC(ctx,"get-double",dialoggetdbl)
    BIND_FUNC(ctx,"ask",dialogyesno)
    BIND_FUNC(ctx,"ask-okcancel",dialogokcancel)
end sub
