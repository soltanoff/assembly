; A+C-C*B
	.ref _c_int00
_c_int00:

	.text
	
		MVK .S1 30,A0 		;A = 30
		MVK .S1  6,A1		;B = 6
		MVK .S1  5,A2		;C = 5
		
		MPY .M1 A2,A1,A1	;B = C*B
		NOP
		
		SUB .S1 A2,A1,A1	;B = C-B
		
		ADD .S1	A0,A1,A1	;B = A+B