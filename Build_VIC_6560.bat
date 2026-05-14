cd VIC_6560
apio lint
apio build
cd ..
bin2c.exe -n iCE40_BitStream -o iCE40_BitStream.h VIC_6560\_build\default\Hardware.bin
copy iCE40_BitStream.h ..\..\CBM_Flash_ROMs\FlashSPI\iCE40_BitStream.h
