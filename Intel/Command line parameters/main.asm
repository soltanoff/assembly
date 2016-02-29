data	segment	para public 'data'	;ᥣ���� ������

      msg0 db   0ah,0dh,'A/C-C*B = $' 
   errmsg0 db   0ah,0dh,'MSG1: �訡�� �८�ࠧ������ � 楫��$'  
   errmsg1 db   0ah,0dh,'MSG2: ��९������� ࠧ�來�� �⪨$' 
   errmsg2 db   0ah,0dh,'MSG3: ������� ��  ����$'
   errmsg3 db   0ah,0dh,'MSG4: �㡫�஢���� ��� ���⮩  ��ࠬ���$' 
   errmsg4 db   0ah,0dh,'MSG5: �訡�� ��ࠬ��஢ ��������� ��ப�$'
   
   var_a        db      0
   var_b        db      0
   var_c        db      0
   
   var_temp dw 0
   
   buf  db     6 dup(' ')   
   
data	ends

stk	segment	stack
	db	256 dup ('?')	;ᥣ���� �⥪�
stk	ends

code	segment	para public 'code'	;��砫� ᥣ���� ����



;��砫� ��楤��� main
main proc	
	assume cs:code,ds:data,ss:stk
	mov	ax,data	   ; ���� ᥣ���� ������ � ॣ���� ax
	mov	ds,ax	   ; ax � ds
	;call cr     ;
	lea dx, msg0
	call write_str     ;
 	call get_cmd_line  ; � ES:SI ����� ��������� ��ப� 
 	
 	; ��ࠡ�⪠ ��������� ��ப� 
 	xor cx,cx
	mov cl,[es:si]
	inc si
        CICLE:                
            dec cx
            mov dl,[es:si]	                    
            inc si 
            
            cmp dl,2fh       ; �� ᨬ��� '/' (2fh) ?
            jne SKIP_WAIT    ; ���, �� �� ����� ���� �஡�� 
            
            mov dl,[es:si]   ; ��, �� ��砫� ����	                     
            inc si           ; �����稬 ������ 
            dec cx           ; �����訬 ���稪
            
            ; �஢�ઠ ��ࠬ��� /a
            cmp dl,61h       ; �� ᨬ��� 'a' ? 61
            jne PB           ; ���, �஢�ਬ 'b'
            test  bl,01h     ; ��ࠬ��� /a 㦥 ��⠭  ?
            jnz PARAMerr     ; �� �� �㡫� 
            xor   bl,01h     ; ���, ��⠭���� �ਧ���  ��ࠬ��� /a 
			call skip_cmp
			lea   dx,buf     ;
            call  extract_key; ��⠥� ��ࠬ��� � ���� 
            jz   PARAMerr  
            call  str_to_int ; 
            mov   var_a,dl   ;   
            jmp RETRY
          ; �஢�ઠ ��ࠬ��� /b
          PB:
            cmp dl,62h       ; �� ᨬ��� 'b' ?
            jne PD           ; ���, �஢�ਬ 'd'
            test  bl,02h     ; ��ࠬ��� /b 㦥 ��⠭  ?
            jnz PARAMerr     ; �� �� �㡫� 
            xor   bl,02h     ; ���, ��⠭���� �ਧ���  ��ࠬ��� /b 
			call skip_cmp
            lea   dx,buf     ;
            call  extract_key; ��⠥� ��ࠬ��� � ���� 
            jz   PARAMerr  
            call  str_to_int ; 
            mov   var_b,dl   ;   
            jmp  RETRY
            
          ; �஢�ઠ ��ࠬ��� /c  
          PD:
            cmp   dl,63h     ; �� ᨬ��� 'd' ?
            jne UNKNOW       ; ���, ��������� ��ࠬ���
            test  bl,04h     ; ��ࠬ��� /d 㦥 ��⠭  ?
            jnz PARAMerr     ; �� �� �㡫� 
            xor   bl,04h     ; ���, ��⠭���� �ਧ���  ��ࠬ��� /d 
			call skip_cmp
            lea   dx,buf     ;
            call  extract_key; ��⠥� ��ࠬ��� � ���� 
            jz    PARAMerr 
            call  str_to_int ; 
            mov   var_c,dl   ;   
            jmp   RETRY
            
          ; �ய�� �஡����   
          SKIP_WAIT: 
             cmp dl,20h       ; �� �஡�� ?
             jne UNKNOW       ; ��� �� ����� � ���� ᨬ��� 
          ; 
       RETRY: 
         cmp cx,0h
         jne CICLE     
       
       cmp bl,7               ; �஢�ਬ �� �� ��ࠬ���� �뫨 �������  
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
main endp		;����� ��楤��� main

skip_cmp proc
	;==========
	dec cx
    mov dl,[es:si]	                    
    inc si
	cmp dl,3dh       ; �� ᨬ��� '=' ?
    jne UNKNOW           ; ���,
	;==========
ret
skip_cmp endp

; � ES:SI  ࠧ��� ���������� ��ப� 
;   ES:SI+1 ��砫� ���������� ��ப� �����稢����� 0Dh
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


; ��ନ��� �����ப� �� ��ப�  �����稢��饩�� 0dh ࠧ����⥫� ' ' � '/'
; [ࠧ��� ����][ࠧ��� ���⠭��].......[CR]        
; �室 :
;   es:si ������ ��砫� �����ப� - ��ࠬ���   
;   ds:dx ���� ��室���� ���� 
;   cx    �᫮ ����ࠡ�⠭��� ᨬ����� ��������� ��ப� (�����)
; ��室 
;      si     ������ ���� �����ப� - ��ࠬ���    
;      [dx+1] �����  �����ப� - ��ࠬ���
;      cx     �����蠥� �᫮ ����ࠡ�⠭��� ᨬ����� �� ����� ��ப� (�����)
;      ��⠭�������� 䫠� 0 �᫨ ��ப� 0 ࠧ��� 

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
     cmp dl,0dh         ; �᫨ ���� � ����� ��࡮⪨ 
     je  FPUSH              
     cmp dl,2fh         ; �᫨ ��� � ����� ��࡮⪨ 
     je  FPUSH          
     cmp dl,20h         ; �᫨ �஡�� � ����� ��࡮⪨ 
     je  FPUSH          
     ; ���� ��੤�� � ᫥���饬� ᨬ���� �����ப� 
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
  cmp bl,00h            ; ��⠭���� 䫠� ��� 
pop  bp
pop  dx
pop  bx
pop  ax
ret   
extract_key  endp  


; ��᫮ ����㦥�� � Al   
; ��ॢ�� ��᫠ � ��ப� ����㦥���� � DS:DX
Int_To_Str proc near
  push ax
  push bx 
  push cx
  push dx
  push bp 
  

  xor cx,cx      ; ���稪 ����ᠭ��� � �⥪ ᨬ����   
  ;mov bp,dx      
  mov bx,dx		 ; ���� ��ப� ����ᥬ � Bp
  
  xor dx,dx                    
  ;mov bl,10      ; ������⥫� �� = 10

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
  div bl          ; ��᫥ ������� �  Al 楫�� ����, � Ah - ���⮪
  pop bx
  
  add ah,30h      ; ����稫� ASCII ᨬ��� ���� ���⪠ �  ah
  mov dl,ah        
  push dx         ; ��⮫���� ASCII ᨬ��� � �⥪
  inc cl          ; �����稬 ���稪 ����ᠭ��� � �⥪ ᨬ����� 
  cmp al,0        ; ���� ��⭮�  <> 0
  jnz PUSHASCII   ; �믮��塞 ������� (��ॢ�� � 10 cc)
  
; ��⮫���� �� ASCII �� �⥪� � ��ப�
POPASCII:
  pop dx          ; �믨孥� ASCII ��� �� �⥪� (� ���⭮� ���浪�)
  
  mov [bx],dl
  inc bx
  ;mov [bp],dl     ; ����ᥬ ᨬ��� � ��ப�  
  ;inc bp          ;  
  
  loop POPASCII   ; 
  
  mov [bx],24h
  ;mov [bp],24h    ; �������騩 ᨬ��� � ��ப� $  
  
  pop bp
  pop dx               
  pop cx 
  pop bx
  pop ax
  ret
Int_To_Str endp  


; A/C-C*B
; �ந������ ������ १���� � Dx
; Dl��⭮� Dh-���⮪
calculate proc near
  push ax
  push bx
  push cx
  
  xor ax,ax        
    
  ; =========================
  mov  al,var_b   ; ����ᥬ �����⥫� � Ax
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
  
  ; ��⭮� � Ax, ���⮪ � Dx 
  ; �஢�ਬ ��⭮�
  cmp al, -128  ;
  jl OVERFLOW
  cmp al, 127  ;
  jg OVERFLOW
  
  ; ᤥ���� ���⮪ ������⥫��  
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
  mov Dh,Dl   ; ��࠭�� १��� � Dh-���⮪  (㦥 ����� 0) 
  mov Dl,Al   ; Dl-��⭮�
  pop  cx
  pop  bx
  pop  ax
  ret
calculate endp 


; ltktybt Ax/Bl ��⭮� � Ax ���⮪ � Dx 
devide proc 
push bx
     
     ;cbw        ; ���ਬ ������� � AX �� ��ண� ᫮�� DX:AX
     ;push ax 
     ;mov al,bl 
     ;cbw        ; ���ਬ ����⥫� �� ᫮��
     ;mov bx,ax  ; 
     ;pop  ax
     ; ������� � DX:AX  ����⥫� � BX  
     ;==================
     cbw
     
     idiv bl  
     ;=====================
     ; ��⭮� � Ax ���⮪ � DX
pop  bx  
ret 
devide endp 
   
   
; �뢮� १���� �������    
write_result proc
push ax
push dx
       ;call cr                ; ��ॢ�� ��ப�  
       ; �뢮� ���⭮��
       xor ax,ax 
       push dx
       mov al,dl;
       lea dx,buf; 
       call int_to_str;
       call write_str;        ;      
       
       call dot               ; 
       
       ; �뢮� ���⪠         
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




; ������ � DS:DX   
; ��ॢ���� ⥪�⮢�� ��ப� � �᫮ � ������ ࠧ��஬ ���� 
; ������ � DOS �� ��९������� ࠧ�來�� �⪨  � �������⨬�� ᨬ����� � 
; ��ப� (�����⨬� ᨬ���� - + 0..9 � ����⢥���� ���浪� ᫥�������)
; ��뢠�� GOTO_XY, WRITE_STR, 

str_to_int proc near 
   push ax
   push bx
   push cx
   push bp
   push si
   xor  bx,bx  
   xor  cx,cx       ; ���㫨� ॣ���� ���稪�
   mov  bp,dx       ; ����ᥬ ���� ��ப� � Bp 
   xor  dx,dx       ; ��१ ��� ॣ���� �����⨬ ���祭��
   mov si,0         ; ���� �� 㬮�砭�� +  
   mov bl,0         ; �஬����筮� �࠭���� १���� 
   inc bp           ; �����樮���㥬 �� �᫮ ���⠭��� ᨬ����� 
   mov cl,[bp]      ; ����᪬ � Cl �᫮ ���⠭��� ᨬ����� 
   inc bp           ; ����樮���㥬 ������ �� 1� ᨬ��� � ��ப�
   mov dl,[bp]      ; ��ᬮ�ਬ 1 ᨬ��� (�஢�ਬ ���� �� �� ?)
   cmp dl,2dh       ; �� '-' ?   
   jne PLUS         ; ��� �� �� '-' (���஡㥬 �஢���� �� '+')   
   mov si,1         ; �� �� '-' , �������� ���� �᫠ 
   inc bp           ; ��३��� � ᫥���饬� ᨬ����; 
   dec cl           ; �����訬 ���稪 ��ࠡ��뢠���� ᨬ����� (㦥 1 ��ࠡ�⠭)
   jmp GO
PLUS:   
   cmp dl,2bh        ; �� '+' ? 
   jne GO            ; ��� �� �� ����
   inc bp            ; �� �� '+', ��३��� � ᫥���饬� ᨬ����;  
   dec cl            ; �����訬 ���稪 ��ࠡ��뢠���� ᨬ����� 
GO:
   xor ax,ax         ;  
   xor dx,dx         ;    
   mov dl,[bp]       ; � Dl ������� �롨ࠥ�� �� ��ப� 
   inc bp            ; � ᫥���饬� ����� ��ப�
   cmp dl,30h        ; �஢�ਬ ��  dl < '0'
   jl ERROR          ; �� ASCII ��� ����� 祬 '0' (+,- 㦥 �஢�७�)          
   cmp dl,39h        ; �஢�ਬ ��  dl > '9'   
   jg ERROR          ; ��, �� ����� ���� ᨬ���� ����� 9 (�訡��)        
   sub  dl,30h       ; �� ��� �� 0 �� 9 => Dl  
   mov al,10         ; �������⥫� �������� ���� � Al
   mul bl            ; ( ����砫쭮 = 0 )
   jo BAIT_OF        ; ��९������� �.�⪨ ���� 
   mov bl,al         ; ���࠭�� �஬����筮� �ந�������� 
   add ax,dx         ; ������ �஬�� �ந�������� � ��।��� ࠧ��
   cmp ax,128     
   jg BAIT_OF
   mov bl,al         ; ���࠭�� �஬������ १����  
   loop GO           ; ��⮬���᪨ 㬥��蠥� CX �� 1 
   ; ��।������ ����� �᫠  
   cmp si,0          ; ���� + ?
   jne SET_MINUS     ; �᫮ ����⥫쭮� (���� ��ॢ��� � ��� ���)       
   test bl,80h        ; ���  �᫮ <127
   jnz BAIT_OF        ; ��� ��������� �᫠ �� ����� >127
   jmp DONE          ; �� �� + �᫮ � ��������� <=127
; 
SET_MINUS:    
    neg  bl          ; ��ॢ���� �᫮ � ��� ���
    test bl,80h      ; ��᫮ ����� -128 
    jz  BAIT_OF      ; �� ��� �����
    jmp DONE         ; �᫨ ��� ��९������� � �� ��     
; 
; ��ࠡ�⪠ ��९������� ࠧ�來�� �⪨ 
BAIT_OF: 
     call cr
     lea dx, errmsg1 
     call write_str
     call dos_exit
     
; ��ࠡ�⪠ �訡���� ᨬ����� ()  
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

; ��ॢ�� ��ப� � ������ ���⪨ 
cr  proc near 
  push ax
  push bx
  push cx
  mov  bh,0     
  mov  cx,1
  mov  al,0Dh  ; ��ॢ�� ��ப�
  mov  ah,0eh  ; ०�� �⮡ࠦ���� TTY (������� �ࠢ���騥 ����)
  int 10h
  mov  al,0Ah  ; ������ ���⪨
  mov  ah,0eh  ; 
  int 10h
  pop cx
  pop bx 
  pop ax
  ret
cr endp 


; ���⪠ �ᥣ� �࠭�, �������筮 cls, Int 10h
clear_scr proc near 
   push ax
   push bx
   push cx
   push dx
   xor al,al        ; al:=0 ������ ����
   xor cx,cx        ; cx:=0 ���孨� ���� 㣮� (0,0)
   mov dh,24        ; ������ ��ப� �࠭�  24
   mov dl,79        ; �ࠢ� �⮫��� �࠭� 79
   mov bh,7         ; ��ଠ��� ��ਡ��� ���⪨
   mov ah,6         ; �맮� �㭪樨 scroll_up 
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

; �뢮��� ��ப� �� �࠭ int 21h 
; ��ப� ����㦥�� DS:DX �����蠥��� ᨬ����� $  
write_str proc near 
  push ax
  mov ah,09h
  int 21h;  
  pop ax
  ret
write_str endp    


; ��⠥� ��ப� � ����, �ଠ� �室���� ���� � ��ࠢ�� �� 0Ah int 21h 
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
   mov ax,4c01h         ; ��室 � DOS c ����� 1 
   int 21h
dos_exit endp 


code	ends		;����� ᥣ���� ����
end	main		;����� �ணࠬ�� � �窮� �室� main
