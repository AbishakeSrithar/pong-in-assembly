STACK SEGMENT PARA STACK 'STACK' ; Defines Segment (block of memory) of type Stack (stack data structures live here?) named 'stack' (optional param). para means paragraph-aligned (memory address is at a multiple of 16).
  DB 64 DUP (0) ; Reserves 64 bytes of memory, initialized to 0, for the stack. DB - Defined Byte, 64 DUP(licate) 0 (64 times)
STACK ENDS ; End of Stack

DATA SEGMENT PARA 'DATA' ; Data Segments are storage for variables and constants
DATA ENDS

CODE SEGMENT PARA 'CODE' ; Code Segments contains the actual machine instructions that the CPU executes
  ASSUME CS:CODE, DS:DATA, SS:STACK ; Tells Assembler to Assume CS, DS, SS registers (on CPU memory 8,16,32,64 bits? fast access) are associated with CODE, DATA, STACK segments

  MAIN PROC FAR ; name of Procedure and entry point because MAIN name. PROC indicates start. FAR is type of procedure (eg. can be called from any segment in seg mem model? opposite is NEAR)
    MOV AX, DATA ; AX is a 16 bit general register. MOV moves base address from DATA to AX register
    MOV DS, AX  ; Initialize data segment

    MOV DL, 'A' ; Character to print
    MOV AH, 2 ; Function 2 - Display character in DL (AH to 2 specifies that the program wants to use DOS function 2)
    INT 21h ; DOS interrupt (Performs the above function)

    MOV AX, 4C00h ; Terminate program ( 4C is the function number for terminating the program, and 00 is the return code)
    INT 21h ; DOS interrupt (And performs above function)
  MAIN ENDP ; End of procedure (PROC)

CODE ENDS ; End of CODE SEGMENT
END MAIN ; END - End of source file, MAIN - labels MAIN as entry point