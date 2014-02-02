#ifndef _FBGFX_DIALOGS_BI
#define _FBGFX_DIALOGS_BI -1

namespace dialog

type dbox
    as integer x1, y1, x2, y2
end type

enum response explicit
    yes = 0
    no = 1
    ok = 0
    cancel = 1
end enum

enum qtype explicit
    YesNo
    OkCancel
end enum

enum icon explicit
    none
    exclaim
    warning
    questionmark
end enum

'basic dialogs
declare sub message( byref msg as string, byval i as icon = icon.none, byref button_text as string = "Ok" )
declare function question( byref msg as string, byval _t as qtype = qtype.YesNo, byval i as icon = icon.none ) as response
declare function input_str( byref msg as string, byval max_len as integer = 50, byval i as icon = icon.none ) as string
declare function input_int( byref msg as string, byval cancel as integer ptr, byval i as icon = icon.none ) as integer

'advanced dialogs
type _custom_callback as sub (  byval dx as integer, byval dy as integer, byval _ud as any ptr )

declare sub custom_ok(  byval min_w as integer, byval min_h as integer, byval delay as double, byval cb as _custom_callback, byval _data_ as any ptr )


end namespace

#inclib "dialogs"

#endif
