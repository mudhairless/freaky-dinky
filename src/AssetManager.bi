'AssetManager
#include once "ext/file/file.bi"

enum AssetType 
    string_asset
    image_asset
    sprite_asset
    sound_asset
    music_asset
end enum

type status_callback as sub ( byval as integer )

type AssetManager
    public:
    declare constructor
    declare destructor
    declare sub add(   byref name_ as string, _
                        byval type_ as AssetType, _
                        byval file_ as ext.File ptr )

    declare sub cb( byval as status_callback )

    declare function load( ) as integer

    declare function lookup( byref name_ as string, byref type_ as AssetType ) as any ptr
    
    private:
    m_status as status_callback
    m_assets as any ptr
    m_na as uinteger
end type

