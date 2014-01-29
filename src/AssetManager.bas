#include once "AssetManager.bi"

type gen_asset
    as any ptr d
    as AssetType t
    as string n
    as ext.File ptr f
    dfree as sub( byval as any ptr )
    declare destructor
end type

destructor gen_asset ()
    if this.dfree <> 0 then
        this.dfree(this.d)
    end if
    n = ""
end destructor


