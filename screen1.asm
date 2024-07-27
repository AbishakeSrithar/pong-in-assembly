STACK SEGMENT PARA STACK 'STACK' ; Defines Segment (block of memory) of type Stack (stack data structures live here?) named 'stack' (optional param). para means paragraph-aligned (memory address is at a multiple of 16).
  DB 64 DUP (' ') ; Reserves 64 bytes of memory, initialized to 0, for the stack. DB - Defined Byte, 64 DUP(licate) 0 (64 times)
STACK ENDS ; End of Stack

DATA SEGMENT PARA 'DATA' ; Data Segments are storage for variables and constants

  BALL_X DW 0Ah ; x position (col) of ball (dw - defined word can hold 16bits instead of db-8)
  BALL_Y DW 0Ah ; y position (row) of ball
  BALL_SIZE DW 04h ; size of the ball (no pixels in width/height)

DATA ENDS

CODE SEGMENT PARA 'CODE' ; Code Segments contains the actual machine instructions that the CPU executes

  MAIN PROC FAR ; name of Procedure and entry point because MAIN name. PROC indicates start. FAR is type of procedure (eg. can be called from any segment in seg mem model? opposite is NEAR)
  ASSUME CS:CODE, DS:DATA, SS:STACK ; Tell Code Segment about code, data, stack registers
  PUSH DS ; push the DS Segment to the stack
  SUB AX, AX ; Clean the AX register
  PUSH AX ; Push AX to the stack
  MOV AX, DATA ; Put DATA into AX
  MOV DS, AX ; Put AX into DS
  POP AX ; pop top item of stack to the AX register
  POP AX; release top item (again)
    
    MOV AH, 00h ; Function to set video mode
    MOV AL, 13h ; https://mendelson.org/wpdos/videomodes.txt video mode: 320x200 256 colour
    INT 10h ; the 17th (hexadec) interrupt vector (executes the function above)

    MOV AX, 0A000h     ; Video memory segment
    MOV ES, AX
    MOV DI, 0000h      ; Start at the beginning of video memory
    MOV AL, 04h        ; Color index for red (assuming 04h is red in the current palette)
    MOV CX, 320 * 200  ; Number of pixels to fill
    REP STOSB          ; Fill the screen with the color

    CALL DRAW_BALL
    
    RET
  MAIN ENDP ; End of procedure (PROC)

  DRAW_BALL PROC NEAR

    MOV CX, BALL_X ; Set the initial column (x) (CX contains 2 8 bit registers CH and CL)
    MOV DX, BALL_Y ; Set the initial row (y)

    DRAW_BALL_HORIZONTAL: 
      MOV AH, 0Ch ; Set the config to writing a pixel
      MOV AL, 0Fh ; Choose White colour
      MOV BH, 00h ; Set the page number to 0
      INT 10h ; executes above
      INC CX ; CX += 1

      ; CX - BALL_X > BALL_SIZE (true -> next row, false -> next column)
      MOV AX, CX ; CX (prev + i) into AX
      SUB AX, BALL_X ; AX (prev + i) - BALL_X (prev)
      CMP AX, BALL_SIZE ; AX (i) <=> BALL_SIZE (4)
      JNG DRAW_BALL_HORIZONTAL ; Jump Not Greater than so false - next col (So recall func)

      ; only get here if TRUE -> next row
      MOV CX, BALL_X ; the CX goes back to initial column value (reset iteration)
      INC DX ; Increment the row number
      
      MOV AX, DX ; DX - BALL_Y > BALL_SIZE (true -> Done, false -> draw row in incremented row number)
      SUB AX, BALL_Y ; AX (prev + i) - BALL_Y (prev)
      CMP AX, BALL_SIZE ; AX (i) <=> BALL_SIZE (4)
      JNG DRAW_BALL_HORIZONTAL ; Call func with new incremented row num if not greater than

    RET
  DRAW_BALL ENDP

CODE ENDS ; End of CODE SEGMENT
END MAIN ; END - End of source file, MAIN - labels MAIN as entry point