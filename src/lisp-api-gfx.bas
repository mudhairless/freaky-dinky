#include once "game-defs.bi"
#include once "lisp_runtime.bi"

declare sub registerGfxDialogApi
declare sub registerGfxImageApi
declare sub registerGfxScreenApi
declare sub registerSpriteGfxApi

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

define_lisp_function(clearscreen,args)
    cls
    return _T_
end_lisp_function()

define_lisp_function(screenlock,args)
    screenlock
    return _T_
end_lisp_function()

define_lisp_function(screenunlock,args)
    screenunlock
    return _T_
end_lisp_function()

define_lisp_function(makergb,args)

        if( _LENGTH(args) < 3 ) then
                _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
        end if

        _OBJ(p1) = _EVAL(_CAR(args))
        _OBJ(p2) = _EVAL(_CAR(_CDR(args)))
        _OBJ(p3) = _EVAL(_CAR(_CDR(_CDR(args))))

        _OBJ(res) = _NEW(OBJECT_TYPE_INTEGER)
        res->value.int = rgb(*p1,*p2,*p3)

        return res
        
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

define_lisp_function(waitms,args)

    _OBJ(wt) = _EVAL(_CAR(args))

    sleep *wt,1

    return _T_

end_lisp_function()


sub registerGfxApi
    var ctx = lm->Functions
    BIND_FUNC(ctx,"set-screen-size",setscreensize)
    BIND_FUNC(ctx,"set-window-title",setwintitle)
    BIND_FUNC(ctx,"clear-screen",clearscreen)
    BIND_FUNC(ctx,"make-rgb",makergb)
    BIND_FUNC(ctx,"lock-screen",screenlock)
    BIND_FUNC(ctx,"unlock-screen",screenunlock)
    BIND_FUNC(ctx,"wait-ms",waitms)

    registerGfxScreenApi
    registerGfxImageApi
    registerGfxDialogApi
    registerGfxScreenApi
    registerSpriteGfxApi
end sub
