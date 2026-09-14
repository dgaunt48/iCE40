//------------------------------------------------------------------------------------------------
//---- DaveFPGA ... 2024 Dave Gaunt                                                           ----
//------------------------------------------------------------------------------------------------
//---- Version 0.1                                                                            ----
//------------------------------------------------------------------------------------------------

#include <stdio.h>
#include "types.h"
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/clocks.h"

#include "vga111.h"
#include "iCE40_BitStream.h"

#define SPI_BAUD_RATE	(20 * 1000 * 1000)	/* 20Mhz */
#define VGA_PAL_CLOCK	(25000000)

enum board_pins{
	PIN_RED = 0, PIN_GREEN, PIN_BLUE,
	PIN_SPI_MOSI,
	PIN_SPI_MISO,
	PIN_SPI_CS,
	PIN_SPI_CLOCK,
	PIN_FPGA_CDONE,
	PIN_HSYNC,
	PIN_VSYNC,
	PIN_FPGA_RESET,
	PIN_25MHZ_CLOCK = 21
};

static_assert(21 == PIN_25MHZ_CLOCK, "Pico only exposes PIN_21 for external clocks!");

//------------------------------------------------------------------------------------------------
//---- Directly Upload BitStream To iCE40                                                     ----
//------------------------------------------------------------------------------------------------
int main()
{
	stdio_init_all();
    const u32 uSpiSpeed = spi_init(spi0, SPI_BAUD_RATE);

    gpio_init(PIN_FPGA_RESET);
    gpio_set_dir(PIN_FPGA_RESET, GPIO_OUT);
    gpio_put(PIN_FPGA_RESET, false);

    gpio_init(PIN_SPI_CS);
    gpio_init(PIN_FPGA_CDONE);
    gpio_set_dir(PIN_FPGA_CDONE, GPIO_IN);

    gpio_set_function(PIN_SPI_CS, GPIO_FUNC_SIO);
    gpio_set_function(PIN_SPI_CLOCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SPI_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SPI_MISO, GPIO_FUNC_SPI);
    gpio_set_dir(PIN_SPI_CS, GPIO_OUT);
	gpio_put(PIN_SPI_CS, true);

	vga_Init(PIN_RED, PIN_HSYNC, PIN_VSYNC);
	vga_FilledRect(0, 0, VGA_RESOLUTION_X, VGA_RESOLUTION_Y, RGB111_GREEN);
	vga_FilledRect(1, 1, VGA_RESOLUTION_X-2, VGA_RESOLUTION_Y-2, RGB111_BLACK);

	// CS Low While Reset is Low to select Slave Mode.
	sleep_ms(2);
    gpio_put(PIN_SPI_CS, false);
    gpio_put(PIN_FPGA_RESET, true);
    sleep_us(1200);					// iCE40HX requires max 1200us clearing time

    spi_write_blocking(spi0, iCE40_BitStream, iCE40_BitStream_size);
    gpio_put(PIN_SPI_CS, true);

    // iCE40 needs at least 49 cycles with CS high to enter user mode
    uint8_t dummy_padding[8] = {0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF};
    spi_write_blocking(spi0, dummy_padding, sizeof(dummy_padding));

	// Start Clock
	clock_gpio_init(PIN_25MHZ_CLOCK, CLOCKS_CLK_GPOUT0_CTRL_AUXSRC_VALUE_CLK_SYS, ((float)SYS_CLK_HZ / (float)VGA_PAL_CLOCK));

	if( gpio_get(PIN_FPGA_CDONE) )
	{
		vga_DrawString(4, 4, "Bitstream Upload Complete", RGB111_GREEN);
	}
	else
	{
		vga_DrawString(4, 4, "FPGA Init Failed!!!", RGB111_RED);
	}

	// char szTempString[128];
	// sprintf(szTempString, "Spi Speed %d", uSpiSpeed);
	// vga_DrawString(4, 4, szTempString, RGB111_GREEN);

	while(true)
	{
		sleep_ms(16);
	}
}
