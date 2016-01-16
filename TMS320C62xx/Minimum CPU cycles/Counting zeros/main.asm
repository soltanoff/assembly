	.ref _c_int00
_c_int00:
		
 .data   ; ������

array:	.byte 0, 0, 1, 0, 0, 8, 6, 4, 5, 0, 7, 8, 0, 9, 3, 2, 1, 0, 0, 1, 0, 0, 0, 0		; ������ (��� ����)

 .text   ; ���

		; A0 - ������ �������
		; B0 - ������ �������
		; A1 - ����� �������� �������� 1
		; B1 - ����� �������� �������� 2
		; A2 - ������� ������� 1
		; B2 - ������� ������� 2
		; A3 - ������� ����� 1
		; B3 - ������� ����� 2
		
 		MVKL .S1  array,A0    		; ��������� ����� ������� � A0,B0 			[1]
		|| MVKL .S2  array,B0		;

		MVKH .S1  array,A0			; ��������� ����� ������� � A0,B0 			[1]
		|| MVKH .S2  array,B0		;
				
		MVK .S2  6,B1  				; ������� � B1 = 12						[1]
		|| ADD .L2 B0, 12, B0

		B .S1  LOOP					; ������� ���� A1 <> 0						[6]
		|| LDB .D1  *A0++, A2		; ������� ������� ������� 1 � A2         	[5]	
		|| LDB .D2  *B0++, B2		; ������� ������� ������� 2 � B2         	[5]	

		B .S1  LOOP					; ������� ���� A1 <> 0						[6]
		|| LDB .D1  *A0++, A2		; ������� ������� ������� 1 � A2         	[5]	
		|| LDB .D2  *B0++, B2		; ������� ������� ������� 2 � B2         	[5]	

		B .S1  LOOP					; ������� ���� A1 <> 0						[6]
		|| LDB .D1  *A0++, A2		; ������� ������� ������� 1 � A2         	[5]	
		|| LDB .D2  *B0++, B2		; ������� ������� ������� 2 � B2         	[5]	

		B .S1  LOOP					; ������� ���� A1 <> 0						[6]
		|| LDB .D1  *A0++, A2		; ������� ������� ������� 1 � A2         	[5]	
		|| LDB .D2  *B0++, B2		; ������� ������� ������� 2 � B2         	[5]	
		
		B .S1  LOOP					; ������� ���� A1 <> 0						[6]
		|| LDB .D1  *A0++, A2		; ������� ������� ������� 1 � A2         	[5]	
		|| LDB .D2  *B0++, B2		; ������� ������� ������� 2 � B2         	[5]	

LOOP:
	;/////////////////////////////////////
		[B1] B .S1  LOOP			; ������� ���� A1 <> 0
		|| [B1] SUB .S2  B1,1,B1    ; ��������� �������	�������� �������� 1		[6]	
		|| LDB .D1  *A0++, A2		; ������� ������� ������� 1 � A2         	[5]	
		|| LDB .D2  *B0++, B2		; ������� ������� ������� 2 � B2         	[5]	
		|| [!A2] ADD .L1  A3,1,A3	; ���� ������� ������� 1 = 0 �� ��������� �������� �����
		|| [!B2] ADD .L2  B3,1,B3	; ���� ������� ������� 2 = 0 �� ��������� �������� �����
	;//////////////////////////////////////
	ADD .L2 A3, B3, B1
	NOP
.end