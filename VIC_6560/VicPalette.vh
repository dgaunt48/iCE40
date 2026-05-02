//------------------------------------------------------------------------------------------------
//---- VicPalette.vh - 2023 Dave Gaunt                                                   	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - 									                                              ----
//------------------------------------------------------------------------------------------------

parameter COLOUR_BLACK			= 0;
parameter COLOUR_WHITE			= 1;
parameter COLOUR_RED			= 2;
parameter COLOUR_CYAN			= 3;
parameter COLOUR_PURPLE			= 4;
parameter COLOUR_GREEN			= 5;
parameter COLOUR_BLUE			= 6;
parameter COLOUR_YELLOW			= 7;
parameter COLOUR_ORANGE			= 8;
parameter COLOUR_LIGHT_ORANGE	= 9;
parameter COLOUR_PINK			= 10;
parameter COLOUR_LIGHT_CYAN		= 11;
parameter COLOUR_LIGHT_PURPLE	= 12;
parameter COLOUR_LIGHT_GREEN	= 13;
parameter COLOUR_LIGHT_BLUE		= 14;
parameter COLOUR_LIGHT_YELLOW	= 15;

parameter PALETTE_RED_MSB		= 23;
parameter PALETTE_RED_LSB		= 16;
parameter PALETTE_GREEN_MSB		= 15;
parameter PALETTE_GREEN_LSB		= 8;
parameter PALETTE_BLUE_MSB		= 7;
parameter PALETTE_BLUE_LSB		= 0;

reg		[23:0]		aPalette	[0:15];		// 24 Bit Palette With 16 Colours

initial
begin
	aPalette[COLOUR_BLACK][23:0] 			= 24'h000000; // 9'b000000000;
	aPalette[COLOUR_WHITE][23:0] 			= 24'hFFFFFF; // 9'b111111111;
	aPalette[COLOUR_RED][23:0] 				= 24'hC63729; // 9'b110001001;
	aPalette[COLOUR_CYAN][23:0]				= 24'h99FFFF; // 9'b100111111;
	aPalette[COLOUR_PURPLE][23:0] 			= 24'hDB44F9; // 9'b111010111;
	aPalette[COLOUR_GREEN][23:0] 			= 24'h81FF5D; // 9'b100111011;
	aPalette[COLOUR_BLUE][23:0] 			= 24'h4832FF; // 9'b010001111;
	aPalette[COLOUR_YELLOW][23:0] 			= 24'hFFFF22; // 9'b111111001;
	aPalette[COLOUR_ORANGE][23:0] 			= 24'hE98F00; // 9'b111100000;
	aPalette[COLOUR_LIGHT_ORANGE][23:0] 	= 24'hFFDC6F; // 9'b111101010;
	aPalette[COLOUR_PINK][23:0] 			= 24'hFFB6AC; // 9'b111101110;
	aPalette[COLOUR_LIGHT_CYAN][23:0] 		= 24'hBCFFFF; // 9'b101111111;
	aPalette[COLOUR_LIGHT_PURPLE][23:0] 	= 24'hFFAEFF; // 9'b111101111;
	aPalette[COLOUR_LIGHT_GREEN][23:0] 		= 24'hBFFFA0; // 9'b110111101;
	aPalette[COLOUR_LIGHT_BLUE][23:0] 		= 24'hBAAAFF; // 9'b110101111;
	aPalette[COLOUR_LIGHT_YELLOW][23:0] 	= 24'hFFFF51; // 9'b111111011;
end
