#include once "game-defs.bi"
#include once "ext/log.bi"
#include once "ext/json.bi"

using ext
dim shared lm as LISP.LispModule ptr
dim shared pakf as ext.ZipFile ptr
dim shared next_l as string
dim shared am as AssetManager ptr

type events
    as string ontick, onclick, onkey, onload, onunload
end type

declare function eventLoop( byref ev as events ) as string
declare function loadScripts( byval al as ext.json.JSONvalue ptr ) as ext.bool
declare function loadAssets( byval al as ext.json.JSONvalue ptr ) as ext.bool
declare function getPkgName() as string
declare function runit( byref fn as string ) as ext.bool
declare function main () as integer

function eventLoop( byref ev as events ) as string

    var ret = 0

    if ev.onload <> "" then
        DEBUG("Sending onload signal")
        ret = lm->Eval("(" & ev.onload & ")")
        if ret <> 0 then
            ext.setError(1024,"LISP error")
            WARN("Error in onload script: " & getLispError)
        end if
    end if

    dim as integer mx, my, mb

    while ret = 0 andalso next_l = ""
        if ev.ontick <> "" then
            DEBUG("Sending ontick signal")
            ret = lm->Eval("(" & ev.ontick & ")")
            if ret <> 0 then
                ext.setError(1024,"LISP error")
                WARN("Error in ontick script: " & getLispError)
            end if
        end if

        var k = inkey()

        if k <> "" then
            if ev.onkey <> "" then
                DEBUG("Sending onkey signal")
                var signal = 0
                if len(k) > 1 then
                    signal = (k[0] shl 8) or k[1]
                else
                    signal = asc(k)
                end if
                ret = lm->Eval("(" & ev.onkey & " " & signal & ")")
                if ret <> 0 then
                    ext.setError(1024,"LISP error")
                    WARN("Error in onkey script: " & getLispError)
                end if
            end if
        end if

        if screenptr <> 0 then
        getmouse mx, my,,mb
        if mx > -1 andalso (mb and 1 orelse mb and 2) then
            if ev.onclick <> "" then
                DEBUG("Sending onclick signal")
                ret = lm->Eval("(" & ev.onclick & " " & mx & " " & my & " " & mb & ")")
                if ret <> 0 then
                    ext.setError(1024,"LISP error")
                    WARN("Error in onclick script: " & getLispError)
                end if
            end if
        end if
        end if
    wend

    if ev.onunload <> "" then
        DEBUG("Sending onunload signal")
        ret = lm->Eval("(" & ev.onunload & ")")
        if ret <> 0 then
            ext.setError(1024,"LISP error")
            WARN("Error in onunload script: " & getLispError)
        end if
    end if

    if next_l = "-" then next_l = ""
    if next_l <> "" then
        INFO("Chaining to " & next_l)
    else
        INFO("Exiting...")
    end if
    return next_l

end function

setLogMethod(LOG_FILE)
setLogLevel(_DEBUG)
INFO("Starting engine")
lm = new LISP.LispModule
registerGfxApi
registerRTapi

var ret = main
if pakf <> 0 then delete pakf
if lm <> 0 then delete lm
if am <> 0 then delete am
var vret = ext.getError()
if vret <> 0 then
    ret = vret
    FATAL(ext.getErrorText(vret))
end if
INFO("Return Value: " & ret)
end ret

function evalFile( byref fn as const string ) as integer
    return lm->Eval( "(include-file " & chr(34) & fn & chr(34) & ")" )
end function

function loadScripts( byval al as ext.json.JSONvalue ptr ) as ext.bool
    if al <> 0 then
        if al->valueType <> ext.json.jstring andalso al->valueType <> ext.json.array then
            WARN("The value of scripts was not a string or an array.")
            return ext.false
        else
            if al->valuetype = ext.json.jstring then
                DEBUG("Loading " & al->getString())
                var lret = evalFile(al->getString())
                if lret <> 0 then
                    WARN("Error in script (" & al->getString() & "): " & getLispError)
                    return ext.false
                end if
            else
                var arr = al->getArray()
                for n as uinteger = 0 to arr->length -1
                    DEBUG("Loading " & arr->at(n)->getString())
                    var lret = evalFile(arr->at(n)->getString())
                    if lret <> 0 then
                        WARN("Error in script (" & arr->at(n)->getString() & "): " & getLispError)
                        return ext.false
                    end if
                next
            end if
            return ext.true
        end if
    else
        FATAL("NULL value passed to loadScripts.")
        return ext.false
    end if
end function

function loadAssets( byval al as ext.json.JSONvalue ptr ) as ext.bool
    if am = 0 then
        am = new AssetManager
        INFO("Creating new AssetManager")
    else
        INFO("Reusing existing AssetManager")
    end if
    if al <> 0 then
        if al->valueType = ext.json.array then 
            var arr = al->getArray()
            for i as uinteger = 0 to arr->length -1
                var fn = arr->at(i)->getString()
                var fnf = pakf->open(fn)
                am->add(fn,image_asset,fnf)
            next
            am->load()
            am->dispose()
            return ext.true
        elseif al->valueType= ext.json.jstring then
            am->add(al->getString(),image_asset,pakf->open(al->getString()))
            am->load()
            am->dispose()
            return ext.true
        else
            WARN("Value of assets not string or array")
            return ext.false
        end if
    else
        FATAL("NULL passed to loadAssets")
        return ext.false
    end if
end function

function runit( byref fn as string ) as ext.bool

    var mf = pakf->open(fn)
    INFO("Running: " & fn)
    if mf->open() = ext.true then
        FATAL("Error opening " & fn)
        return ext.true
    end if
    dim mfj as ext.json.JSONobject
    var mft = mfj.loadFile(*mf)
    if mft = 0 then
        FATAL( "Error parsing " & fn)
        return ext.true
    end if
    if mfj.children() = 0 then
        WARN( "Error in JSON syntax in " & fn)
        return ext.true
    end if

    var assets = mfj.child("assets")
    var assetsr = loadAssets(assets)
    if assetsr = ext.false then
        WARN("Error loading assets " & fn)
        return ext.true
    end if

    var scripts = mfj.child("scripts")
    var scriptsr = loadScripts(scripts)
    if scriptsr = ext.false then
        WARN("Error loading scripts in " & fn)
        return ext.true
    end if

    dim ev as events
    var tmp = mfj.child("ontick")
    if tmp <> 0 then ev.ontick = tmp->getString()
    tmp = mfj.child("onload")
    if tmp <> 0 then ev.onload = tmp->getString()
    tmp = mfj.child("onunload")
    if tmp <> 0 then ev.onunload = tmp->getString()
    tmp = mfj.child("onclick")
    if tmp <> 0 then ev.onclick = tmp->getString()
    tmp = mfj.child("onkey")
    if tmp <> 0 then ev.onkey = tmp->getString()

    var evret = eventLoop( ev )
    var ret = ext.false
    if evret <> "" then
        INFO("Collecting Garbage")
        lm->GarbageCollect()
        ret = runit(evret)
    end if
    INFO("Collecting Garbage")
    lm->GarbageCollect()

    return ret

end function

function getPkgName() as string

    var pkgname = ""
    var tmpn = command(0)

    if instrrev(tmpn,"/") > 0 then
        pkgname = exepath & mid(tmpn,instrrev(tmpn,"/"))
    else
        pkgname = exepath & "/" & tmpn
    end if
    
    if instr(pkgname,".") < 1 then
        pkgname &= ".epk"
    else
        pkgname = left(pkgname,len(pkgname)-3) & "epk"
    end if

    INFO("Package name: " & pkgname)
    function = pkgname

end function

function main () as integer

    var pakname = getPkgName()
    pakf = new ext.ZipFile(pakname)
    var e = ext.getError()
    if e <> 0 then
        FATAL( "Could not open " & pakname & ": " & getErrorText(e) )
        return __LINE__ -1
    end if
    
    var pakinfof = pakf->open("package.json")
    if pakinfof = 0 then
        FATAL("The package file may be corrupted or missing.")
        return __LINE__ -1
    end if

    dim pakinfoj as ext.json.JSONobject
    var r = pakinfoj.loadFile(*pakinfof)

    if r = 0 then
        FATAL("The package info file may be corrupted or missing.")
        return __LINE__ -1
    end if

    if pakinfoj.children = 0 then
        FATAL("The package info file may be corrupted or missing.")
        return __LINE__ -1
    end if

    var gamename = pakinfoj.child("friendly-name")->getString()
    var gamever = pakinfoj.child("version")->getString()
    var gamedef = pakinfoj.child("default")->getString()

    ? "Loading " & chr(34) & gamename & " " & gamever & chr(34)

    var prel = pakinfoj.child("at-load")
    if prel <> 0 then
        if prel->valueType = ext.json.jvalue_type.jstring then
            var prelf = pakf->open(prel->getString())
            if prelf->open() = ext.true then
                FATAL("Could not open at-load script: " & prel->getString())
            else
                var pret = evalFile(prel->getString())
                if pret <> 0 then
                    WARN("Error in script (" & prel->getString() & "): " & getLispError)
                    return __LINE__
                end if
            end if
        end if
    end if

    var runret = runit(gamedef)

    var atxit = pakinfoj.child("at-exit")
    if atxit <> 0 then
        if atxit->valueType = ext.json.jvalue_type.jstring then
            var xitf = pakf->open(atxit->getString())
            if xitf->open() = ext.true then
                FATAL("Could not open at-exit script: " & atxit->getString())
            else
                var xret = evalFile(atxit->getString())
                if xret <> 0 then
                    WARN("Error in script (" & atxit->getString() & "): " & getLispError)
                    return __LINE__
                end if
            end if
        end if
    end if
    
    if runret then
        return __LINE__
    else
        return 0
    end if

end function
