apio lint
apio build
..\bin2c.exe -n iCE40_BitStream -o _build\iCE40_BitStream.h _build\default\Hardware.bin
copy _build\iCE40_BitStream.h ..\DaveFPGA\Source\iCE40_BitStream.h
pause
