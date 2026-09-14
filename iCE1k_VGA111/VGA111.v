//------------------------------------------------------------------------------------------------
//---- VGA111.v - 2023 Dave Gaunt     	                	                               	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - 									                                              ----
//------------------------------------------------------------------------------------------------

`default_nettype none		// Disable Implicit Definitions By Verilog

//----------------------------------------------------------------------------------------------------
// Top Module And Signals Wired To FPGA Pins
//----------------------------------------------------------------------------------------------------
module VGA111(
	input wire 			vga_clk,			// Oscillator input 25Mhz

	output reg			vga_hsync,
	output reg			vga_vsync,
	output reg	 		vga_r,
	output reg	 		vga_g,
	output reg	 		vga_b
);

reg [7:0] timer_t = 0;						// 8 bit timer with 0 initialisation

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
			nRasterHorizontal <= nRasterHorizontal + 1;
		end
		else
		begin
			nRasterHorizontal <= 0;

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
		end

		if ((nRasterHorizontal >= h_pixels) || (nRasterVertical >= v_pixels))
		begin	// VGA Colour Signals Are Low During The Blanking Periods
			vga_r <= 0;
			vga_g <= 0;
			vga_b <= 0;
		end
		else
		begin	// In Screen Region
			if (nRasterHorizontal<214)
			begin
				vga_r <= 0;
				vga_g <= 0;
				vga_b <= 1;
			end
			else if (nRasterHorizontal<428)
			begin
				vga_r <= 0;
				vga_g <= 1;
				vga_b <= 0;
			end
			else
			begin
				vga_r <= 1;
				vga_g <= 0;
				vga_b <= 0;
			end
		end
	end
end
endmodule
