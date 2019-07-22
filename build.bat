@rem
@rem Building bat. Fix path to fasm if something.
@rem

@SET FASM="C:\Program Files (x86)\FASM\FASM.exe"

@del *.bin

%FASM% bootFullDisk.asm
@if not %ERRORLEVEL% == 0 (
    @pause
    @exit
)

%FASM% Stage1_RealMode.asm
@if not %ERRORLEVEL% == 0 (
    @pause
    @exit
)

%FASM% Stage2_ProtectedMode.asm
@if not %ERRORLEVEL% == 0 (
    @pause
    @exit
)

%FASM% Stage3_LongMode.asm
@if not %ERRORLEVEL% == 0 (
    @pause
    @exit
)

%FASM% Stage3_data.asm
@if not %ERRORLEVEL% == 0 (
    @pause
    @exit
)

copy /B /Y bootFullDisk.bin+Stage1_RealMode.bin+Stage2_ProtectedMode.bin+Stage3_LongMode.bin+Stage3_data.bin disk.bin
@if not %ERRORLEVEL% == 0 (
    @pause
    @exit
)
