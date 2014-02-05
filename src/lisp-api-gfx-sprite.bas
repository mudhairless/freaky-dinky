#include once "game-defs.bi"
#include once "lisp_runtime.bi"
#define FBEXT_BUILD_NO_GFX_LOADERS
#include once "ext/graphics/sprite.bi"

using LISP

define_lisp_function(spritesetpos,args)

    _OBJ(spr) = _EVAL(_CAR(args))
    _OBJ(x) = _EVAL(_CAR(_CAR(_CDR(args))))
    _OBJ(y) = _EVAL(_CAR(_CDR(_CAR(_CDR(args)))))

    dim as AssetType atype
    var s = cast(ext.gfx.Sprite ptr,am->lookup(*(spr->value.str),atype))

    if s = 0 then return _NIL_

    s->Position(cint(*x),cint(*y))

    return _T_

end_lisp_function()

define_lisp_function(spriteupdatepos,args)

    _OBJ(spr) = _EVAL(_CAR(args))
    _OBJ(x) = _EVAL(_CAR(_CAR(_CDR(args))))
    _OBJ(y) = _EVAL(_CAR(_CDR(_CAR(_CDR(args)))))

    dim as AssetType atype
    var s = cast(ext.gfx.Sprite ptr,am->lookup(*(spr->value.str),atype))

    if s = 0 then return _NIL_

    s->Update(cint(*x),cint(*y))

    return _T_

end_lisp_function()

define_lisp_function(spritedisplay,args)

    _OBJ(spr) = _EVAL(_CAR(args))
    _OBJ(index) = _EVAL(_CAR(_CDR(args)))

    dim as AssetType atype
    var s = cast(ext.gfx.Sprite ptr,am->lookup(*(spr->value.str),atype))

    if s = 0 then return _NIL_

    s->DrawImage(*index,,ext.gfx.TRANS_)

    return _T_

end_lisp_function()

sub registerSpriteGfxApi
    var ctx = lm->Functions
    BIND_FUNC(ctx,"set-sprite-pos",spritesetpos)
    BIND_FUNC(ctx,"update-sprite-pos",spriteupdatepos)
    BIND_FUNC(ctx,"display-sprite",spritedisplay)
end sub
