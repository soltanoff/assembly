#Shift array
====================

This project examined the development of the principles of building 
applications in assembly language for the system of Texas Instruments, 
introduction of teams and rules of construction programs in accordance 
with the peculiarities of the conveyor and parallel execution of commands.

OBJECTIVE 
------------
Develop a program, moves the array elements in the two positions to the left. 
The released cells left side of the array elements are filled with the right part.

THE ADVANTAGE OF THE TASK
------------
The number of CPU cycles when the algorithm is directly proportional to the length of the array (without initialization of objects). 
This is achieved through parallel processing conveyor TMS.

BUILD SETTINGS
------------
Debug: Options=-g -q -al -fr"%\Debug" -d"_DEBUG" -mv6200

Release: Options=-q -o3 -fr"%\Release"
