#define fbext_NoBuiltinInstanciations() -1
#define FBEXT_NO_EXTERNAL_LIBS -1
#include once "ext/strings/split.bi"
#include once "ext/input.bi"
#include once "dialogs.bi"
#include once "fbgfx.bi"

dim shared _exclaim as fb.image ptr
dim shared _warning as fb.image ptr
dim shared _question as fb.image ptr

dim shared m_prevscreen as fb.image ptr

exclaimidata:
#include "exclaim.dat"

warningidata:
#include "warning.dat"

questionidata:
#include "question.dat"

namespace dialog

        private sub __read_data( byval im as fb.image ptr, byval i_x as integer, byval i_y as integer )

                var xc = 0

                for y as integer = 0 to i_y-1
                        for x as integer = 0 to i_x-1
                                read xc
                                pset im,(x,y), xc
                        next
                next

        end sub

        private sub __init () constructor
                if screenptr = 0 then
                        screenres 1,1,32,,fb.GFX_NULL
                end if

                m_prevscreen = 0

                var i_x = 0
                var i_y = 0

                restore exclaimidata
                read i_x
                read i_y
                _exclaim = imagecreate(i_x,i_y)
                __read_data(_exclaim,i_x,i_y)

                restore warningidata
                read i_x
                read i_y
                _warning = imagecreate(i_x,i_y)
                __read_data(_warning,i_x,i_y)

                restore questionidata
                read i_x
                read i_y
                _question = imagecreate(i_x,i_y)
                __read_data(_question,i_x,i_y)


        end sub

        private sub __destroy () destructor
                if _exclaim <> 0 then imagedestroy _exclaim
                if _warning <> 0 then imagedestroy _warning
                if _question <> 0 then imagedestroy _question
                if m_prevscreen <> 0 then imagedestroy m_prevscreen
        end sub

        private sub save_screen( byval w as integer, byval h as integer )

                if m_prevscreen <> 0 then
                        imagedestroy(m_prevscreen)
                end if

                m_prevscreen = imagecreate(w,h)

                get (0,0)-(w-1,h-1), m_prevscreen

        end sub

        private sub restore_screen()
                if m_prevscreen <> 0 then
                        put (0,0), m_prevscreen, PSET
                end if
                imagedestroy m_prevscreen
                m_prevscreen = 0
                setmouse(,,1)
        end sub

        private sub _fade_bg ( byval w as integer, byval h as integer )
                var f = imagecreate(w,h,0,32)
                put (0,0),f,alpha,100
                imagedestroy f
        end sub

        private sub _draw_dialog_o( byval db as dbox )
                with db
                        line (.x1-1,.y1-1)-(.x2+1,.y2+1),&hFFFFFFFF, B
                        line (.x1,.y1)-(.x2,.y2),&hFFC9C9C9, BF
                        line (.x1,.y1)-(.x2,.y2),0,B
                end with
        end sub

        private sub _draw_button  ( byref txt as string, _
                byval db as dbox )
                with db
                        line (.x1,.y1)-(.x2,.y2),&hFFC9C9C9,BF
                        line (.x1,.y1)-(.x2,.y2),0,B
                        draw string (.x1+2,.y1+2),txt,0,,trans
                end with

        end sub

        private sub _draw_input_s ( byval x as uinteger, byval y as uinteger, _
                byref s as string, byval d as any ptr )

                var db = *cast(dbox ptr, d)
                _draw_button( s, db )

        end sub

        private function _wait_for_input( byval dbs as dbox ptr, byval dbs_len as uinteger ) as uinteger

                setmouse(,,1)
                var retval = 0u
                do
                        var x = -1, y = -1, button = 0
                        getmouse x, y, ,button
                        if button and 1 then
                                for n as uinteger = 0 to dbs_len - 1
                                        with dbs[n]
                                                if x > .x1 andalso x < .x2  andalso y > .y1 andalso y < .y2 then
                                                        retval = n
                                                        exit do
                                                end if
                                        end with
                                next
                        end if
                        sleep 20,1
                loop

                setmouse(,,0)

                return retval

        end function

        private function _draw_dialog_interior( byref _dmsg as string, byval i as icon, byval _max_s as uinteger = 0 ) as dbox ptr

                dim m() as string
                dim as integer s_w, s_h
                screeninfo( s_w, s_h )

                _fade_bg(s_w,s_h)

                var h = ext.strings.explode(_dmsg,!"\v",m()) * 10

                var max_len = 0
                for n as integer = lbound(m) to ubound(m)
                        var temp_len = len(m(n)) * 8
                        if temp_len > max_len then max_len = temp_len
                next
                max_len += 20
                if _max_s <> 0 then
                        if max_len < _max_s * 8 then max_len = (_max_s * 8) + 20
                end if
                if max_len < 35 then max_len = 35+15
                if max_len > s_w then max_len = s_w
                var hmax_len = int(max_len / 2)

                var sy = int(s_h/2) - int((h + 30) / 2)
                var sx = int(s_w/2) - hmax_len

                if i <> icon.none then
                        dim temp_i as fb.image ptr
                        select case i
                                case icon.exclaim
                                        temp_i = _exclaim
                                case icon.warning
                                        temp_i = _warning
                                case icon.questionmark
                                        temp_i = _question
                        end select
                        _draw_dialog_o (type<dbox>(sx-temp_i->width+6,sy,sx+max_len,sy+h+30))
                        put (sx-(temp_i->width)+8,sy+6),temp_i,trans

                else
                        _draw_dialog_o (type<dbox>(sx,sy,sx+max_len,sy+h+30))
                end if

                for n as integer = lbound(m) to ubound(m)
                        draw string (sx+10,sy+10 + (10*n)),m(n),0,,trans
                next n

                var ret = new dbox
                with *ret
                        .x1 = sx
                        .y1 = s_w
                        .x2 = sx+max_len
                        .y2 = sy+h+30
                end with

                return ret

        end function

        public sub custom_ok(  byval min_w as integer, byval min_h as integer, _
                byval delay as double, byval cb as _custom_callback, _
                byval _data_ as any ptr )

                dim as integer s_w, s_h
                screeninfo( s_w, s_h )

                save_screen(s_w,s_h)
                _fade_bg(s_w,s_h)

                var h_mw = (min_w+20) \ 2
                var h_mh = (min_h+30) \ 2
                var hs_w = s_w \ 2
                var hs_h = s_h \ 2

                _draw_dialog_o( type<dbox>(hs_w-h_mw,hs_h-h_mh,hs_w+h_mw,hs_h+h_mh) )

                var ok_b = type<dbox>((hs_w+h_mw)-35, (hs_h+h_mh)-15, (hs_w+h_mw)-15, (hs_h+h_mh)-5)

                _draw_button ("Ok", ok_b)
                setmouse(,,1)
                cb( (hs_w-h_mw)+10, (hs_h-h_mh)+10, _data_ )
                var step_t = timer + delay
                do
                        var begin_t = timer
                        var x = -1, y = -1, button = 0
                        getmouse x, y, ,button
                        if button and 1 then

                                with ok_b
                                        if x > .x1 andalso x < .x2  andalso y > .y1 andalso y < .y2 then
                                                exit do
                                        end if
                                end with

                        end if

                        if step_t < begin_t then
                                cb( (hs_w-h_mw)+10, (hs_h-h_mh)+10, _data_ )
                                step_t = timer + delay
                        end if

                        sleep 20,1
                loop
                restore_screen()
                setmouse(,,0)


        end sub

        public sub message( byref msg as string, byval i as icon = icon.none, byref button_text as string = "Ok" )
                dim as integer s_w, s_h
                screeninfo( s_w, s_h )
                save_screen(s_w,s_h)

                var mm = _draw_dialog_interior( msg, i )
                var len_bt = len(button_text) * 8
                var ok_b = type<dbox>(mm->x2-(15+(len_bt+4)), (mm->y2)-15, mm->x2-15, (mm->y2)-5)
                delete mm

                _draw_button (button_text, ok_b)

                _wait_for_input( @ok_b, 1 )
                restore_screen

        end sub

        public function question( byref msg as string, byval _t as qtype = qtype.YesNo, byval i as icon = icon.none ) as response
                dim as integer s_w, s_h
                screeninfo( s_w, s_h )
                save_screen(s_w,s_h)

                var mm = _draw_dialog_interior( msg, i )

                var buttons = new dbox[2]
                select case _t
                        case qtype.OkCancel
                                buttons[1] = type<dbox>(mm->x2-((6*8)+10), (mm->y2)-15, mm->x2-10, (mm->y2)-5)
                                _draw_button ("Cancel", buttons[1])

                                buttons[0] = type<dbox>(buttons[1].x1-35,buttons[1].y1,buttons[1].x1-15,buttons[1].y2)
                                _draw_button ("Ok", buttons[0])

                        case else
                                buttons[1] = type<dbox>(mm->x2-35, (mm->y2)-15, mm->x2-15, (mm->y2)-5)
                                _draw_button ("No", buttons[1])

                                buttons[0] = type<dbox>(buttons[1].x1-40,buttons[1].y1,buttons[1].x1-15,buttons[1].y2)
                                _draw_button ("Yes", buttons[0])


                end select
                delete mm

                var ret = _wait_for_input( buttons, 2 )
                delete[] buttons
                restore_screen
                return ret

        end function

        public function input_str( byref msg as string, byval max_len as integer = 50, byval i as icon = icon.none ) as string
                dim as integer s_w, s_h
                screeninfo( s_w, s_h )
                save_screen(s_w,s_h)
                var mm = _draw_dialog_interior( msg, i, max_len )

                var igetstr = ext.xInput()
                igetstr.maxlength = max_len
                igetstr.cancel = 0
                igetstr.print_cb = @_draw_input_s
                var ibb_i = 0
                if (max_len*8) > mm->y1 then
                        ibb_i =mm->y1-10
                else
                        ibb_i = mm->x1+(max_len*8)+8
                end if
                var ibb = type<dbox>(mm->x1+5, mm->y2-15, ibb_i, mm->y2-5)
                igetstr.print_cb_data = @ibb

                var ret = igetstr.get(mm->x1+5,mm->y2-10)
                delete mm
                restore_screen
                return ret

        end function

        public function input_int( byref msg as string, byval cancel as integer ptr, byval i as icon = icon.none ) as integer
                dim as integer s_w, s_h
                screeninfo( s_w, s_h )
                save_screen(s_w,s_h)
                var mm = _draw_dialog_interior( msg, i, 10 )

                var igetstr = ext.xInput()
                igetstr.maxlength = 10
                igetstr.cancel = 0
                igetstr.print_cb = @_draw_input_s
                var ibb_i = 0
                if (80) > mm->y1 then
                        ibb_i =mm->y1-10
                else
                        ibb_i = mm->x1+(80)+8
                end if
                var ibb = type<dbox>(mm->x1+5, mm->y2-15, ibb_i, mm->y2-5)
                igetstr.print_cb_data = @ibb

                var retval = igetstr.get(mm->x1+5,mm->y2-10)
                delete mm
                if retval = chr(27) then *cancel = 1
                restore_screen
                return valint(retval)
        end function

        public function input_dbl( byref msg as string, byval cancel as double ptr, byval i as icon = icon.none ) as double
                dim as integer s_w, s_h
                screeninfo( s_w, s_h )
                save_screen(s_w,s_h)
                var mm = _draw_dialog_interior( msg, i, 10 )

                var igetstr = ext.xInput()
                igetstr.maxlength = 14
                igetstr.cancel = 0
                igetstr.print_cb = @_draw_input_s
                var ibb_i = 0
                if (80) > mm->y1 then
                        ibb_i =mm->y1-10
                else
                        ibb_i = mm->x1+(80)+8
                end if
                var ibb = type<dbox>(mm->x1+5, mm->y2-15, ibb_i, mm->y2-5)
                igetstr.print_cb_data = @ibb

                var retval = igetstr.get(mm->x1+5,mm->y2-10)
                delete mm
                if retval = chr(27) then *cancel = 1.0
                restore_screen
                return val(retval)
        end function

end namespace
