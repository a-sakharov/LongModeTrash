FORMAT binary
use16
org 0x0900
;;;
start:
    MOV SI, hello_str
    CALL printString

    MOV SI, enter_pm_str
    CALL printString
    
    LGDT [gdt_load]
    
    ;save cursor position
    MOV AH, 0x03
    XOR BH, BH
    INT 0x10
    
    PUSH DX
    
    ; inform bios that we are entering protected mode
    MOV AX, 0xEC00
    MOV BL, 1
    INT 0x15
    
    CLI ;who knows...
    SMSW AX 
    OR AX, 1 ; PE=1
    LMSW AX
    
    ; now we in protected mode. cool.
    ; next stage at 0x0A00. jump to it with CS initialization to 32-bit segment 1
    
    JMP FAR 0x08:0x0A00
    
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
enter_pm_str: DB "Entering protected mode...", 10, 13, 0

align 4
gdt:
gdt_e0: ;zero
    DD 0
    DD 0
gdt_e1: ;code
    DW 0xFFFF ;limit
    DW 0x0000 ;base
    DB 0x00 ;also base
    DB 10011010b ;Type+S+DPL+P
    DB 11001111b ;limit+AVL+L+D/B+G
    DB 0x00 ;base
gdt_e2: ;data
    DW 0xFFFF ;limit
    DW 0x0000 ;base
    DB 0x00 ;also base
    DB 10010010b ;Type+S+DPL+P
    DB 11001111b ;limit+AVL+L+D/B+G
    DB 0x00 ;base

gdt_load:
gdt_size: DW $-gdt
gdt_pntr: DD gdt
; Two segments in same address space.
; First for code, second for data.
;   Base = 0 (start at memory linear 0)
;   Limit = 0xFFFFF   \
;                      \   Seg. end = (limit+1)*(G ? 0x1000 : 1)
;                       >  Seg. end = (0xFFFFF + 1) * 0x1000 = 
;                      /   = 0x100000000 bytes (0xFFFFFFFF + 1)
;   G(ranularity) = 1 /
;   D/B = 1 (32-bit)
;   L = 0 (no 64-bit code)
;   AVL = 0 (who cares?)
;   P = 1 (segment present in memory)
;   DPL = 0 (ring 0, ho-ho)
;   S = 1 (data/code segment, not a system segment)
;   Type = 0010 for data (R+W) and 1010 for code (R+E)

times 0x100-($-$$) DB 0
