FORMAT binary
use16
org 0x0900
;;;
start:
    MOV SI, hello_str
    CALL printString

    JMP $
    
printString:
    ; Teletype output
    ; AH = 0Eh
    ; AL = character to write
    ; BH = page number
    ; BL = foreground color (graphics modes only)

    PUSH AX
    PUSH BX
    PUSH SI
    
    XOR BX, BX
    MOV AH, 0x0E
    
.next_char:
    LODSB
    TEST AL, AL
    JZ .end_of_output
    INT 10h
    JMP .next_char
    
.end_of_output:

    POP SI
    POP BX
    POP AX

    ret

;;;
hello_str: DB "Stage 1 started.", 10, 13, 0