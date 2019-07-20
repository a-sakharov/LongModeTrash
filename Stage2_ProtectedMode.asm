FORMAT binary
use32
org 0x0A00
;;;
start:
; so, we are in 32-bit protected mode
    ;init all segment regs except CS. CS should setup alredy.
    MOV AX, 0x10
    MOV DS, AX
    MOV ES, AX
    MOV FS, AX
    MOV GS, AX
    MOV SS, AX
    
    MOV EAX, [0x800000];about 8mb. just to check that everything ok
    
    POP DX
    MOV [cur_row], dh
    
    MOV ESI, hello_msg
    CALL printLine
    
    MOV EAX, 0x80000001
    CPUID
    
    TEST EDX, 0x20000000
    JZ .no_long_mode
    MOV ESI, long_mode_ok_msg
    JMP .print_long_mode_sp
.no_long_mode:
    MOV ESI, no_long_mode_msg
.print_long_mode_sp:
    CALL printLine
    
    JMP $
    

printLine:
    PUSH EDI
    PUSH EAX
    PUSH EDX
    PUSH ESI
    
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
    
    POP ESI
    POP EDX
    POP EAX
    POP EDI
    RET

;;
hello_msg: DB "Stage 2 started. Protected mode enter success.", 0
no_long_mode_msg: DB "Long mode is not supported!", 0
long_mode_ok_msg: DB "Long mode support found.", 0
cur_row: db 0
times 0x100-($-$$) DB 0
