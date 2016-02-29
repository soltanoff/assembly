data	segment	para public 'data'	;сегмент данных

      msg0 db   0ah,0dh,'A/C-C*B = $' 
   errmsg0 db   0ah,0dh,'MSG1: Ошибка преобразования в целое$'  
   errmsg1 db   0ah,0dh,'MSG2: Переполнение разрядной сетки$' 
   errmsg2 db   0ah,0dh,'MSG3: Деление на  ноль$'
   errmsg3 db   0ah,0dh,'MSG4: Дублированный или пустой  параметр$' 
   errmsg4 db   0ah,0dh,'MSG5: Ошибка параметров командной строки$'
   
   var_a        db      0
   var_b        db      0
   var_c        db      0
   
   var_temp dw 0
   
   buf  db     6 dup(' ')   
   
data	ends

stk	segment	stack
	db	256 dup ('?')	;сегмент стека
stk	ends

code	segment	para public 'code'	;начало сегмента кода



;начало процедуры main
main proc	
	assume cs:code,ds:data,ss:stk
	mov	ax,data	   ; адрес сегмента данных в регистр ax
	mov	ds,ax	   ; ax в ds
	;call cr     ;
	lea dx, msg0
	call write_str     ;
 	call get_cmd_line  ; В ES:SI Длина командной строки 
 	
 	; Обработка командной строки 
 	xor cx,cx
	mov cl,[es:si]
	inc si
        CICLE:                
            dec cx
            mov dl,[es:si]	                    
            inc si 
            
            cmp dl,2fh       ; Это символ '/' (2fh) ?
            jne SKIP_WAIT    ; Нет, но это может быть пробел 
            
            mov dl,[es:si]   ; Да, Это начало ключа	                     
            inc si           ; Увеличим индекс 
            dec cx           ; Уменьшим счетчик
            
            ; Проверка параметра /a
            cmp dl,61h       ; Это символ 'a' ? 61
            jne PB           ; Нет, проверим 'b'
            test  bl,01h     ; Параметра /a уже считан  ?
            jnz PARAMerr     ; Да это дубль 
            xor   bl,01h     ; Нет, установим признак  параметра /a 
			call skip_cmp
			lea   dx,buf     ;
            call  extract_key; Читает параметр в буфер 
            jz   PARAMerr  
            call  str_to_int ; 
            mov   var_a,dl   ;   
            jmp RETRY
          ; Проверка параметра /b
          PB:
            cmp dl,62h       ; Это символ 'b' ?
            jne PD           ; Нет, проверим 'd'
            test  bl,02h     ; Параметра /b уже считан  ?
            jnz PARAMerr     ; Да это дубль 
            xor   bl,02h     ; Нет, установим признак  параметра /b 
			call skip_cmp
            lea   dx,buf     ;
            call  extract_key; Читает параметр в буфер 
            jz   PARAMerr  
            call  str_to_int ; 
            mov   var_b,dl   ;   
            jmp  RETRY
            
          ; Проверка параметра /c  
          PD:
            cmp   dl,63h     ; Это символ 'd' ?
            jne UNKNOW       ; Нет, неизвестный параметр
            test  bl,04h     ; Параметра /d уже считан  ?
            jnz PARAMerr     ; Да это дубль 
            xor   bl,04h     ; Нет, установим признак  параметра /d 
			call skip_cmp
            lea   dx,buf     ;
            call  extract_key; Читает параметр в буфер 
            jz    PARAMerr 
            call  str_to_int ; 
            mov   var_c,dl   ;   
            jmp   RETRY
            
          ; Пропуск пробелов   
          SKIP_WAIT: 
             cmp dl,20h       ; Это пробел ?
             jne UNKNOW       ; Нет это какой то левый символ 
          ; 
       RETRY: 
         cmp cx,0h
         jne CICLE     
       
       cmp bl,7               ; Проверим все ли параметры были найдены  
       jne UNKNOW             ; 
       
       call calculate; 
       call write_result; 
       call dos_exit      
UNKNOW:
    lea dx,errmsg4
    call write_str 
    call dos_exit
         
PARAMerr:
    lea dx,errmsg3
    call write_str 
	call cr
    call dos_exit
main endp		;конец процедуры main

skip_cmp proc
	;==========
	dec cx
    mov dl,[es:si]	                    
    inc si
	cmp dl,3dh       ; Это символ '=' ?
    jne UNKNOW           ; Нет,
	;==========
ret
skip_cmp endp

; В ES:SI  размер коммандной строки 
;   ES:SI+1 начало коммандной строки заканчивается 0Dh
get_cmd_line proc  
push ax
push bx
  mov ah,62h
  int 21h
  mov bx,80h 
  lea si,es:bx
pop bx
pop ax
ret
get_cmd_line endp 


; Формирует подстроку из строки  заканчивающейся 0dh разделитель ' ' и '/'
; [размер буфера][размер прочитанный].......[CR]        
; Вход :
;   es:si Индекс начала подстроки - параметра   
;   ds:dx адрес выходного буфера 
;   cx    число необработанных символов командной строки (необяз)
; Выход 
;      si     Индекс конца подстроки - параметра    
;      [dx+1] Длина  подстроки - параметра
;      cx     Уменьшает число необработанных символов на длину строки (необяз)
;      Устанавливает флаг 0 если строка 0 размера 

extract_key  proc 
push ax
push bx
push dx
push bp 

  mov bx,dx
  
  xor ax,ax
  mov ax,dx; 
  
  xor dx,dx
  add bx,2 
  SPUSH:
     mov dl,[es:si]
     cmp dl,0dh         ; Если ентер то конец обрботки 
     je  FPUSH              
     cmp dl,2fh         ; Если слэш то конец обрботки 
     je  FPUSH          
     cmp dl,20h         ; Если пробел то конец обрботки 
     je  FPUSH          
     ; Иначе перйдем к следующему символу подстроки 
     mov [ds:bx],dl
     inc bx             ;
     inc si             ;
     jmp SPUSH
  FPUSH: 
  push ax
  
  mov al,0dh
  mov  [ds:bx],al  

  pop ax
  
  
  sub bx,ax

  sub bx,2 
  
  push dx
  push bx
  
  mov dx, bx
  mov bx, ax
  
  mov [ds:bx+1],dl
  
  pop bx
  pop dx
     
  sub cx,bx             ;  
  cmp bl,00h            ; Установим флаг нуля 
pop  bp
pop  dx
pop  bx
pop  ax
ret   
extract_key  endp  


; Число загружено в Al   
; Перевод Числа в строку загруженную в DS:DX
Int_To_Str proc near
  push ax
  push bx 
  push cx
  push dx
  push bp 
  

  xor cx,cx      ; Счетчик записанных в стек симолов   
  ;mov bp,dx      
  mov bx,dx		 ; Адрес строки занесем в Bp
  
  xor dx,dx                    
  ;mov bl,10      ; Показатель СС = 10

  cmp al,0h       
  jg PUSHASCII     
  jz PUSHASCII       
  
  neg al 
  
  mov [bx],2dh
  inc bx

  
PUSHASCII:
  cbw             ;
  xor ah,ah
  
  push bx
  mov bl,10
  div bl          ; После деления в  Al целая часть, В Ah - остаток
  pop bx
  
  add ah,30h      ; Получили ASCII символ цифры остатка в  ah
  mov dl,ah        
  push dx         ; Затолкнем ASCII символ в стек
  inc cl          ; Увеличим счетчик записанных в стек символов 
  cmp al,0        ; Пока частное  <> 0
  jnz PUSHASCII   ; выполняем деление (перевод в 10 cc)
  
; Вытолкнем все ASCII из стека в строку
POPASCII:
  pop dx          ; выпихнем ASCII код из стека (В обратном порядке)
  
  mov [bx],dl
  inc bx
  ;mov [bp],dl     ; Занесем символ в строку  
  ;inc bp          ;  
  
  loop POPASCII   ; 
  
  mov [bx],24h
  ;mov [bp],24h    ; Завершающий символ в строке $  
  
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
  
  ;jo OVERFLOW 
  
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
  cmp dl,0           
  jg FINISH   
  neg dl         
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
     
     ;cbw        ; расширим делиное в AX до второго слова DX:AX
     ;push ax 
     ;mov al,bl 
     ;cbw        ; расширим делитель до слова
     ;mov bx,ax  ; 
     ;pop  ax
     ; делимое в DX:AX  делитель в BX  
     ;==================
     cbw
     
     idiv bl  
     ;=====================
     ; частное в Ax остаток в DX
pop  bx  
ret 
devide endp 
   
   
; Вывод результата деления    
write_result proc
push ax
push dx
       ;call cr                ; перевод строки  
       ; Вывод Частного
       xor ax,ax 
       push dx
       mov al,dl;
       lea dx,buf; 
       call int_to_str;
       call write_str;        ;      
       
       call dot               ; 
       
       ; Вывод остатка         
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




; СТРОКА в DS:DX   
; Переводит текстовую строку в число со знаком размером байт 
; возврат в DOS при переполнении разрядной сетки  и недопустимых символах в 
; строке (допустимы символы - + 0..9 в естественном порядке следования)
; Вызывает GOTO_XY, WRITE_STR, 

str_to_int proc near 
   push ax
   push bx
   push cx
   push bp
   push si
   xor  bx,bx  
   xor  cx,cx       ; Обнулим регистр счетчика
   mov  bp,dx       ; Занесем адрес строки в Bp 
   xor  dx,dx       ; Через этот регистр возвратим значение
   mov si,0         ; Знак по умолчанию +  
   mov bl,0         ; Промежуточное хранение результата 
   inc bp           ; Спозиционируем на число прочитанных символов 
   mov cl,[bp]      ; Занескм в Cl число прочитанных символов 
   inc bp           ; Позиционируем индекс на 1й символ в строке
   mov dl,[bp]      ; Посмотрим 1 символ (Проверим знак ли это ?)
   cmp dl,2dh       ; Это '-' ?   
   jne PLUS         ; Нет это не '-' (Попробуем проверить на '+')   
   mov si,1         ; Да это '-' , Запомним знак числа 
   inc bp           ; Перейдем к следующему символу; 
   dec cl           ; Уменьшим счетчик обрабатываемых символов (уже 1 обработан)
   jmp GO
PLUS:   
   cmp dl,2bh        ; Это '+' ? 
   jne GO            ; НЕТ это не плюс
   inc bp            ; Да это '+', Перейдем к следующему символу;  
   dec cl            ; Уменьшим счетчик обрабатываемых символов 
GO:
   xor ax,ax         ;  
   xor dx,dx         ;    
   mov dl,[bp]       ; В Dl Символы выбираемые из строки 
   inc bp            ; К следующему байту строки
   cmp dl,30h        ; Проверим на  dl < '0'
   jl ERROR          ; Это ASCII код меньше чем '0' (+,- уже проверены)          
   cmp dl,39h        ; Проверим на  dl > '9'   
   jg ERROR          ; Да, не может быть символа больше 9 (ошибка)        
   sub  dl,30h       ; Это цифра от 0 до 9 => Dl  
   mov al,10         ; Сомножителю положено быть в Al
   mul bl            ; ( Изначально = 0 )
   jo BAIT_OF        ; Переполнение р.сетки байта 
   mov bl,al         ; Сохраним промежуточное произведение 
   add ax,dx         ; Сложим промеж произведение и очередной разряд
   cmp ax,128     
   jg BAIT_OF
   mov bl,al         ; Сохраним промежуточный результат  
   loop GO           ; Автоматически уменьшает CX на 1 
   ; Определение знака числа  
   cmp si,0          ; Знак + ?
   jne SET_MINUS     ; число отрицательное (надо перевести в доп код)       
   test bl,80h        ; Нет  число <127
   jnz BAIT_OF        ; Для знакового числа это много >127
   jmp DONE          ; Все ОК + число в диапазоне <=127
; 
SET_MINUS:    
    neg  bl          ; Переведем число в доп код
    test bl,80h      ; Число меньше -128 
    jz  BAIT_OF      ; Да оно меньше
    jmp DONE         ; Если нет переполнения то все ОК     
; 
; Обработка переполнения разрядной сетки 
BAIT_OF: 
     call cr
     lea dx, errmsg1 
     call write_str
     call dos_exit
     
; Обработка ошибочных символов ()  
ERROR: 
     call cr 
     lea dx, errmsg0 
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

; Перевод строки и возврат каретки 
cr  proc near 
  push ax
  push bx
  push cx
  mov  bh,0     
  mov  cx,1
  mov  al,0Dh  ; Перевод строки
  mov  ah,0eh  ; режим отображения TTY (Работают управляющие коды)
  int 10h
  mov  al,0Ah  ; Возврат каретки
  mov  ah,0eh  ; 
  int 10h
  pop cx
  pop bx 
  pop ax
  ret
cr endp 


; Очистка всего экрана, аналогично cls, Int 10h
clear_scr proc near 
   push ax
   push bx
   push cx
   push dx
   xor al,al        ; al:=0 Очистить окно
   xor cx,cx        ; cx:=0 Верхний левый угол (0,0)
   mov dh,24        ; Нижняя строка экрана  24
   mov dl,79        ; Правый столбец экрана 79
   mov bh,7         ; Нормальные атрибуты очистки
   mov ah,6         ; вызов функции scroll_up 
   int 10h
   pop dx
   pop cx
   pop bx
   pop ax
   ret
clear_scr endp    


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

; Выводит строку на экран int 21h 
; Строка загружена DS:DX завершается символом $  
write_str proc near 
  push ax
  mov ah,09h
  int 21h;  
  pop ax
  ret
write_str endp    


; Читает строку в буфер, формат входного буфера в Справке по 0Ah int 21h 
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
   mov ax,4c01h         ; Выход в DOS c кодом 1 
   int 21h
dos_exit endp 


code	ends		;конец сегмента кода
end	main		;конец программы с точкой входа main
