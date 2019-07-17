@rem
@rem Building bat. Fix path to fasm if something.
@rem
@SET FASM="C:\Program Files (x86)\FASM\FASM.exe"
%FASM% bootFullDisk.asm
%FASM% Stage1_RealMode.asm
%FASM% Stage2_ProtectedMode.asm
%FASM% Stage3_LongMode.asm

copy /B /Y bootFullDisk.bin+Stage1_RealMode.bin+Stage2_ProtectedMode.bin+Stage3_LongMode.bin disk.bin