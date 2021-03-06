	.ref _c_int00
_c_int00:
;=======================================	
	.data
array:	.int 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
;=======================================
	.text	
		MVKL .S1 array,A1		; записываем в регистр А0 адрес начала массива
		|| MVKL .S2 array,B1	; записываем в регистр B0 адрес начала массива
 		MVKH .S1 array,A1
 		|| MVKH .S2 array,B1

		|| MV .L1 A1,A4
		|| ADD .L2 B1,4,B4

		|| LDW .D1 *A1[0],A8 ; запоминаем 1 элемент

		LDW .D1 *A1[1],B8 ; запоминаем 2 элемент 
		|| ADD .L1 A1,8,A1
		|| ADD .L2 B1,12,B1
		|| MVK .S2 8,B0 ; счетчик переходов в цикле 
;=======================================
		B .S2 LOOP
		|| LDW .D1 *A1++[2],A11
		|| LDW .D2 *B1++[2],B11
		NOP
		B .S2 LOOP
		|| LDW .D1 *A1++[2],A11
		|| LDW .D2 *B1++[2],B11
		NOP
LOOP:
		[B0] B .S2 LOOP
		|| LDW .D1 *A1++[2],A11
		|| LDW .D2 *B1++[2],B11	
		STW .D1 A11,*A4++[2]
		|| STW .D2 B11,*B4++[2]
		|| [B0] SUB .S2 B0,1,B0
;=======================================
		STW .D1 A8,*A4
		|| STW .D2 B8,*B4
		NOP
.end