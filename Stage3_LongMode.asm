FORMAT BINARY
use64
org 0x0C00
;;
start:
    POP DX
    MOV byte [cur_row], DL
    
    MOV RSI, hello_msg
    CALL printLine
    
    ;i dont care at all
    CLD
    MOV RCX, 0xC00 / 8
    MOV RSI, 0xD00
    MOV RDI, 0xB8000 + (80 * 2 * 8)
.next_screen_item:
    LODSQ
    STOSQ
    LOOP .next_screen_item
    JMP $

printLine:
    PUSH RDI
    PUSH RAX
    PUSH RDX
    PUSH RSI
    
    MOVZX EAX, byte [cur_row]
    INC EAX
    MOV byte [cur_row], AL
    DEC EAX
    MOV EDX, 80*2
    MUL EDX
    MOV EDI, EAX
    ADD EDI, 0xB8000
    
.next_char:
    MOV AL, [ESI]
    TEST AL, AL
    JZ .end_of_output
    MOV [EDI], AL
    ADD EDI, 2
    INC ESI
    JMP .next_char
    
.end_of_output:
    
    POP RSI
    POP RDX
    POP RAX
    POP RDI
    RET
    
;;
hello_msg: db "Stage 3: Long mode enter success.", 0
cur_row: db 0
times 0x100-($-$$) DB 0
