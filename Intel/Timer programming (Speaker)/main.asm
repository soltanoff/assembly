codesg segment para "code" ; Начало сегмента кода 
; Присваивается значение сегмента программы  	
assume cs:codesg, ds:codesg,  ss:codesg,  es:codesg
                                  
org 100h       ; Начало программы в конце PSP

start:
   jmp main      ; Обход через данные (в *.COM 1 сегмент только для кода )
   ;определение данных 
   flag    db 0
   music   dw      1208,6834,2152,7240,6834,1208,6834,2152,2711,3224
   
main proc near    
begin:
        mov     cx, 10
        lea     si,music
beg:    push    cx
        in      al,61h
		; останавливаем звук (гробим первые два бита)
        or      al, 3
        out     61h,al
		
		; BCD: 	двоич. 16бит число (0000-0FFFh)
		; M:	генератор прямоугольных импульсов
		; RW:	чтение/запись сначало младшего, а затем старшего байта
		; SC:	Канал 2 (спикер)
        mov     al,10110110b 
        out     43h, al
        cmp     cx, 0
        jae     M2
        dec     si
        dec     si
M2:
        mov     ax,cs:[si]
        cmp     cx, 0
        jb      M1
        inc     si
        inc     si
M1:
        out     42h,al
        mov     al,ah
        out     42h,al
        in      al,61h
		; врубаем звук (устанавливаем первые два бита)
        or      al,3
        out     61h, al
        in      al,61h
        mov     ax,8600h
        mov     bx,cs
        mov     es,bx
        lea     bx,flag
        mov     cx,7
        mov     dx,0A120h
        int     15h
bue:
        pop     cx
        loop    beg
        in      al,61h
        and     al,0ffh-3
        out     61h,al
        mov ax,4c00h
		
		int 21h
		call dos_exit
main endp 

dos_exit proc
int 20h 
dos_exit endp 
; конец сегмента 
codesg  ends
; конец программы
end start

;dw      9119,8609,8125,7671,7240,6834,6450,6088,5746,5424,5119,4832
;dw      4559,4304,4062,3835,3620,3416,3224,3043,2873,2711,2559,2415
;dw      2280,2152,2031,1918,1810,1708,1612,1522,1437,1356,1280,1208