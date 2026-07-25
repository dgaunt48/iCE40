//------------------------------------------------------------------------------------------------
//---- LEDS.v					                                                         	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - FPGA Version Of Hello World!		                                              ----
//------------------------------------------------------------------------------------------------

module LEDS(
	input wire b25MHzClock,
	input  wire [1:0] aButtons,

	output reg bDividedClock,
	output wire [1:0] aLEDs
);

assign aLEDs[0] = ~aButtons[0];
assign aLEDs[1] = ~aButtons[1];

reg [2:0] nClockDivider;
reg [2:0] nTimer = 0;

always @ (posedge b25MHzClock)
begin
	if(nTimer < 2)
	begin
		nTimer <= nTimer + 1;
		bDividedClock <= 0;
		nClockDivider <= 0;
	end
	else
	begin
		nClockDivider <= nClockDivider + 1;

		if (0 == nClockDivider)
			bDividedClock <= ~bDividedClock;
	end
end

endmodule
