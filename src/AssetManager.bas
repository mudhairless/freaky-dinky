#include once "ext/algorithms/detail/common.bi"
#include once "ext/json.bi"
#include once "ext/graphics/image.bi"
#include once "AssetManager.bi"
#include once "fbgfx.bi"

type gen_asset
    as any ptr d
    as AssetType t
    as string n
    as ext.File ptr f
    as uinteger rc
    dfree as sub( byval as any ptr )
end type

constructor AssetManager
    m_na = 0
    m_s = 30
    m_assets = new gen_asset[m_s]
end constructor

destructor AssetManager
    if m_assets <> 0 then
        delete[] cast(gen_asset ptr,m_assets)
    end if
end destructor

sub AssetManager.m_resize( )

    var m_assets_ = cast(gen_asset ptr,m_assets)
    var newsize = cuint(m_s * 1.5)
    var newptr = new gen_asset[newsize]
    ext.memcpy(newptr,m_assets_,sizeof(gen_asset)*m_s)
    delete[] cast(gen_asset ptr,m_assets)
    m_assets = newptr
    m_s = newsize
    
end sub

sub AssetManager.m_compact( )

    var fcnt = 0u
    var cnt = -1
    var m_assets_ = cast(gen_asset ptr,m_assets)

    for i as uinteger = 0 to m_s -1
        if m_assets_[i].rc = 0 then
            cnt = i
        else
            if cnt >= 0 then
                m_assets_[cnt] = m_assets_[i]
                cnt = -1
                m_assets_[i].f = 0
                m_assets_[i].rc = 0
                m_assets_[i].d = 0
                m_assets_[i].n = ""
                fcnt += 1
            end if
        end if
    next

    m_na -= fcnt

end sub

sub AssetManager.cb( byval _cb as status_callback )
    m_status = _cb
end sub

private function load_string_asset( byval dt as gen_asset ptr ) as ext.bool
    return ext.true
end function

private sub free_image( byval d_ as any ptr )
    delete cast(ext.gfx.Image ptr,d_)
end sub

private function load_image_asset( byval dt as gen_asset ptr ) as ext.bool
    if dt->d <> 0 then return ext.true
    if screenptr = 0 then
        screenres 1,1,32,,fb.GFX_NULL
    end if
    if screenptr = 0 then
        return ext.false
    end if
    dt->d = ext.gfx.LoadImage(*(dt->f),right(dt->n,3))
    if dt->d = 0 then return ext.false
    dt->dfree = @free_image
    return ext.true
end function

private function load_sprite_asset( byval dt as gen_asset ptr ) as ext.bool
    return ext.true
end function

private function load_sound_asset( byval dt as gen_asset ptr ) as ext.bool
    return ext.true
end function

private function load_music_asset( byval dt as gen_asset ptr ) as ext.bool
    return ext.true
end function

private function load_map_asset( byval dt as gen_asset ptr ) as ext.bool
    return ext.true
end function

function AssetManager.load( ) as integer
    var m_assets_ = cast(gen_asset ptr,m_assets)
    for i as uinteger = 0 to m_na -1

        select case m_assets_[i].t
        case string_asset
            if load_string_asset(@m_assets_[i]) = ext.false then return i+1
        case image_asset
            if load_image_asset(@m_assets_[i]) = ext.false then return i+1
        case sprite_asset
            if load_sprite_asset(@m_assets_[i]) = ext.false then return i+1
        case sound_asset
            if load_sound_asset(@m_assets_[i]) = ext.false then return i+1
        case music_asset
            if load_music_asset(@m_assets_[i]) = ext.false then return i+1
        case map_asset
            if load_map_asset(@m_assets_[i]) = ext.false then return i+1
        case else 'invalid asset type
            return -1
        end select

    next

    return 0

end function

sub AssetManager.dispose( )
    var m_assets_ = cast(gen_asset ptr,m_assets)
    var remcnt = 0
    for i as uinteger = 0 to m_na -1
        if m_assets_[i].rc > 1 then
            m_assets_[i].rc = 1
        else
            m_assets_[i].rc = 0
            if m_assets_[i].dfree <> 0 then
                m_assets_[i].dfree(m_assets_[i].d)
                m_assets_[i].d = 0
            end if
        end if
    next

    m_compact()

end sub

function AssetManager.lookup( byref name_ as string, byref type_ as AssetType ) as any ptr
    var m_assets_ = cast(gen_asset ptr,m_assets)
    if m_na = 0 then return 0

    for i as uinteger = 0 to m_na -1

        if m_assets_[i].n = name_ then
            type_ = m_assets_[i].t
            m_li = i
            return m_assets_[i].d
        end if

    next

    return 0
    
end function

sub AssetManager.add(   byref name_ as string, _
                        byval type_ as AssetType, _
                        byval file_ as ext.File ptr )
    var m_assets_ = cast(gen_asset ptr,m_assets)
    if m_na = m_s then m_resize
    var tmp = AssetType.string_asset
    if this.lookup(name_,tmp) = 0 then
        m_assets_[m_na].n = name_
        m_assets_[m_na].t = type_
        m_assets_[m_na].f = file_
        m_assets_[m_na].rc = 2
        m_na += 1
    else
        m_assets_[m_li].rc += 1
    end if

end sub
