# Source
Skeleton rp2354 project to create a 25mhz clock and upload the FPGA bitstream.

# KiCAD\iCE40hx1k
My custom iCE40hx1k FPGA board with rp2354a I use when prototyping.

## Features
- Direct programming via SWD from the pico.
- Auto reset and much faster turn-around time than my other FT232H board.
- Cheaper BOM as both spi flash IC's are no longer needed.
- 3 Bit VGA from the pico for debugging.
- 2 User defined clock frequencies available from the pico.
- Upto 19 3v3 IO pins available to / from the pico.
- 40 5v <-> 3v3 bi-directional level shifters avaliable (some shared to the pico).
- 24 5v <-> 3v3 bi-directional open drain level shifters.
- Second 3 Bit VGA connector is availble from the FPGA.
- [link to ibom](KiCad/ibom_iCE40hx1k_vq100.html)

![iCE40hx1k](Images/iCE40hx1k_vq100.jpg?raw=true "iCE40hx1k")

# KiCAD\iCE40hx4k
FT232H based iCE40hx4k board.  Not using this much anymore as i like
the workflow from the pico SWD.  Will probably make a new version of
this more like the 1k board when I need more IO pins or bitstream space.

## Features
- SPI flash programmed directly via FT232H.
- No direct control via the pico.
- Pico can be left running and reload the FPGA bitstream.
- [link to ibom](KiCad/ibom_iCE40hx4k_tq144.html)

![iCE40hx4k](Images/iCE40hx4k_tq144.jpg?raw=true "iCE40hx4k")
