STACK SEGMENT PARA STACK 'STACK' ; Defines Segment (block of memory) of type Stack (stack data structures live here?) named 'stack' (optional param). para means paragraph-aligned (memory address is at a multiple of 16).
  DB 64 DUP (' ') ; Reserves 64 bytes of memory, initialized to 0, for the stack. DB - Defined Byte, 64 DUP(licate) 0 (64 times)
STACK ENDS ; End of Stack

DATA SEGMENT PARA 'DATA' ; Data Segments are storage for variables and constants

DATA ENDS

CODE SEGMENT PARA 'CODE' ; Code Segments contains the actual machine instructions that the CPU executes

  MAIN PROC FAR ; name of Procedure and entry point because MAIN name. PROC indicates start. FAR is type of procedure (eg. can be called from any segment in seg mem model? opposite is NEAR)
    
    MOV AH, 00h ; Function to set video mode
    MOV AL, 13h ; https://mendelson.org/wpdos/videomodes.txt video mode: 320x200 256 colour
    INT 10h ; the 17th (hexadec) interrupt vector (executes the function above)

    ; tutorial
    ; MOV AH, 0Bh ; Set config type to parent of background (display/cursor pos, other vid adjacent)
    ; MOV BH, 00h ; To the background colour
    ; MOV BL, 01h ; choose black as background colour
    ; INT 10h ; executes above

    ; stackoverflow but gives wrong colour/code
    ; MOV AX,0600h 
    ; MOV BH, 48h   
    ; MOV CX,0000h  
    ; MOV DX,184Fh  
    ; INT 10h

    ; chatgpt (works)
    MOV AX, 0A000h     ; Video memory segment
    MOV ES, AX
    MOV DI, 0000h      ; Start at the beginning of video memory
    MOV AL, 04h        ; Color index for red (assuming 04h is red in the current palette)
    MOV CX, 320 * 200  ; Number of pixels to fill
    REP STOSB          ; Fill the screen with the color

    MOV AH, 0Ch ; Set the config to writing a pixel
    MOV AL, 0Fh ; Choose White colour
    MOV BH, 00h ; Set the page number to 0
    MOV CX, 0Ah ; Set the column (x)
    MOV DX, 0Ah ; Set the line (y)
    INT 10h ; executes above
    
    RET
  MAIN ENDP ; End of procedure (PROC)

CODE ENDS ; End of CODE SEGMENT
END MAIN ; END - End of source file, MAIN - labels MAIN as entry point