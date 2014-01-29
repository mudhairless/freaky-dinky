#include once "game-defs.bi"

#include once "ext/json.bi"


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

    if ev.onload <> "" then
        lm->Eval("(" & ev.onload & ")")
    end if

    while next_l = ""
        next_l = "-"
    wend

    if ev.onunload <> "" then
        lm->Eval("(" & ev.onunload & ")")
    end if

    if next_l = "-" then next_l = ""
    return next_l

end function

lm = new LISP.LispModule
registerGfxApi

var ret = main
if pakf <> 0 then delete pakf
if lm <> 0 then delete lm
if am <> 0 then delete am
? "Return Value: " & ret
end ret

function evalFile( byref fn as const string ) as integer
    var xitf = pakf->open(fn)
    if xitf->open() = ext.true then
        return __LINE__
    else
        var xits = ""
        while not xitf->eof()
            var xtmp = xitf->readLine()
            xits &= xtmp
        wend
        xitf->close()
        var xret = lm->Eval(xits)
        if xret <> 0 then
            ? "Error in script: " & fn
            ? "Line: " & lm->ErrorLine();
            ? " Column: " & lm->ErrorColumn()
            ? lm->ErrorText()
            return __LINE__
        end if
    end if
    return 0
end function

function loadScripts( byval al as ext.json.JSONvalue ptr ) as ext.bool
    if al <> 0 then
        if al->valueType <> ext.json.jstring orelse al->valueType <> ext.json.array then
            return ext.false
        else
            if al->valuetype = ext.json.jstring then
                var lret = evalFile(al->getString())
                if lret <> 0 then return ext.false
            else
                var arr = al->getArray()
                for n as uinteger = 0 to arr->length -1
                    var lret = evalFile(arr->at(n)->getString())
                    if lret <> 0 then return ext.false
                next
            end if
            return ext.true
        end if
    else
        return ext.false
    end if
end function

function loadAssets( byval al as ext.json.JSONvalue ptr ) as ext.bool
    if am = 0 then am = new AssetManager
    if al <> 0 then
        if al->valueType <> ext.json.array then return ext.false
        var arr = al->getArray()
        for i as uinteger = 0 to arr->length -1
            var fn = arr->at(i)->getString()
            var fnf = pakf->open(fn)
            am->add(fn,image_asset,fnf)
        next
        am->load()
        am->dispose()
        return ext.true
    else
        return ext.false
    end if
end function

function runit( byref fn as string ) as ext.bool

    var mf = pakf->open(fn)
    if mf->open() = ext.true then
        ? "Error opening " & fn
        return ext.true
    end if
    dim mfj as ext.json.JSONobject
    var mft = mfj.loadFile(*mf)
    if mft = 0 then
        ? "Error parsing " & fn
        return ext.true
    end if
    if mfj.children() = 0 then
        ? "Error in JSON syntax in " & fn
        return ext.true
    end if

    var assets = mfj.child("assets")
    var assetsr = loadAssets(assets)
    if assetsr = ext.false then
        ? "Error loading assets " & fn
        return ext.true
    end if

    var scripts = mfj.child("scripts")
    var scriptsr = loadScripts(scripts)
    if scriptsr = ext.false then
        ? "Error loading scripts in " & fn
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
        lm->GarbageCollect()
        ret = runit(evret)
    end if
    
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

    function = pkgname

end function

function main () as integer

    var pakname = getPkgName()
    pakf = new ext.ZipFile(pakname)
    var e = ext.getError()
    if e <> 0 then
        ? "Could not open " & pakname
        ? ext.getErrorText(e)
        ? "Error: " & __FILE__ & ":" & __LINE__
        return __LINE__ -1
    end if
    
    var pakinfof = pakf->open("package.json")
    if pakinfof = 0 then
        ? "Could not open " & pakname
        ? "The package file may be corrupted or missing."
        ? "Error: " & __FILE__ & ":" & __LINE__
        return __LINE__ -1
    end if

    dim pakinfoj as ext.json.JSONobject
    var r = pakinfoj.loadFile(*pakinfof)

    if r = 0 then
        ? "Could not open " & pakname
        ? "The package info file may be corrupted or missing."
        ? "Error: " & __FILE__ & ":" & __LINE__
        return __LINE__ -1
    end if

    if pakinfoj.children = 0 then
        ? "Could not open " & pakname
        ? "The package info file may be corrupted or missing."
        ? "Error: " & __FILE__ & ":" & __LINE__
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
                ? "Could not open exit script: " & prel->getString()
            else
                var prels = ""
                while not prelf->eof()
                    var preltmp = prelf->readLine()
                    prels &= preltmp
                wend
                prelf->close()
                var pret = lm->Eval(prels)
                if pret <> 0 then
                    ? "Error in script: " & prel->getString()
                    ? "Line: " & lm->ErrorLine();
                    ? " Column: " & lm->ErrorColumn()
                    ? lm->ErrorText()
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
                ? "Could not open exit script: " & atxit->getString()
            else
                var xits = ""
                while not xitf->eof()
                    var xtmp = xitf->readLine()
                    xits &= xtmp
                wend
                xitf->close()
                var xret = lm->Eval(xits)
                if xret <> 0 then
                    ? "Error in script: " & atxit->getString()
                    ? "Line: " & lm->ErrorLine();
                    ? " Column: " & lm->ErrorColumn()
                    ? lm->ErrorText()
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
