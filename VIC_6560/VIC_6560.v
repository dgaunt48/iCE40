//------------------------------------------------------------------------------------------------
//---- VIC_6560.v - 2023 Dave Gaunt                                                        	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - Vic Chip FPGA For VIC2020 Project                                               ----
//------------------------------------------------------------------------------------------------

// 499 @ 48.25 MHz

`default_nettype none		// Disable Implicit Definitions By Verilog

// `define TEST_SCROLL_X
`define TEST_SCROLL_Y
// `define TEST_SCREEN_WIDTH
`define FAKE_SCAN_LINES

//----------------------------------------------------------------------------------------------------
// Top Module And Signals Wired To FPGA Pins
//----------------------------------------------------------------------------------------------------
module VIC_6560(
	input wire 			vga_clk,			// Oscillator input 25Mhz

	output reg			vga_hsync,
	output reg			vga_vsync,
	output wire [7:0]	vga_r,
	output wire [7:0]	vga_g,
	output wire [7:0]	vga_b
);

reg [7:0] timer_t = 0;						// 8 bit timer with 0 initialisation

reg [7:0] aVicChars [0:4095];
initial	$readmemh("VicChars.vh", aVicChars);

reg	[7:0] aVicVideoRam [0:511];
initial $readmemh("VicVideoRam.vh", aVicVideoRam);

reg [3:0] aVicColourRam [0:511];
initial $readmemh("VicColourRam.vh", aVicColourRam);

parameter h_pulse   = 96;					// H-SYNC pulse width 96 * 40 ns (25 Mhz) = 3.84 uS
parameter h_bp      = 48;					// H-BP back porch pulse width
parameter h_pixels  = 640;					// H-PIX Number of pixels horizontally
parameter h_fp      = 16;					// H-FP front porch pulse width
parameter h_frame   = 800;					// 800 = 96 (H-SYNC) + 48 (H-BP) + 640 (H-PIX) + 16 (H-FP)
parameter v_pulse   = 2;					// V-SYNC pulse width
parameter v_bp      = 33;					// V-BP back porch pulse width
parameter v_pixels  = 480;					// V-PIX Number of pixels vertically
parameter v_fp      = 10;					// V-FP front porch pulse widthreg
parameter v_frame   = 525;					// 525 = 2 (V-SYNC) + 33 (V-BP) + 480 (V-PIX) + 10 (V-FP)

reg     [9:0]   	nRasterHorizontal;
reg     [9:0]   	nRasterVertical;

reg		[7:0]		nDisplayPixelX;			// Vic X Pixel Index On Entire Screen (0 - 213)
reg		[1:0]		nCRTPixelScaleX;		// 2 Bit Vic Pixel Scaler

`ifdef TEST_SCROLL_X
reg		[1:0]		nScrollDelay;			// Delay to test screen shift registers
`endif

`include "VicPalette.vh"
`include "VicRegisters.vh"

wire [9:0] nX1;
assign nX1 = {aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB], 2'b00} - 30;

wire [7:0] nVicScreenX;			// Vic Visible Display Area X Pixel (0 - Chars Wide * 8)
assign nVicScreenX = nDisplayPixelX - nX1[7 : 0];

wire [8:0] nY1;
assign nY1 = {aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB], 1'b0} - 48;

wire [9:0] nVicScreenY;
assign nVicScreenY = nRasterVertical[9 : 1] - {1'b0, nY1};

wire [8:0] nScreenIndex;
assign nScreenIndex = (nVicScreenY[7 : 3] * aVIC[VIC2][VIC2_SCREEN_COLUMNS_MSB:VIC2_SCREEN_COLUMNS_LSB]) + {4'b0000, nVicScreenX[7 : 3]};

wire [11:0] nCharacterIndex;	// High Bit Selects Between The Two Character Sets.
assign nCharacterIndex = {1'b1, aVicVideoRam[nScreenIndex], nVicScreenY[2 : 0]};

wire [7:0] nCurrentChar;
assign nCurrentChar = aVicChars[nCharacterIndex];

wire [3:0] nCurrentColour;
assign nCurrentColour = aVicColourRam[nScreenIndex];

reg [7:0] nPixelRed;
reg [7:0] nPixelGreen;
reg [7:0] nPixelBlue;

`ifdef FAKE_SCAN_LINES
assign vga_r = (nRasterVertical[0 : 0]) ? nPixelRed : nPixelRed >> 1;
assign vga_g = (nRasterVertical[0 : 0]) ? nPixelGreen : nPixelGreen >> 1;
assign vga_b = (nRasterVertical[0 : 0]) ? nPixelBlue : nPixelBlue >> 1;
`else
assign vga_r = nPixelRed;
assign vga_g = nPixelGreen;
assign vga_b = nPixelBlue;
`endif		

//----------------------------------------------------------------------------------------------------
// 
//----------------------------------------------------------------------------------------------------
always @ (posedge vga_clk)						// 25Mhz clock
begin
	if(timer_t < 250)							// generate 10 uS RESET signal 
	begin
		timer_t <= timer_t + 1;
		nRasterHorizontal <= 0;
		nRasterVertical <= 0;
		nDisplayPixelX <= 0;
		nCRTPixelScaleX <= 0;
	end
	else
	begin

		if (nRasterHorizontal < h_frame - 1)
		begin
			if (nCRTPixelScaleX >= 3)
			begin
				nCRTPixelScaleX <= 1;
				nDisplayPixelX <= nDisplayPixelX + 1;
			end
			else
			begin
				nCRTPixelScaleX <= nCRTPixelScaleX + 1;
			end

			nRasterHorizontal <= nRasterHorizontal + 1;
		end
		else
		begin
			nRasterHorizontal <= 0;
			nDisplayPixelX <= 0;
			nCRTPixelScaleX <= 0;

			if (nRasterVertical < v_frame - 1)		// 525 - 1 = 524
				nRasterVertical <= nRasterVertical + 1;
			else
				nRasterVertical <= 0;					// nRasterVertical = 0 to 524
		end

		if (nRasterHorizontal < h_pixels + h_fp + 1 || nRasterHorizontal > h_pixels + h_fp + h_pulse)	// H-SYNC generator
			vga_hsync <= 1;
		else if (vga_hsync == 1)
			vga_hsync <= 0;


		// if ((vertical < 490) or (vertical > 492)) then not in v-sync		( v-sync = lines 490, 491 & 492 )

		// 			480 + 10 					           480 + 10 + 2								// Should this be v_pulse - 1 ???
		if (nRasterVertical < v_pixels + v_fp || nRasterVertical > v_pixels + v_fp + v_pulse)		// V-SYNC generator
			vga_vsync <= 0;
		else if (vga_vsync == 0)
		begin
			vga_vsync <= 1;
`ifdef TEST_SCROLL_X
			if(nScrollDelay == 0)
			begin
				if(aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB] < 64)
					aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB] <= aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB] + 1;
			else
				aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB] <= 0;
			end

			nScrollDelay <= nScrollDelay + 1;
`endif
`ifdef TEST_SCROLL_Y
			if(aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB] < 128)
				aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB] <= aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB] + 1;
			else
				aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB] <= 0;
`endif
`ifdef TEST_SCREEN_WIDTH
			aVIC[VIC2][VIC2_SCREEN_COLUMNS_MSB:VIC2_SCREEN_COLUMNS_LSB] <= aVIC[VIC2][VIC2_SCREEN_COLUMNS_MSB:VIC2_SCREEN_COLUMNS_LSB] + 1;
`endif
		end

		if ((nRasterHorizontal >= h_pixels) || (nRasterVertical >= v_pixels))
		begin	// VGA Colour Signals Are Low During The Blanking Periods
			nPixelRed <= 0;
			nPixelGreen <= 0;
			nPixelBlue <= 0;
		end
		else if ((((nRasterVertical >> 1) + 48) < {aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB], 1'b0}) ||
				((nDisplayPixelX + 30) < {aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB], 2'b00}) ||
				(((nRasterVertical >> 1) + 48) >= {aVIC[VIC1][VIC1_SCREEN_ORIGINY_MSB:VIC1_SCREEN_ORIGINY_LSB], 1'b0} + {aVIC[VIC3][VIC3_SCREEN_ROWS_MSB:VIC3_SCREEN_ROWS_LSB], 3'b000}) ||
				(({2'b00, nDisplayPixelX} + 30) >= {aVIC[VIC0][VIC0_SCREEN_ORIGINX_MSB:VIC0_SCREEN_ORIGINX_LSB], 2'b00} + {aVIC[VIC2][VIC2_SCREEN_COLUMNS_MSB:VIC2_SCREEN_COLUMNS_LSB], 3'b000}))
		begin	// In Border Region
			nPixelRed <= aPalette[{1'b0, aVIC[VICF][VICF_BORDERCOL_MSB:VICF_BORDERCOL_LSB]}][PALETTE_RED_MSB:PALETTE_RED_LSB];
			nPixelGreen <= aPalette[{1'b0, aVIC[VICF][VICF_BORDERCOL_MSB:VICF_BORDERCOL_LSB]}][PALETTE_GREEN_MSB:PALETTE_GREEN_LSB];
			nPixelBlue <= aPalette[{1'b0, aVIC[VICF][VICF_BORDERCOL_MSB:VICF_BORDERCOL_LSB]}][PALETTE_BLUE_MSB:PALETTE_BLUE_LSB];
		end
		else
		begin	// In Screen Region
			if (nCurrentChar[7 - nVicScreenX[2 : 0]] == 1)
			begin
				nPixelRed <= aPalette[nCurrentColour][PALETTE_RED_MSB:PALETTE_RED_LSB];
				nPixelGreen <= aPalette[nCurrentColour][PALETTE_GREEN_MSB:PALETTE_GREEN_LSB];
				nPixelBlue <= aPalette[nCurrentColour][PALETTE_BLUE_MSB:PALETTE_BLUE_LSB];
			end
			else
			begin
				nPixelRed <= aPalette[aVIC[VICF][VICF_SCREENCOL_MSB:VICF_SCREENCOL_LSB]][PALETTE_RED_MSB:PALETTE_RED_LSB];
				nPixelGreen <= aPalette[aVIC[VICF][VICF_SCREENCOL_MSB:VICF_SCREENCOL_LSB]][PALETTE_GREEN_MSB:PALETTE_GREEN_LSB];
				nPixelBlue <= aPalette[aVIC[VICF][VICF_SCREENCOL_MSB:VICF_SCREENCOL_LSB]][PALETTE_BLUE_MSB:PALETTE_BLUE_LSB];
			end
		end

	end
end
endmodule
