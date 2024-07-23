STACK SEGMENT PARA STACK 'STACK' ; Defines Segment (block of memory) of type Stack (stack data structures live here?) named 'stack' (optional param). para means paragraph-aligned (memory address is at a multiple of 16).
  DB 64 DUP (' ') ; Reserves 64 bytes of memory, initialized to 0, for the stack. DB - Defined Byte, 64 DUP(licate) 0 (64 times)
STACK ENDS ; End of Stack

DATA SEGMENT PARA 'DATA' ; Data Segments are storage for variables and constants

DATA ENDS

CODE SEGMENT PARA 'CODE' ; Code Segments contains the actual machine instructions that the CPU executes

  MAIN PROC FAR ; name of Procedure and entry point because MAIN name. PROC indicates start. FAR is type of procedure (eg. can be called from any segment in seg mem model? opposite is NEAR)
    RET
  MAIN ENDP ; End of procedure (PROC)

CODE ENDS ; End of CODE SEGMENT
END MAIN ; END - End of source file, MAIN - labels MAIN as entry point