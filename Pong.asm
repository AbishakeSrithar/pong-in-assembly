STACK SEGMENT PARA STACK 'STACK'                ; Defines Segment (block of memory) of type Stack (stack data structures live here?) named 'stack' (optional param). para means paragraph-aligned (memory address is at a multiple of 16).
  DB 64 DUP (' ')                               ; Reserves 64 bytes of memory, initialized to 0, for the stack. DB - Defined Byte, 64 DUP(licate) 0 (64 times)
STACK ENDS ; End of Stack         
         
DATA SEGMENT PARA 'DATA'                        ; Data Segments are storage for variables and constants
         
  WINDOW_WIDTH DW 140h                          ; 320 in hexadec
  WINDOW_HEIGHT DW 0C8h                         ; 200 in hexdec
  WINDOW_BOUNDS DW 6                            ; Variable used for earlier collision checks
         
  TIME_AUX DB 0                                 ; variable used for time delta
  GAME_ACTIVE DB 1                              ; Game in progress (1: True, 0: False (Game Over))
  WINNER_INDEX DB 0                             ; The index of the winner (1 -> player one, 2 -> player two)
  CURRENT_SCENE DB 1                            ; The index of the current scene (0 -> main menu, 1 -> the game)
         
  TEXT_PLAYER_ONE_POINTS DB '0', '$'            ; text with player 1 points
  TEXT_PLAYER_TWO_POINTS DB '0', '$'            ; text with player 2 points
  TEXT_GAME_OVER_TITLE DB 'GAME OVER', '$'      ; text with Game Over message
  TEXT_GAME_OVER_WINNER DB 'PLAYER 0 WON!', '$' ; text with Winner message
  TEXT_GAME_OVER_PLAY_AGAIN DB 'Press R to play again', '$'  ; text with Play Again message
  TEXT_GAME_OVER_MAIN_MENU DB 'Press E to exit to main menu', '$'  ; text with game over menu message
  TEXT_MAIN_MENU_TITLE DB 'MAIN MENU', '$'      ; text with game menu title
  TEXT_MAIN_MENU_SINGLEPLAYER DB 'SINGLEPLAYER - S KEY', '$'  ; text with single player option
  TEXT_MAIN_MENU_MULTIPLAYER DB 'MULTIPLAYER - M KEY', '$'  ; text with 2 player option
  TEXT_MAIN_MENU_EXIT DB 'EXIT GAME - E KEY', '$'  ; text with exit game message

  BALL_ORIGINAL_X DW 0A0h                       ; 320/2=160 in hexadec
  BALL_ORIGINAL_Y DW 64h                        ; 200/2=100 in hexadec
         
  BALL_X DW 0Ah                                 ; x position (col) of ball (dw - defined word can hold 16bits instead of db-8)
  BALL_Y DW 0Ah                                 ; y position (row) of ball
  BALL_SIZE DW 04h                              ; size of the ball (no pixels in width/height)
  BALL_VELOCITY_X DW 05h                        ; X velocity of ball
  BALL_VELOCITY_Y DW 02h                        ; Y velocity of ball
         
  PADDLE_LEFT_X DW 0Ah                          ; current x position of left paddle
  PADDLE_LEFT_Y DW 0Ah                          ; current y position of left paddle
  PLAYER_ONE_POINTS DB 0                        ; current points of the left player (player one)
         
  PADDLE_RIGHT_X DW 130h                        ; current x position of right paddle
  PADDLE_RIGHT_Y DW 0Ah                         ; current y position of right paddle
  PLAYER_TWO_POINTS DB 0                        ; current points of the right player (player two)
         
  PADDLE_WIDTH DW 05H                           ; default paddle width
  PADDLE_HEIGHT DW 1Fh                          ; default paddle height
  PADDLE_VELOCITY DW 05h                        ; default paddle velocity

DATA ENDS

CODE SEGMENT PARA 'CODE'                        ; Code Segments contains the actual machine instructions that the CPU executes
         
  MAIN PROC FAR                                 ; name of Procedure and entry point because MAIN name. PROC indicates start. FAR is type of procedure (eg. can be called from any segment in seg mem model? opposite is NEAR)
  ASSUME CS:CODE, DS:DATA, SS:STACK             ; Tell Code Segment about code, data, stack registers
  PUSH DS                                       ; push the DS Segment to the stack
  SUB AX, AX                                    ; Clean the AX register
  PUSH AX                                       ; Push AX to the stack
  MOV AX, DATA                                  ; Put DATA into AX
  MOV DS, AX                                    ; Put AX into DS
  POP AX                                        ; pop top item of stack to the AX register
  POP AX                                        ; release top item (again)
         
    CALL CLEAR_SCREEN                           ; set initial video mode configs
         
    CHECK_TIME:   

      CMP CURRENT_SCENE, 00h
      JE SHOW_MAIN_MENU
          
      CMP GAME_ACTIVE, 00h         
      JE SHOW_GAME_OVER         
         
      MOV AH, 2Ch                               ; get the system time
      INT 21h                                   ; CH = hour, CL = minute, DH = second, DL = 1/100s
         
      CMP DL, TIME_AUX                          ; compare 1/100s to prev time aux var
      JE CHECK_TIME                             ; if equal, check again
         
      MOV TIME_AUX, DL                          ; if not update out TIME_AUX with current time
         
      CALL CLEAR_SCREEN                         ; clear screen by restarting video mode
         
      CALL MOVE_BALL                            ; move ball
      CALL DRAW_BALL                            ; draw ball
         
      CALL MOVE_PADDLES                         ; move the 2 paddles (check for pressed keys)
      CALL DRAW_PADDLES                         ; draw the 2 paddles with updated positions
         
      CALL DRAW_UI                              ; draw all the game user interface
         
      JMP CHECK_TIME                            ; after everything checks time again
         
      SHOW_GAME_OVER:         
        CALL DRAW_GAME_OVER_MENU         
        JMP CHECK_TIME

      SHOW_MAIN_MENU:
        CALL DRAW_MAIN_MENU
        JMP CHECK_TIME

      RET
  MAIN ENDP ; End of procedure (PROC)         
         
  MOVE_BALL PROC NEAR                           ; process movement of ball

;   move the ball horizontally
    MOV AX, BALL_VELOCITY_X
    ADD BALL_X, AX

;   check if ball has passed the left boundary (BALL_X < WINDOW_BOUNDS (true -> collided))
    MOV AX, WINDOW_BOUNDS
    CMP BALL_X, AX 
    JL GIVE_POINT_TO_PLAYER_TWO                ; if less, add point to player two and reset ball position

;   Check if the ball has passed the right boundary (BALL_X > WINDOW_WIDTH - BALL_SIZE - WINDOW_BOUNDS (true -> collided))
    MOV AX, WINDOW_WIDTH
    SUB AX, BALL_SIZE
    SUB AX, WINDOW_BOUNDS
    CMP BALL_X, AX
    JG GIVE_POINT_TO_PLAYER_ONE                ; if greater, add point to player one and reset ball position
    JMP MOVE_BALL_VERTICALLY

;   Give 1 point to Player 2 and reset ball position
    GIVE_POINT_TO_PLAYER_ONE:
      INC PLAYER_ONE_POINTS
      CALL RESET_BALL_POSITION                 ; Resets Ball to centre of screen

      CALL UPDATE_TEXT_PLAYER_ONE_POINTS       ; Update text of Player 1 points

      CMP PLAYER_ONE_POINTS, 05h;              ; Check if player has reached 5 points
      JGE GAME_OVER
      RET
;   Give 1 point to Player 1 and reset ball position
    GIVE_POINT_TO_PLAYER_TWO:
      INC PLAYER_TWO_POINTS
      CALL RESET_BALL_POSITION                 ; Resets Ball to centre of screen
      
      CALL UPDATE_TEXT_PLAYER_TWO_POINTS       ; Update text of Player 2 points

      CMP PLAYER_TWO_POINTS, 05h;              ; Check if player has reached 5 points
      JGE GAME_OVER                            ; Stops the game
      RET

    GAME_OVER:                         ; Reach 5 points for Game Over
      CMP PLAYER_ONE_POINTS, 05h
      JNL WINNER_IS_PLAYER_ONE         ; P1 !< 5 -> p1 wins
      JMP WINNER_IS_PLAYER_TWO         ; else P2 wins

      WINNER_IS_PLAYER_ONE:
        MOV WINNER_INDEX, 01h
        JMP CONTINUE_GAME_OVER
      WINNER_IS_PLAYER_TWO:
        MOV WINNER_INDEX, 02h
        JMP CONTINUE_GAME_OVER

      CONTINUE_GAME_OVER:
        MOV PLAYER_ONE_POINTS, 00h      ; Reset Player One points
        MOV PLAYER_TWO_POINTS, 00h     ; Reset Player Two points
        CALL UPDATE_TEXT_PLAYER_ONE_POINTS
        CALL UPDATE_TEXT_PLAYER_TWO_POINTS
        MOV GAME_ACTIVE, 00h
        RET

;   move the ball vertically
    MOVE_BALL_VERTICALLY:

      MOV AX, BALL_VELOCITY_Y
      ADD BALL_Y, AX

;   Check if the ball has passed the top boundary, it colliding, reverse velocity in Y
;   BALL_Y < WINDOW_BOUNDS (true -> collided)
    MOV AX, WINDOW_BOUNDS
    CMP BALL_Y, AX
    JL NEG_VELOCITY_Y

;   Check if the ball has passed the bottom boundary, it colliding, reverse velocity in Y
;   BALL_Y > WINDOW_HEIGHT  - BALL_SIZE - WINDOW_BOUNDS (true -> collided)
    MOV AX, WINDOW_HEIGHT
    SUB AX, BALL_SIZE
    SUB AX, WINDOW_BOUNDS
    CMP BALL_Y, AX
    JG NEG_VELOCITY_Y

;   Check if the ball is colliding with the right paddle
    ; maxx1 > minx2                        && minx1 < maxx2                           && maxy1 > miny2                        && miny1 < maxy2
    ; BALL_X + BALL_SIZE > PADDLE_RIGHT_X  && BALL_X < PADDLE_RIGHT_X + PADDLE_WIDTH  && BALL_Y + BALL_SIZE > PADDLE_RIGHT_Y  &&  BALL_Y < PADDLE_RIGHT_Y + PADDLE_HEIGHT

    MOV AX, BALL_X
    ADD AX, BALL_SIZE
    CMP AX, PADDLE_RIGHT_X
    JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ; No collision -> check right paddle

    MOV AX, PADDLE_RIGHT_X
    ADD AX, PADDLE_WIDTH
    CMP BALL_X, AX
    JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ; No collision -> check right paddle

    MOV AX, BALL_Y
    ADD AX, BALL_SIZE
    CMP AX, PADDLE_RIGHT_Y
    JNG CHECK_COLLISION_WITH_LEFT_PADDLE  ; No collision -> check right paddle

    MOV AX, PADDLE_RIGHT_Y
    ADD AX, PADDLE_HEIGHT
    CMP BALL_Y, AX
    JNL CHECK_COLLISION_WITH_LEFT_PADDLE  ; No collision -> check right paddle

    JMP NEG_VELOCITY_X                     ; If collision, reverse Ball's horizontal velocity

;   Check if the ball is colliding with the left paddled
    ; maxx1 > minx2                       && minx1 < maxx2                          && maxy1 > miny2                       && miny1 < maxy2
    ; BALL_X + BALL_SIZE > PADDLE_LEFT_X  && BALL_X < PADDLE_LEFT_X + PADDLE_WIDTH  && BALL_Y + BALL_SIZE > PADDLE_LEFT_Y  &&  BALL_Y < PADDLE_LEFT_Y + PADDLE_HEIGHT
    CHECK_COLLISION_WITH_LEFT_PADDLE:
      MOV AX, BALL_X
      ADD AX, BALL_SIZE
      CMP AX, PADDLE_LEFT_X
      JNG EXIT_COLLISION_CHECK            ; If no collision, exit

      MOV AX, PADDLE_LEFT_X
      ADD AX, PADDLE_WIDTH
      CMP BALL_X, AX
      JNL EXIT_COLLISION_CHECK            ; If no collision, exit

      MOV AX, BALL_Y
      ADD AX, BALL_SIZE
      CMP AX, PADDLE_LEFT_Y
      JNG EXIT_COLLISION_CHECK            ; If no collision, exit

      MOV AX, PADDLE_LEFT_Y
      ADD AX, PADDLE_HEIGHT
      CMP BALL_Y, AX
      JNL EXIT_COLLISION_CHECK            ; If no collision, exit

      JMP NEG_VELOCITY_X      

      NEG_VELOCITY_Y:
        NEG BALL_VELOCITY_Y               ; Negates the Ball Velocity Y
        RET

      NEG_VELOCITY_X:
        NEG BALL_VELOCITY_X               ; Negates the Ball Velocity X
        RET
      
      EXIT_COLLISION_CHECK:
        RET


  MOVE_BALL ENDP

  MOVE_PADDLES PROC NEAR

;   LEFT PADDLE MOVEMENT
;   Check if any key is being pressed (if not check other paddle)? if no key press then no paddles will move? ********TODO*********
    MOV AH, 01h
    INT 16h
    JZ CHECK_RIGHT_PADDLE_MOVEMENT     ; ZF = 1, JZ -> Jump if Zero (This is needed, why?) **************TODO***********

;   Check which key is being pressed (AL = ASCII Char)
    MOV AH, 00h
    INT 16h

;   If it is 'w' or 'W' move up
    CMP AL, 77h                        ; 'w'
    JE MOVE_LEFT_PADDLE_UP
    CMP AL, 57h                        ; 'W'
    JE MOVE_LEFT_PADDLE_UP

;   If it is 's' or 'S' move down
    CMP AL, 73h                        ; 's'
    JE MOVE_LEFT_PADDLE_DOWN
    CMP AL, 53h                        ; 'S'
    JE MOVE_LEFT_PADDLE_DOWN
    JMP CHECK_RIGHT_PADDLE_MOVEMENT

    MOVE_LEFT_PADDLE_UP:
      MOV AX, PADDLE_VELOCITY
      SUB PADDLE_LEFT_Y, AX

      MOV AX, WINDOW_BOUNDS
      CMP PADDLE_LEFT_Y, AX
      JL FIX_PADDLE_LEFT_TOP_POSITION
      JMP CHECK_RIGHT_PADDLE_MOVEMENT

      FIX_PADDLE_LEFT_TOP_POSITION:
        MOV PADDLE_LEFT_Y, AX
        JMP CHECK_RIGHT_PADDLE_MOVEMENT

    MOVE_LEFT_PADDLE_DOWN:
      MOV AX, PADDLE_VELOCITY
      ADD PADDLE_LEFT_Y, AX

      MOV AX, WINDOW_HEIGHT
      SUB AX, WINDOW_BOUNDS
      SUB AX, PADDLE_HEIGHT
      CMP PADDLE_LEFT_Y, AX
      JG FIX_PADDLE_LEFT_BOTTOM_POSITION
      JMP CHECK_RIGHT_PADDLE_MOVEMENT

      FIX_PADDLE_LEFT_BOTTOM_POSITION:
        MOV PADDLE_LEFT_Y, AX
        JMP CHECK_RIGHT_PADDLE_MOVEMENT

    ; Right PADDLE MOVEMENT
    CHECK_RIGHT_PADDLE_MOVEMENT:

      ; If it is 'o' or 'O' move up
      CMP AL, 6Fh                      ; 'o'
      JE MOVE_RIGHT_PADDLE_UP
      CMP AL, 4Fh                      ; 'O'
      JE MOVE_RIGHT_PADDLE_UP

      ; If it is 'l' or 'L' move down
      CMP AL, 6Ch                      ; 'l'
      JE MOVE_RIGHT_PADDLE_DOWN
      CMP AL, 4Ch                      ; 'L'
      JE MOVE_RIGHT_PADDLE_DOWN
      JMP EXIT_PADDLE_MOVEMENT

      MOVE_RIGHT_PADDLE_UP:
        MOV AX, PADDLE_VELOCITY
        SUB PADDLE_RIGHT_Y, AX

        MOV AX, WINDOW_BOUNDS
        CMP PADDLE_RIGHT_Y, AX
        JL FIX_PADDLE_RIGHT_TOP_POSITION
        JMP EXIT_PADDLE_MOVEMENT

        FIX_PADDLE_RIGHT_TOP_POSITION:
          MOV PADDLE_RIGHT_Y, AX
          JMP EXIT_PADDLE_MOVEMENT

      MOVE_RIGHT_PADDLE_DOWN:
        MOV AX, PADDLE_VELOCITY
        ADD PADDLE_RIGHT_Y, AX

        MOV AX, WINDOW_HEIGHT
        SUB AX, WINDOW_BOUNDS
        SUB AX, PADDLE_HEIGHT
        CMP PADDLE_RIGHT_Y, AX
        JG FIX_PADDLE_RIGHT_BOTTOM_POSITION
        JMP EXIT_PADDLE_MOVEMENT

        FIX_PADDLE_RIGHT_BOTTOM_POSITION:
          MOV PADDLE_RIGHT_Y, AX
          JMP EXIT_PADDLE_MOVEMENT

      EXIT_PADDLE_MOVEMENT:
        RET
  RET
  MOVE_PADDLES ENDP

  RESET_BALL_POSITION PROC NEAR

    MOV AX, BALL_ORIGINAL_X
    MOV BALL_X, AX

    MOV AX, BALL_ORIGINAL_Y
    MOV BALL_Y, AX

    NEG BALL_VELOCITY_X
    NEG BALL_VELOCITY_Y

    RET
  RESET_BALL_POSITION ENDP

  DRAW_BALL PROC NEAR

    MOV CX, BALL_X                     ; Set the initial column (x) (CX contains 2 8 bit registers CH and CL)
    MOV DX, BALL_Y                     ; Set the initial row (y)

    DRAW_BALL_HORIZONTAL: 
      MOV AH, 0Ch                      ; Set the config to writing a pixel
      MOV AL, 0Fh                      ; Choose White colour
      MOV BH, 00h                      ; Set the page number to 0
      INT 10h                          ; executes above
      
      INC CX                           ; CX += 1

;     CX - BALL_X > BALL_SIZE (true -> next row, false -> next column)
      MOV AX, CX                       ; CX (prev + i) into AX
      SUB AX, BALL_X                   ; AX (prev + i) - BALL_X (prev)
      CMP AX, BALL_SIZE                ; AX (i) <=> BALL_SIZE (4)
      JNG DRAW_BALL_HORIZONTAL         ; Jump Not Greater than so false - next col (So recall func)

;     only get here if TRUE -> next row
      MOV CX, BALL_X                   ; the CX goes back to initial column value (reset iteration)
      INC DX                           ; Increment the row number
          
      MOV AX, DX                       ; DX - BALL_Y > BALL_SIZE (true -> Done, false -> draw row in incremented row number)
      SUB AX, BALL_Y                   ; AX (prev + i) - BALL_Y (prev)
      CMP AX, BALL_SIZE                ; AX (i) <=> BALL_SIZE (4)
      JNG DRAW_BALL_HORIZONTAL         ; Call func with new incremented row num if not greater than

    RET
  DRAW_BALL ENDP

  DRAW_PADDLES PROC NEAR

    MOV CX, PADDLE_LEFT_X              ; Set the initial column (x) (CX contains 2 8 bit registers CH and CL)
    MOV DX, PADDLE_LEFT_Y              ; Set the initial row (y)

    DRAW_PADDLE_LEFT_HORIZONTAL:
      MOV AH, 0Ch                      ; Set the config to writing a pixel
      MOV AL, 0Fh                      ; Choose White colour
      MOV BH, 00h                      ; Set the page number to 0
      INT 10h                          ; executes above

      INC CX                           ; CX += 1

;     CX - PADDLE_LEFT_X > PADDLE_WIDTH (true -> next row, false -> next column)
      MOV AX, CX                       ; CX (prev + i) into AX
      SUB AX, PADDLE_LEFT_X            ; AX (prev + i) - PADDLE_LEFT_X (prev)
      CMP AX, PADDLE_WIDTH             ; AX (i) <=> PADDLE_WIDTH (4)
      JNG DRAW_PADDLE_LEFT_HORIZONTAL  ; Jump Not Greater than so false - next col (So recall func)

;     only get here if TRUE -> next row
      MOV CX, PADDLE_LEFT_X            ; the CX goes back to initial column value (reset iteration)
      INC DX                           ; Increment the row number
      
      MOV AX, DX                       ; DX - PADDLE_LEFT_Y > PADDLE_HEIGHT (true -> Done, false -> draw row in incremented row number)
      SUB AX, PADDLE_LEFT_Y            ; AX (prev + i) - PADDLE_LEFT_Y (prev)
      CMP AX, PADDLE_HEIGHT            ; AX (i) <=> PADDLE_HEIGHT (4)
      JNG DRAW_PADDLE_LEFT_HORIZONTAL  ; Call func with new incremented row num if not greater than

    MOV CX, PADDLE_RIGHT_X             ; Set the initial column (x) (CX contains 2 8 bit registers CH and CL)
    MOV DX, PADDLE_RIGHT_Y             ; Set the initial row (y)

    DRAW_PADDLE_RIGHT_HORIZONTAL:
      MOV AH, 0Ch                      ; Set the config to writing a pixel
      MOV AL, 0Fh                      ; Choose White colour
      MOV BH, 00h                      ; Set the page number to 0
      INT 10h                          ; executes above

      INC CX                           ; CX += 1

;     CX - PADDLE_RIGHT_X > PADDLE_WIDTH (true -> next row, false -> next column)
      MOV AX, CX                       ; CX (prev + i) into AX
      SUB AX, PADDLE_RIGHT_X           ; AX (prev + i) - PADDLE_RIGHT_X (prev)
      CMP AX, PADDLE_WIDTH             ; AX (i) <=> PADDLE_WIDTH (4)
      JNG DRAW_PADDLE_RIGHT_HORIZONTAL ; Jump Not Greater than so false - next col (So recall func)

;    only get here if TRUE -> next row
      MOV CX, PADDLE_RIGHT_X           ; the CX goes back to initial column value (reset iteration)
      INC DX                           ; Increment the row number
      
      MOV AX, DX                       ; DX - PADDLE_RIGHT_Y > PADDLE_HEIGHT (true -> Done, false -> draw row in incremented row number)
      SUB AX, PADDLE_RIGHT_Y           ; AX (prev + i) - PADDLE_RIGHT_Y (prev)
      CMP AX, PADDLE_HEIGHT            ; AX (i) <=> PADDLE_HEIGHT (4)
      JNG DRAW_PADDLE_RIGHT_HORIZONTAL ; Call func with new incremented row num if not greater than

  RET
  DRAW_PADDLES ENDP

  DRAW_UI PROC NEAR

;   Draw the points of the left player (player one)
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 04h                        ; set row number
    MOV DL, 06h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_PLAYER_ONE_POINTS     ; give DX a pointer to the string TEXT_PLAYER_ONE_POINTS
    INT 21h                            ; print the string 

;   Draw the points of the right player (player two)
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 04h                        ; set row number
    MOV DL, 1Fh                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_PLAYER_TWO_POINTS     ; give DX a pointer to the string TEXT_PLAYER_ONE_POINTS
    INT 21h                            ; print the string 
    RET
  
  DRAW_UI ENDP

  UPDATE_TEXT_PLAYER_ONE_POINTS PROC NEAR

    XOR AX, AX
    MOV AL, PLAYER_ONE_POINTS          ; P1: 2pnts => AL = 2

    ; Convert decimal value to ASCII code character (add 30h for num, or subtract for vice versa)
    ADD AL, 30h
    MOV [TEXT_PLAYER_ONE_POINTS], AL

    RET
  UPDATE_TEXT_PLAYER_ONE_POINTS ENDP

  UPDATE_TEXT_PLAYER_TWO_POINTS PROC NEAR

    XOR AX, AX
    MOV AL, PLAYER_TWO_POINTS          ; P2: 2pnts => AL = 2

    ; Convert decimal value to ASCII code character (add 30h for num, or subtract for vice versa)
    ADD AL, 30h
    MOV [TEXT_PLAYER_TWO_POINTS], AL
  
    RET
  UPDATE_TEXT_PLAYER_TWO_POINTS ENDP

  DRAW_GAME_OVER_MENU PROC NEAR        ; Draw the game over menu

    CALL CLEAR_SCREEN                  ; Clear the screen before displaying the menu
;   Shows the menu title
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 04h                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_GAME_OVER_TITLE       ; give DX a pointer to the string TEXT_GAME_OVER_TITLE
    INT 21h                            ; print the string 

;   Shows the winner
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 06h                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    CALL UPDATE_WINNER_TEXT

    MOV AH, 09h
    LEA DX, TEXT_GAME_OVER_WINNER      ; give DX a pointer to the string TEXT_GAME_OVER_WINNER
    INT 21h                            ; print the string

;   Shows the play again message
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 08h                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_GAME_OVER_PLAY_AGAIN  ; give DX a pointer to the string TEXT_GAME_OVER_PLAY_AGAIN
    INT 21h                            ; print the string

;   Shows the main menu message
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 0Ah                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_GAME_OVER_MAIN_MENU   ; give DX a pointer to the string TEXT_GAME_OVER_MAIN_MENU
    INT 21h                            ; print the string

;   Waits for key press
    MOV AH, 00h
    INT 16h

;   If r or R is clicked, we restart game
    CMP AL, 'R'
    JE RESTART_GAME
    CMP AL, 'r'
    JE RESTART_GAME

    ;   If e or E is clicked, we go to main menu
    CMP AL, 'E'
    JE EXIT_TO_MAIN_MENU
    CMP AL, 'e'
    JE EXIT_TO_MAIN_MENU
    RET

    RESTART_GAME:
      MOV GAME_ACTIVE, 01h
      RET

    EXIT_TO_MAIN_MENU:
      MOV GAME_ACTIVE, 00h
      MOV CURRENT_SCENE, 00h
      RET

  DRAW_GAME_OVER_MENU ENDP

  DRAW_MAIN_MENU PROC NEAR
    CALL CLEAR_SCREEN                  ; Clear the screen before displaying the menu
;   Shows the menu title
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 04h                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_MAIN_MENU_TITLE       ; give DX a pointer to the string TEXT_MAIN_MENU_TITLE
    INT 21h

;   Singleplayer message
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 06h                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_MAIN_MENU_SINGLEPLAYER       ; give DX a pointer to the string TEXT_MAIN_MENU_SINGLEPLAYER
    INT 21h

;   Multiplayer message
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 08h                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_MAIN_MENU_MULTIPLAYER   ; give DX a pointer to the string TEXT_MAIN_MENU_MULTIPLAYER
    INT 21h

;   Exit message
    MOV AH, 02h                        ; set cursor position
    MOV BH, 00h                        ; set page number
    MOV DH, 0Ah                        ; set row number
    MOV DL, 04h                        ; set col number
    INT 10h

    MOV AH, 09h
    LEA DX, TEXT_MAIN_MENU_EXIT        ; give DX a pointer to the string TEXT_MAIN_MENU_EXIT
    INT 21h

;   Waits for key press
    MOV AH, 00h
    INT 16h

    RET
  DRAW_MAIN_MENU ENDP

  UPDATE_WINNER_TEXT PROC NEAR

    MOV AL, WINNER_INDEX
    ADD AL, 30h
    MOV [TEXT_GAME_OVER_WINNER+7], AL
  
    RET
  UPDATE_WINNER_TEXT ENDP



  CLEAR_SCREEN PROC NEAR

    MOV AH, 00h                        ; Function to set video mode
    MOV AL, 13h                        ; https://mendelson.org/wpdos/videomodes.txt video mode: 320x200 256 colour
    INT 10h                            ; the 17th (hexadec) interrupt vector (executes the function above)

    MOV AH, 0Bh                        ; Set config type to parent of background (display/cursor pos, other vid adjacent)
    MOV BH, 00h                        ; To the background colour
    MOV BL, 00h                        ; choose black as background colour (default)
    INT 10h                            ; executes above

    RET

  CLEAR_SCREEN ENDP

CODE ENDS                              ; End of CODE SEGMENT
END MAIN                               ; END - End of source file, MAIN - labels MAIN as entry point