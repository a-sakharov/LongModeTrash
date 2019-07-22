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
    JNZ .long_mode_ok
    MOV ESI, no_long_mode_msg 
    CALL printLine
    JMP $
    
.long_mode_ok:
    MOV ESI, long_mode_ok_msg
    CALL printLine
    
    MOVZX DX, byte [cur_row]
    PUSH DX
    ;here init long mode...
    
    ;paging disable, to be sure
    MOV EAX, CR0
    AND EAX, 0x7FFFFFFF
    MOV CR0, EAX
    
    ;enabling PAE
    MOV EAX, CR4
    OR EAX, 0x20
    MOV CR4, EAX
    
    ;set LME bit (enablind IA-32e aka Long Mode)
    MOV ECX, 0xC0000080
    RDMSR
    OR EAX, 0x100
    WRMSR
    
    ;--setup PML4E------------------------------------------------------------------------------\
    ;clear memory for all of these tables                                                      ;|
    CLD                                                                                        ;|
    XOR EAX, EAX                                                                               ;|
    MOV EDI, 0x2000     ;start address                                                         ;|
    MOV ECX, 0x4000/4   ;size divided by size of dword                                         ;|
    REP STOSD                                                                                  ;|
                                                                                               ;|
    MOV EDI, 0x2000                                                                            ;|
                                                                                               ;|
    ;setup PML4E first entry                                                                   ;|
    MOV [EDI+0x0000], DWORD 0x00003003 ; flags: write+present, address of PDPTE                ;|
    ;setup PDPTE first entry                                                                   ;|
    MOV [EDI+0x1000], DWORD 0x00004003 ; flags: write+present, address of PDE                  ;|
    ;setup PDE first entry                                                                     ;|
    MOV [EDI+0x2000], DWORD 0x00005003 ; flags: write+present, address of PTE                  ;|
                                                                                               ;|
    MOV EDI, 0x5000                                                                            ;|
    MOV EAX, 0x0003                                                                            ;|
    MOV ECX, 512                                                                               ;|
.next_4kb_frame:                                                                               ;|
    MOV [EDI], EAX                                                                             ;|
    ADD EAX, 0x1000                                                                            ;|
    ADD EDI, 8                                                                                 ;|
    LOOP .next_4kb_frame                                                                       ;|
                                                                                               ;|
    ;set address of PML4E                                                                      ;|
    MOV EAX, 0x2000                                                                            ;|
    MOV CR3, EAX                                                                               ;|
    ;-------------------------------------------------------------------------------------------/    
    
    ;enable paging
    MOV EAX, CR0
    OR EAX, 0x80000000
    MOV CR0, EAX
    
    ;load gdt with 64-bit flag set
    LGDT [gdt_load]
    
    ;jump into the long mode
    JMP FAR 0x08:0x0C00
    
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
    DB 10101111b ;limit+AVL+L+D/B+G
    DB 0x00 ;base
gdt_e2: ;data
    DW 0xFFFF ;limit
    DW 0x0000 ;base
    DB 0x00 ;also base
    DB 10010010b ;Type+S+DPL+P
    DB 10101111b ;limit+AVL+L+D/B+G
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
;   D/B = 0 (caused by L-bit)
;   L = 1 (64-bit code)
;   AVL = 0 (who cares?)
;   P = 1 (segment present in memory)
;   DPL = 0 (ring 0, ho-ho)
;   S = 1 (data/code segment, not a system segment)
;   Type = 0010 for data (R+W) and 1010 for code (R+E)

times 0x200-($-$$) DB 0
