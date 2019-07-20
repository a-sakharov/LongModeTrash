FORMAT binary
use32
org 0x0A00
;;;
; so, we are in 32-bit protected mode
    JMP $
    

times 0x100-($-$$) DB 0
