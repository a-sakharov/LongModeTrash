# Sample x86-64 boot code

## File info

 - README.MD - this file
 - bootFullDisk.asm - bootloader to load from disk (MBR)
 - Stage1_RealMode.asm - first stage, real mode. Entering to protected mode
 - Stage2_ProtectedMode.asm - second stage, protected mode. Entering to long mode.
 - Stage3_LongMode.asm - finally, long mode. Idn what to do here
 - Stage3_data.asm - simple banner used in stage 3

## Boot sequence

 - MBR search VBR and load VBR (zero-stage bootloader)
 - VBR checks and loads first-stage bootloader (FSB) code to <first stage bootloader address>
 - First-stage bootloader initialize hardware, find and load kernel to <kernel address> and 
 fill hardware description tables at <hardware description tables address>
 - Kernel using hardware description tables keep working
 
```

                                                  +-----------------------------+
                                         +------->| Hardware description tables |
                                         |        +-----------------------------+    
                                         |                   
+-----+   +-----+   +--------------------+---+    +--------+ 
| MBR |-->| VBR |-->| First-stage bootloader |--->| Kernel | 
+-----+   +-----+   +------------------------+    +--------+ 
  \          \                         \                      
   ---.       ----------------.         --------------.
       \                       \                       \
+~~~~~~~~~~~~~~~~~~~~~~+  +~~~~~~~~~~~~~~~~~~~~~~~+  +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+
| Start from   0:7c00h |  | Start from   0:7c00h  |  | System initialiaztion                                 |
| Copy self to 0:0500h |  | Find FSB and FSB size |  | Hardware deskriprion tables initialization to 0:0000h |
| Copy VBR to  0:7c00h |  | Copy FSB to 0:0500h   |  | Loading kernel to 0:1000h                             |
| Jump to VBR          |  | Jump to FSB           |  | Jump to kernel                                        |
+~~~~~~~~~~~~~~~~~~~~~~+  +~~~~~~~~~~~~~~~~~~~~~~~+  +~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+

```
