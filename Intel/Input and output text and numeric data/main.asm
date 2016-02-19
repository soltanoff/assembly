;
codesg segment para "code" ; Начало сегмента кода
; Присваивается значение сегмента программы 	
assume cs:codesg, ds:codesg,  ss:codesg,  es:codesg
                                  
org 100h       ; начало проги в конце PSP


start:
   jmp main      ; обход через данные (в *.COM 1 сегмент только для кода )
   ;определение данных
   buf  db 10 dup(0)  ; Буфер ввода 10 байт заполненых нулями  
   
   errmsg0 db "Ошибка преобразования в целое.$"
   errmsg1 db "Переполнение разрядной сетки.$"
   errmsg2 db "Деление на нуль.$"  
   errmsg3 db "Число не может быть отрицательным$"
   
   mess1 db "Введите 3 десятичных числа [-128..127], A/C-C*B$"
   mess2 db 'A = $'
   mess3 db 'B = $'
   mess4 db 'C = $'
  
  
   var_a  db 0     ; 
   var_b  db 0     ;
   var_c  db 0     ;
   
   var_temp dw 0

;ввод данных и вычисление (d*a)/(a+b)
;вызывает GOTO_XY, WRITE_STR, READ_STR,
;         CALCULATE, str_to_int, int_to_str 
main proc near  
    push ax
    push dx
                      
    mov  buf[0],5     ; определим размер входного буфера (4 символа + CR)
                      ; реальный размер буфера после чтения 1б + 1б + 5б = 7б   
   
    ; очистка экрана и ввывод строки заголовка
    call clear_scr  
    lea dx, mess1     ;  загружаем адрес строки mess1
    call write_str    ;  используем int 21h для вывода строки
    call cr
    
    ; просим ввести А
    lea dx, mess2     ;  Загрузка адреса строки в Dx = (mov dx,offset mess2)
    call write_str    ;  ее вывод    
      
   
    lea dx, buf       ;  ?загрузка адреса буфера вводимых символов в Dx
    ;адрес буфера в DS:DX 
    call read_str     ;  чтение строки в буфер используя int 21h
    call str_to_int   ;  перевод строки в число, результат в DX   
    mov var_a,dl   
    
   
    ; просим ввести В
    call cr
    lea dx, mess3     ;  Загрузка адреса строки в Dx = (mov dx,offset mess3)
    call write_str    ;  ее вывод   
    
    lea dx, buf       ;  ?загрузка адреса буфера вводимых символов в Dx
    ;адрес буфера в DS:DX
    call read_str     ;  чтение строки в буфер используя int 21h
    call str_to_int   ;  перевод строки в число, результат в DX    
    mov var_b,dl
   
    ; просим ввести D 
    call cr 
    lea dx, mess4     ;  Загрузка адреса строки в Dx = (mov dx,offset mess3)
    call write_str    ;  ее вывод  
    
    lea dx, buf       ;  ?загрузка адреса буфера вводимых символов в Dx
    ;адрес буфера в DS:DX
    call read_str     ;  чтение строки в буфер используя int 21h
    call str_to_int   ;  перевод строки в число, результат в DX   
    mov var_c,dl
    call cr    
        
    call calculate; 
    call write_result; 
    call dos_exit           ; выход в DOS 
    ;возврат управления системе (прыгаем на int 20h в начале PSP)
   ret
   ;конец процедуры
main endp    


; число загружено в Al   
; перевод числа в строку загруженную в DS:DX
Int_To_Str proc near
  push ax
  push bx 
  push cx
  push dx
  push bp 
  

  xor cx,cx      ; счетчик записанных в стек символов  
  mov bp,dx      ; адрес строки занесем в Bp
  xor dx,dx                    
  mov bl,10      ; показатель СС = 10

  cmp al,0h ;al      
  jg PUSHASCII     
  jz PUSHASCII       
  
  neg al 
  mov [bp],2dh            
  inc bp
  
PUSHASCII:
  cbw             ;
  xor ah,ah
  div bl          ; после деления в Al целая часть, в Ah - остаток
  add ah,30h      ; получили ASCII символ цифры остатка в ah
  mov dl,ah        
  push dx         ; затолкнем ASCII символ в стек
  inc cl          ; увеличим счетчик записаных в стек символов
  cmp al,0        ; пока частное <> 0
  jnz PUSHASCII   ; выполняем деление (перевод в 10 cc)
  
; Вытолкнем все ASCII из стека в строку
POPASCII:
  pop dx          ; втаскиваем ASCII код из стека (в обратном порядке)
  mov [bp],dl     ; занесем символ в строку 
  inc bp          ;  
  loop POPASCII   ; 
  
  mov [bp],24h    ; завершающий символ в строке $  
  
  pop bp
  pop dx               
  pop cx 
  pop bx
  pop ax
  ret
Int_To_Str endp  

; A/C-C*B
; производит подсчет результата в Dx
; Dlчастное Dh-остаток
calculate proc near
  push ax
  push bx
  push cx
  
  xor ax,ax        
    
  ; =========================
  mov  al,var_b   ; занесем множитель в Ax
  imul var_c     
  mov var_temp,ax  
  
  jo OVERFLOW 
  
  xor ax,ax 
  xor bx,bx 
  
  mov al, var_a
  mov bl, var_c 
  
  cmp bl, 0
  jz DEVIDE_BZ
  
  xor dx,dx
  
  call devide 
  
  mov bx, var_temp
  sub al, bl
  
  ;jo OVERFLOW 
  ;========================== 
  
  ; частное в Ax, остаток в Dx 
  ; проверим частное
  cmp al, -128  ;
  jl OVERFLOW
  cmp al, 127  ;
  jg OVERFLOW
  
  ; сделаем остаток положительным  
  cmp dx,0           
  jg FINISH   
  neg dx         
  jmp FINISH
OVERFLOW: 
     call cr 
     lea dx, errmsg1 
     call write_str
     call dos_exit
DEVIDE_BZ:
     call cr
     lea dx, errmsg2 
     call write_str
     call dos_exit
FINISH:  
  mov Dh,Dl   ; сохраним результ в Dh-остаток  (уже больше 0) 
  mov Dl,Al   ; Dl-частное
  pop  cx
  pop  bx
  pop  ax
  ret
calculate endp 


; ltktybt Ax/Bl частное в Ax остаток в Dx 
devide proc 
push bx
     ;cwd        ; расширим делиное в AX до второго слова DX:AX
     push ax 
     mov al,bl 
     ;cbw        ; расширим делитель до слова
     ;mov bx,ax  ; 
     pop  ax
     ; делимое в DX:AX  делитель в BX 
     idiv bx
     ; частное в Ax остаток в DX
pop  bx  
ret 
devide endp 
   
   
; вывод результата деления   
write_result proc
push ax
push dx
       call cr                ;  перевод строки  
       ; вывод частного
       xor ax,ax 
       push dx
       mov al,dl;
       lea dx,buf; 
       call int_to_str;
       call write_str;        ;      
       
       call dot               ; 
       
       ; вывод остатка         
       xor ax,ax 
       pop dx
       mov al,dh;
       lea dx,buf; 
       call int_to_str;
       call write_str;        ;      
pop dx 
pop ax       
ret
write_result endp 




; строка в DS:DX   
; переводит строку в число со знаком размером в байт 
; возврат в DOS при переполнении разрядной сетки и недопустимых символах в
; строке (допустимые - + 0..9 в естественном порядке следования)
; вызывает GOTO_XY, WRITE_STR, 

str_to_int proc near 
   push ax
   push bx
   push cx
   push bp
   push si
   xor  bx,bx  
   xor  cx,cx       ; обнулим регистр
   mov  bp,dx       ; занесем адрес строки в Bp 
   xor  dx,dx       ; через этот регистр возвратим значение
   mov si,0         ; знак по дефолту +  
   mov bl,0         ; промежуточное хранение результата 
   inc bp           ; тыкаем индекс на первый элемент
   mov cl,[bp]      ; занесем в Cl число прочитанных символов
   inc bp           ; тыкаем индекс на 1й символ в строке
   mov dl,[bp]      ; посмотрим 1 символ (проверим, знак ли это ?)
   cmp dl,2dh       ; это '-' ?  
   ;je NEGATIVE 
   jne PLUS         ; не, не он '-' (попробуем проверить на '+')  
   mov si,1         ; да, это '-', запомним знак числа
   inc bp           ; перейдем к следующему символу 
   dec cl           ; уменьшим счетчик обрабатываемых символов (уже 1 посмотрели)
   jmp GO
PLUS:   
   cmp dl,2bh        ; это '+' ? 
   jne GO            ; нит, не он
   inc bp            ; да, это '+', перейдем к следующему символу  
   dec cl            ; уменьшим счетчик обрабатываемых символов
GO:
   xor ax,ax         ;  
   xor dx,dx         ;    
   mov dl,[bp]       ; в Dl символы выбираемые из строки
   inc bp            ; к следующему байту
   cmp dl,30h        ; проверка  dl < '0'
   jl ERROR          ; это ASCII код меньше кода '0' (+,- уже проверены)          
   cmp dl,39h        ; проверка  dl > '9'   
   jg ERROR          ; ошибка,не может быть символа больше 9       
   sub  dl,30h       ; получаем число от 0 до 9 => Dl  
   mov al,10         ; сомножетелю положенно быть в Al
   mul bl            ; ( изначально = 0 )
   jo BAIT_OF        ; переполнение разрядной сетки
   mov bl,al         ; сохраним промежуточное произведение
   add ax,dx         ; сложим промежуточное произведение и очередной разряд
   cmp ax,255     
   jg BAIT_OF
   mov bl,al         ; сохраним промежуточный результат
   loop GO           ; автоматом уменьшает CX на 1 
   ; опред знака числа  
   cmp si,0          ; + ?
   jne SET_MINUS     ; число отрицательно (переводим в доп код)       
   test bl,80h       ; число < 127 ?  
   ;cmp bl, 255 
   ;ja BAIT_OF
   jnz BAIT_OF       ; для знакового числа это много > 127
   jmp DONE          ; все ок + число в диапазоне <= 127
; 
SET_MINUS:    
    neg  bl          ; переводим число в доп код
    test bl,80h      ; число меньше -128 
    ;cmp bl, 80
    jz  BAIT_OF      ; ага, меньше
    jmp DONE         ; если нет переполнения, то все зи    
; 
; обработка переполнения
BAIT_OF: 
     call cr
     lea dx, errmsg1 
     call write_str
     call dos_exit
     
; обработка ошибочных символов ()  
ERROR: 
     call cr 
     lea dx, errmsg0 
     call write_str
     call dos_exit  
; обработка ошибочных символов ()  
NEGATIVE: 
     call cr 
     lea dx, errmsg3 
     call write_str
     call dos_exit  

DONE:
   xor dx,dx 
   mov dl,bl
   pop si
   pop bp
   pop cx
   pop bx 
   pop ax
   ret
str_to_int endp

; перевод строки и возврат каретки 
cr  proc near 
  push ax
  push bx
  push cx
  mov  bh,0     
  mov  cx,1
  mov  al,0Dh  ; перевод строки
  mov  ah,0eh  ; режим отображения TTY (вкл управляющие коды)
  int 10h
  mov  al,0Ah  ; возврат каретки
  mov  ah,0eh  ; 
  int 10h
  pop cx
  pop bx 
  pop ax
  ret
cr endp 


; чистка экрана, аналог cls, Int 10h
clear_scr proc near 
   push ax
   push bx
   push cx
   push dx
   xor al,al        ; al:=0 чистим окно
   xor cx,cx        ; cx:=0 верний левый угол (0,0)
   mov dh,24        ; нижняя строка экрана  24
   mov dl,79        ; правый столбец экрана 79
   mov bh,7         ; нормальные атрибуты очистки
   mov ah,6         ; вызов scroll_up 
   int 10h
   pop dx
   pop cx
   pop bx
   pop ax
   ret
clear_scr endp    

; выводим точку "."
dot proc near
push ax
push bx
push cx
  mov dl,2eh
  mov ah,02h
  int 21h 
pop cx
pop bx
pop ax
ret 
dot endp

; выводим строку при помощи прерывания int 21h 
; строка загружена в DS:DX завершается символом $  
write_str proc near 
  push ax
  mov ah,09h
  int 21h;  
  pop ax
  ret
write_str endp    


; читает строку в буфере, формат входного буфера в справке 0Ah int 21h 
; DS:DX 
read_str proc near 
  push ax
  mov al,var_a
  mov ah,0Ah
  int 21h;  
  pop ax
  ret
read_str endp    

dos_exit proc
int 20h 
dos_exit endp 
; конец сегмента
codesg  ends
; конец программы
end start