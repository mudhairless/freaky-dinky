'AssetManager
#include once "ext/file/file.bi"

enum AssetType 
    string_asset
    image_asset
    sprite_asset
    sound_asset
    music_asset
    map_asset
    script_asset
end enum

type status_callback as sub ( byval as integer )

type AssetManager
    public:
    declare constructor
    declare destructor
    declare sub add(   byref name_ as string, _
                        byval type_ as AssetType, _
                        byval file_ as ext.File ptr, _
                        byval d_ as any ptr = 0 )

    declare sub cb( byval as status_callback )

    declare function load( ) as integer

    declare function lookup( byref name_ as string, byref type_ as AssetType ) as any ptr

    declare sub dispose( )
    
    private:
    declare sub m_resize()
    declare sub m_compact()
    m_status as status_callback
    m_assets as any ptr
    m_na as uinteger
    m_s as uinteger
    m_li as uinteger
end type

