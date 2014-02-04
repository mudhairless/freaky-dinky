#include once "game-defs.bi"
#include once "lisp_runtime.bi"
#include once "dialogs.bi"
#include once "ext/algorithms/detail/common.bi"

using LISP

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

sub registerGfxDialogApi
    var ctx = lm->Functions
    BIND_FUNC(ctx,"dialog-icon",dialogicon)
    BIND_FUNC(ctx,"show-message",dialogmsg)
    BIND_FUNC(ctx,"get-string",dialoggetstr)
    BIND_FUNC(ctx,"get-integer",dialoggetint)
    BIND_FUNC(ctx,"get-double",dialoggetdbl)
    BIND_FUNC(ctx,"ask",dialogyesno)
    BIND_FUNC(ctx,"ask-okcancel",dialogokcancel)
end sub
