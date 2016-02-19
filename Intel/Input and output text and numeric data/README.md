# I/O on 8086 processor

The objective of this project is the development of principles of 
construction of simple console applications in Assembly 
language for MS-DOS, learning teams and ways of addressing 
the Assembly language and the rules of building programs in 
accordance with the structural method of programming.

COM file is the simplest form of the executable file in the MS-DOS and is an exact copy of a program 
in binary form in which it is necessary to load into memory. COM files do not contain a prefix. They do 
not contain address constants, dependent on load addresses in program memory. Everything in the program 
is represented as an offset from the beginning of the code segment, including the data and stack. Consequently, 
the program size cannot exceed 64 Kbytes. Therefore, loading SOM files, defining a large enough free block of 
memory, the construction of the PSP (Program Segment Prefix) and read the whole file in the area after PSP.


In the field of PSP stored system information for the program. The PSP area is always 256 bytes. The content and purpose 
of this field lab will not be considered.


The registers CS, DS, SS and ES given the value of the segment (the segment 
address of the PSP). The instruction pointer IP gets the value of 100N. SP gets the value of FFFEH, i.e., the end address 
space of 64 Kbytes is used for the stack. The byte at address FFFEH on the stack contains 00Í, so that after the RET command 
at the end of the program in IP value 00Í is obtained, i.e., executes the instruction INT 20H, recorded at the beginning of 
the PSP


This code solve A/C-C*B, where A, B, C - signed bytes


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
