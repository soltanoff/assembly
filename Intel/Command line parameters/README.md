# I/O on 8086 processor using parameters from command line

The aim of this research is the development of the principles of passing parameters 
via the command line and the build files of type EXE.

In the course of performing the 
work necessary to develop a program, performs input processing of digital data by a given 
formula. The input data is performed from the command line in the format: 
/<parameter name>=<value>. Be aware that the user can specify parameters in 
any order, for example: “ /a=5 /b=10 /d=15 “ or “ /d=15 /b=10 /a=5 “, i.e. 
the program should be able to analyze the names of the parameters and correctly fill 
out their contents. The program should be monitoring the correctness of data entry, 
i.e. a control of the adequacy of the parameters belonging to the specified ranges of 
the input values and the correct execution of the conversion - control of the overflow 
bit of the grid in arithmetic operations. When errors occur should show the appropriate 
message. The text and format of the messages to come up with their own. 
	 

When performing laboratory work in the program is permitted to use BIOS functions and DOS. 


The program must be written for real mode operation of the microprocessor using instructions 
of the processor 8086 - 80286. The type of the uploaded file EXE. The text of the program should 
contain comments and must be built on the principle of structured programming. Ie shall be 
present the procedure of data input, translation of data from numeric format to string and 
Vice versa, as well as the procedure of mathematical processing that can be used in other 
labs. Please note, in later labs in the use of DOS functions can be prohibited.



This code solve A/C-C*B, where A, B, C - signed bytes


Example: main.exe /a=65 /b=30 /c=-2

Result: A/C-C*B = 28.0

ABOUT I/O
-----------

The use of the basic functions provided by the BIOS, allows you to correct this deficiency. For personal computers the BIOS is 
always there, and it rarely throw out modules associated with I / o. But these functions implement only the simplest designs 
for the organization of input / output, which cannot meet even quite modest requirements for UI. Plus the use of BIOS functions 
consists in abstracting from the specific operating system and specific hardware devices, that allows to preserve the consistency 
of the program when porting to another operating system or implementation of computing machines.
In some cases, when the BIOS cannot 
use, or need to perform I / o using unsupported equipment, used the method of direct operation of the hardware. This is the most difficult 
option I / o, since it is necessary to clearly represent the architecture of the computing machines, the circuitry and principles of the 
organization of interaction with specialized devices. 

In this lab, this way I / o is not considered.
To access the BIOS and the operating system MS-DOS uses a software interrupt mechanism, the program populates the registers with values and call the interrupt command INT. 
The 
use of this approach is explained as follows. Function I / o - a set of procedures different procedures. 

When the program is compiled it is impossible to know in which area of memory will be these procedures, namely the interrupt mechanism allows to abstract from a particular physical 
address implementation. The fact is that the interrupt handler is a special procedure whose address is in the special interrupt vector table. 
The procedure call is made to the wrong address, and the number of the interrupt vector (row in the interrupt table). Responsible for completion 
of table are the BIOS and the operating system that allows a programmer not to think about it. Moreover, this mechanism provides the ability to 
overlap and complement the basic functions, due to changing the interrupt handler, and the code is dramatically reduced, as an INT takes up 
less memory than other teams.
Consider the basic functions of the I / o system MS-DOS. Access to these functions, and all functions of MS-DOS, 
by using the interrupt vector with number 21h.
The functions for reading from the keyboard differ mainly according to three criteria: do you 
expect the enter or return information that there is no cash characters; deduce after reading the symbol on the screen or not (with echo or 
without echo); checking whether when the presence of a Ctrl-Break or not.
