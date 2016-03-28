# Timer: Chanel 2

The objective of this project is the development of principles of 
construction of simple console applications in Assembly 
language for MS-DOS, learning teams and ways of addressing 
the Assembly language and the rules of building programs in 
accordance with the structural method of programming.

The timer correspond to the four port I/o with the following addresses: 
* 40h channel 0 (IRQ0 generates);

* 41h - channel 1 (supports upgrades of memory); 

* 42h channel 2 (speaker controls); 

* 43h - control register. 

BCD field defines the format of the constants used to account binary 
or binary-coded decimal. In BCD mode, the constant is set in the 
range 1-9999. 


Field M specifies the operating modes of the 8254 chip:
 

* 0 - interrupt from the timer; 


* 1 - programmable standby multivibrator; 


* 2 programmable pulse generator; 


* 3 - square wave generator; 


* 4 - software-triggered, single-shot; 


* 5 - hardware-triggered single-shot the. 


We will consider only the mode 3, because it is used in channels 0 and 
2. 
Field RW defines the method of loading constants using single-byte 
port. If this field is set to 00, this control word will be used to 
lock the current contents of the registers of the meter CE in the 
buffer register OL for the purpose of the reading program. This command 
code CLC - locking registers. Code of the channel to be fixing, should 
be specified in the SC. M and BCD fields are not used. 
SC field 
specifies the channel number for which the control word is intended. 
If this field is set to 11, will read the state of the channel. 



ABOUT SPEAKER
-----------

To program the speaker: after programming channel 2 
of the timer must still include the speaker itself. 
This is done by setting bits 0 and 1 of port 61h 1.

...

in al,61h

or al,00000011h

out 61h,al

...

Bit 0 enables the timer channel, and bit 1 enables speaker. 