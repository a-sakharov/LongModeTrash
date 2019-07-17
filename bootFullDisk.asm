FORMAT binary
use16
org 0x7C00
;;;
start:
    MOV SI, hello_str
    CALL printString
    
    MOV SI, diskr_str
    CALL printString

    ; Disk sector read
    ; AH = 02h
    ; AL = number of sectors to read (must be nonzero)
    ; CH = low eight bits of cylinder number
    ; CL = sector number 1-63 (bits 0-5) high two bits of cylinder (bits 6-7, hard disk only)
    ; DH = head number
    ; DL = drive number (bit 7 set for hard disk)
    ; ES:BX -> data buffer
    ; 
    ; Return:
    ; CF set on error
    ; if AH = 11h (corrected ECC error), AL = burst length
    ; CF clear if successful
    ; AH = status
    ; AL = number of sectors transferred (only valid if CF set for some BIOSes)
    
    MOV AX, 0x0214 ; just read 20 sectors (10kb) for now, later maybe fix this
    MOV CX, 2
    MOV DH, 0
    PUSH WORD 0
    POP ES
    MOV BX, 0x0900 ; 1kb from 0x00000500 for stack
    INT 13h
    
    MOV SI, progj_str
    CALL printString
    
    ;setup stack
    PUSH WORD 0
    POP SS
    MOV SP, 0x0900
    
    ;and run into
    PUSH WORD 0
    PUSH WORD 0x0900
    RETF
    
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
hello_str: DB "Bootloader started.", 10, 13, 0
diskr_str: DB "Reading disk to mem...", 10, 13, 0
progj_str: DB "Jumping to loaded data...", 10, 13, 0
;;;
;;; Shuld be used as VBR instead of MBR, so no need to define partitions
;;;
times 510-($-$$) DB 0
DB 0x55,0xAA


; start       end         size           type                           description
;
; 0x00000000  0x000003FF  1 KiB          RAM - partially unusable       Real Mode IVT (Interrupt Vector Table)
; 0x00000400  0x000004FF  256 bytes      RAM - partially unusable       BDA (BIOS data area)
; 0x00000500  0x00007BFF  almost 30 KiB  RAM (guaranteed free for use)  Conventional memory
; 0x00007C00  0x00007DFF  512 bytes      RAM - partially unusable       Your OS BootSector
; 0x00007E00  0x0007FFFF  480.5 KiB      RAM (guaranteed free for use)  Conventional memory
; 0x00080000  0x0009FFFF  128 KiB        RAM - partially unusable       EBDA (Extended BIOS Data Area)
; 0x000A0000  0x000FFFFF  384 KiB        various (unusable)             Video memory, ROM Area 