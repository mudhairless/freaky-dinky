#include once "game-defs.bi"
#define FBEXT_BUILD_NO_GFX_LOADERS
#include once "ext/graphics/image.bi"
#include once "lisp_runtime.bi"

using LISP

define_lisp_function(quit,args)

    next_l = "-"

    return _NIL_

end_lisp_function()

define_lisp_function(setscreensize,args)

    if( _LENGTH(args) < 2 ) then
		_RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
	end if

    _OBJ(p1) = _EVAL(_CAR(args))					'' 1st arg
	_OBJ(p2) = _EVAL(_CAR(_CDR(args)))				'' 2nd arg

    if _IS_INTEGER(p1) andalso _IS_INTEGER(p2) then
	screenres 640, 480, 32
        'screenres *p1, *p2, 32
    else
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    return _NIL_

end_lisp_function()

define_lisp_function(placeimage,args)

    if( _LENGTH(args) < 3 ) then
        _RAISEERROR( LISP_ERR_TOO_FEW_ARGUMENTS )
    end if
    
	_OBJ(p1) = _EVAL(_CAR(args))					'' 1st arg
	_OBJ(p2) = _EVAL(_CAR(_CDR(args)))				'' 2nd arg
	_OBJ(p3) = _EVAL(_CAR(_CDR(_CDR(args))))		'' 3rd arg

    if _IS_INTEGER(p1) andalso _IS_INTEGER(p2) andalso _IS_STRING(p3) then
	dim as AssetType att
        var a = cast(ext.gfx.Image ptr,am->lookup(*(p3->value.str),att))
	if a = 0 then
	    _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
	end if
	screenlock
	a->Display(*p1,*p2,ext.gfx.TRANS_)
	screenunlock
    else
        _RAISEERROR(LISP_ERR_INVALID_ARGUMENT)
    end if

    return _NIL_

end_lisp_function()

define_lisp_function(clearscreen,args)
    screenlock
    cls
    screenunlock
    return _NIL_
end_lisp_function()

sub registerGfxApi
    var ctx = lm->Functions
    BIND_FUNC(ctx,"set-screen-size",setscreensize)
    BIND_FUNC(ctx,"place-image",placeimage)
    BIND_FUNC(ctx,"clear-screen",clearscreen)
    BIND_FUNC(ctx,"quit",quit)

end sub
