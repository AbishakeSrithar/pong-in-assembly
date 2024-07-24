; https://stackoverflow.com/questions/36219498/change-the-background-color-of-dosbox-console-when-executing-a-tasm-program
 TITLE screen1.ASM
.MODEL SMALL

.STACK 0100h
.DATA

.CODE
start:
MOV AX,@DATA
MOV DS,AX



MOV AX,0600h 
MOV BH,17h   
MOV CX,0000h  
MOV DX,184Fh  
INT 10h

MOV AH,02h   ;settin cursor position 
MOV BH,00h   ;page number
MOV DH,0Ch    ;row
MOV DL,28h   ;column
INT 10h

MOV AH,02h
MOV DL,'x'
INT 21h

MOV AX,4C00h
INT 21h
END start