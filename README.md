# pong-in-assembly
Making Pong in Assembly \
Credit: https://www.youtube.com/watch?v=dyANHsj2UOw&list=PLvpbDCl_H7mfgmEJPl1bTHlH5g-f0kWDM&index=2&ab_channel=ProgrammingDimension

How to run Assembly stuff:

mount c e:\pong (wherever your pong.asm is)
c: (navigate to mount)
masm /a pong.asm (MASM converts to machine code and /a detailed listing file that contains the original source code along with the generated machine code and other related information)
link pong (links an object file (machine code) produced by the assembler into an executable)
pong (runs the pong.exe)

