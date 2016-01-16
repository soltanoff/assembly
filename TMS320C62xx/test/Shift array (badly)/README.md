#Shift array
====================

This failure to implement the solution. The number of cycles is minimized, but used almost 
all of the CPU registers.
Solution hones on the basis that the loop has a delay of 5 clock cycles.

OBJECTIVE 
------------
Develop a program, moves the array elements in the two positions to the left. 
The released cells left side of the array elements are filled with the right part.

BUILD SETTINGS
------------
Debug: Options=-g -q -al -fr"%\Debug" -d"_DEBUG" -mv6200

Release: Options=-q -o3 -fr"%\Release"
