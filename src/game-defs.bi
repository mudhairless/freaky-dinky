#include once "ext/file/zipfile.bi"
#include once "lisp.bi"
#include once "AssetManager.bi"

extern lm as LISP.LispModule ptr
extern pakf as ext.ZipFile ptr
extern am as AssetManager ptr
extern next_l as string

declare function getLispError() as string
declare function evalFile( byref fn as const string ) as integer

declare sub registerGfxApi
declare sub registerRTapi
