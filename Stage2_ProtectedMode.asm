FORMAT binary
use32
org 0x0A00
;;;
; so, we are in 32-bit protected mode
    ;init all segment regs except CS. CS should setup alredy.
    MOV AX, 0x10
    MOV DS, AX
    MOV ES, AX
    MOV FS, AX
    MOV GS, AX
    MOV SS, AX
    
    MOV EAX, [0x800000];about 8mb. just to check that everything ok
    JMP $
    

times 0x100-($-$$) DB 0
