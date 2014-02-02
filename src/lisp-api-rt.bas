'lisp runtime functions
#include once "ext/log.bi"
#include once "game-defs.bi"
#define FBEXT_BUILD_NO_GFX_LOADERS
#include once "lisp_runtime.bi"
using LISP

function getLispError() as string
    return "Error (" & lm->ErrorCode & ")[" & lm->ErrorLine & "|" & lm->ErrorColumn & "]: " & lm->ErrorText()
end function

define_lisp_function(quit,args)

    if( _LENGTH(args) = 0 ) then
        next_l = "-"
        return _T_
    else
	_RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

end_lisp_function()

define_lisp_function(chainto,args)

    if( _LENGTH(args) <> 1 ) then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    _OBJ(nextf) = _EVAL(_CAR(args))
    if( _IS_STRING(nextf) ) then
        next_l = *(nextf->value.str)
    else
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    return _T_

end_lisp_function()

define_lisp_function(includefile,args)

	_OBJ(p1) = _EVAL(_CAR(args))
	var f = pakf->open( *(p1->value.str) )
    if f = null then
        FATAL("File (" & *(p1->value.str) & ")  not found in archive.")
        return _NIL_
    end if

    if f->open() = (not 0) then
        FATAL("Unable to open file(" & *(p1->value.str) & ").")
        return _NIL_
    end if

    dim fs as zstring ptr
    var fsl = f->tobuffer(fs)

    var ret = lm->Eval(*fs)

    delete[] cast(ubyte ptr,fs)

	if ret <> 0 then
        WARN("File (" & *(p1->value.str) & ") " & getLispError)
        return _NIL_
    else
        return _T_
    end if

end_lisp_function()

define_lisp_function(logmsg,args)

    _OBJ(lvl) = _EVAL(_CAR(args))
    _OBJ(msg) = _EVAL(_CAR(_CDR(args)))

    DEBUG("msg dtype: " & msg->dtype)

    var rmsg = ""
    if not _IS_STRING(msg) then
        if _IS_INTEGER(msg) then
            rmsg = "Value: " & str(cast(integer,*msg))
        elseif _IS_REAL(msg) then
            rmsg = "Value: " & str(cast(double,*msg))
        else
            rmsg = "Unsupported value."
        end if
    else
        rmsg = *(msg->value.str)
    end if

    select case cast(integer,*lvl)
    case 0
        DEBUG(rmsg)
    case 1
        INFO(rmsg)
    case 2
        WARN(rmsg)
    case else
        FATAL(rmsg)
    end select

    return _T_

end_lisp_function()

define_lisp_function(key,args)

    _OBJ(kc) = _EVAL(_CAR(args))

    if( not _IS_STRING(kc) ) then
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    var ret = 0

    select case *(kc->value.str)
    case "escape"
        ret = 27
    case "space"
        ret = 32
    case "left"
        ret = 65355
    case "right"
        ret = 65357
    case "up"
        ret = 65352
    case "down"
        ret = 65360
    case "window-close"
        ret = 65387
    case else
        ret = 0
    end select
    
    _OBJ(res) = _NEW_INTEGER(ret)

    return res

end_lisp_function()

sub registerRTapi

    var ctx = lm->Functions
    BIND_FUNC(ctx,"include-file",includefile)
    BIND_FUNC(ctx,"log-message",logmsg)
    BIND_FUNC(ctx,"quit",quit)
    BIND_FUNC(ctx,"chain-to",chainto)
    BIND_FUNC(ctx,"key-code",key)

end sub

