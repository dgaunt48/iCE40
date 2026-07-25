//------------------------------------------------------------------------------------------------
//---- DaveFPGA ... 2024 Dave Gaunt                                                           ----
//------------------------------------------------------------------------------------------------
//---- Version 0.1                                                                            ----
//------------------------------------------------------------------------------------------------
#include <stdio.h>
#include "types.h"
#include "pico/stdlib.h"
#include "hardware/clocks.h"

#include "vga111.h"

enum device_pins {
	PIN_RED = 0,
	PIN_GREEN,
	PIN_BLUE,
	PIN_HSYNC = 8,
	PIN_VSYNC,
	PIN_25MHZ_CLOCK = 13
};

static_assert(13 == PIN_25MHZ_CLOCK, "Clock must be on PIN 13!");

#define FPGA_CLOCK			(25000000)

//------------------------------------------------------------------------------------------------
//----                                                                                        ----
//------------------------------------------------------------------------------------------------
int main()
{
	stdio_init_all();

	clock_gpio_init(PIN_25MHZ_CLOCK, CLOCKS_CLK_GPOUT0_CTRL_AUXSRC_VALUE_CLK_SYS, ((float)SYS_CLK_HZ / (float)FPGA_CLOCK));

	vga_Init(PIN_RED, PIN_HSYNC, PIN_VSYNC);
	vga_FilledRect(0, 0, VGA_RESOLUTION_X, VGA_RESOLUTION_Y, RGB111_GREEN);

	u32 uYPos = 5;

	while(true)
	{
		vga_FilledRect(1, 1, VGA_RESOLUTION_X-2, VGA_RESOLUTION_Y-2, RGB111_BLACK);
		vga_DrawString(30, uYPos, "DaveFPGA Version 0.1", RGB111_CYAN);

		if (++uYPos == 55)
			uYPos = 5;

		sleep_ms(200);
	}
}
