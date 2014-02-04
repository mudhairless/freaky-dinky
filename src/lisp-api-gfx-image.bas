#include once "game-defs.bi"
#define FBEXT_BUILD_NO_GFX_LOADERS
#include once "ext/graphics/image.bi"
#include once "lisp_runtime.bi"

using LISP

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

sub registerGfxImageApi
    var ctx = lm->Functions
    BIND_FUNC(ctx,"create-image",createimage)
    BIND_FUNC(ctx,"place-image",placeimage)
end sub
