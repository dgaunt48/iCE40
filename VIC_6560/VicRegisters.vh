//------------------------------------------------------------------------------------------------
//---- VicRegisters.vh - 2023 Dave Gaunt                                                 	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - 									                                              ----
//------------------------------------------------------------------------------------------------

parameter VIC0					= 0;
parameter VIC0_SCREEN_ORIGINX_MSB		= 6;
parameter VIC0_SCREEN_ORIGINX_LSB		= 0;
parameter VIC0_SCREEN_INTERLACE_MSB		= 7;
parameter VIC0_SCREEN_INTERLACE_LSB		= 7;
parameter VIC1					= 1;
parameter VIC1_SCREEN_ORIGINY_MSB		= 7;
parameter VIC1_SCREEN_ORIGINY_LSB		= 0;
parameter VIC2					= 2;
parameter VIC2_SCREEN_COLUMNS_MSB		= 6;
parameter VIC2_SCREEN_COLUMNS_LSB		= 0;
parameter VIC2_SCREEN_RAMSHIFT512_MSB	= 7;
parameter VIC2_SCREEN_RAMSHIFT512_LSB	= 7;
parameter VIC3					= 3;
parameter VIC3_DOUBLE_CHARSIZE_MSB		= 0;
parameter VIC3_DOUBLE_CHARSIZE_LSB		= 0;
parameter VIC3_SCREEN_ROWS_MSB			= 6;
parameter VIC3_SCREEN_ROWS_LSB			= 1;
parameter VIC3_RASTER_LOWBIT_MSB		= 7;
parameter VIC3_RASTER_LOWBIT_LSB		= 7;
parameter VIC4					= 4;
parameter VIC4_RASTER_HIBITS_MSB		= 7;
parameter VIC4_RASTER_HIBITS_LSB		= 0;
parameter VIC5					= 5;
parameter VIC5_CHAR_ROM_1KOFFSET_MSB	= 3;
parameter VIC5_CHAR_ROM_1KOFFSET_LSB	= 0;
parameter VIC5_SCREEN_RAM_1KOFFSET_MSB	= 7;
parameter VIC5_SCREEN_RAM_1KOFFSET_LSB	= 4;
parameter VIC6					= 6;
parameter VIC7					= 7;
parameter VIC8					= 8;
parameter VIC9					= 9;
parameter VICA					= 10;
parameter VICB					= 11;
parameter VICC					= 12;
parameter VICD					= 13;
parameter VICE					= 14;
parameter VICF					= 15;
parameter VICF_BORDERCOL_MSB			= 2;
parameter VICF_BORDERCOL_LSB			= 0;
parameter VICF_REVERSEFIELD_MSB			= 3;
parameter VICF_REVERSEFIELD_LSB			= 3;
parameter VICF_SCREENCOL_MSB			= 7;
parameter VICF_SCREENCOL_LSB			= 4;

reg		[7:0]		aVIC		[0:15];		// 8 Bit VIC Control Registers * 16

initial
begin
	aVIC[VIC0][7:0] = ( 0 << VIC0_SCREEN_INTERLACE_LSB) | (12 << VIC0_SCREEN_ORIGINX_LSB);
	aVIC[VIC1][7:0] = (38 << VIC1_SCREEN_ORIGINY_LSB);
	aVIC[VIC2][7:0] = ( 1 << VIC2_SCREEN_RAMSHIFT512_LSB) | (22 << VIC2_SCREEN_COLUMNS_LSB);
	aVIC[VIC3][7:0] = ( 0 << VIC3_DOUBLE_CHARSIZE_LSB) | (23 << VIC3_SCREEN_ROWS_LSB) | (0 << VIC3_RASTER_LOWBIT_LSB);
	aVIC[VIC4][7:0] = ( 0 << VIC4_RASTER_HIBITS_LSB);
	aVIC[VIC5][7:0] = ( 0 << VIC5_CHAR_ROM_1KOFFSET_LSB) | (15 << VIC5_SCREEN_RAM_1KOFFSET_LSB);
	aVIC[VIC6][7:0] = 87;		// Light Pen Horizontal
	aVIC[VIC7][7:0] = 234;		// Light Pen Vertical
	aVIC[VIC8][7:0] = 0;		// Paddle 1
	aVIC[VIC9][7:0] = 0;		// Paddle 2
	aVIC[VICA][7:0] = 0;		// Alto Channel
	aVIC[VICB][7:0] = 0;		// Tenor Channel
	aVIC[VICC][7:0] = 0;		// Soprano Channel
	aVIC[VICD][7:0] = 0;		// Noise Channel
	aVIC[VICE][7:0] = 0;		// Volume & Aux Colour
	aVIC[VICF][7:0] = (COLOUR_CYAN << VICF_BORDERCOL_LSB) | (1 << VICF_REVERSEFIELD_LSB) | (COLOUR_WHITE << VICF_SCREENCOL_LSB);
end
