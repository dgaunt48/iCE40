//------------------------------------------------------------------------------------------------
//---- LEDS_TB.v					                                                       	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - TestBench For FPGA Version Of Hello World!		                              ----
//------------------------------------------------------------------------------------------------

`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100 ns / 10 ns

module LEDS_TB();

parameter DURATION = 10;

reg b25MHzClock = 0;
always #0.5 b25MHzClock = ~b25MHzClock;

//-- Leds port
wire [1:0] aLEDs;
reg  [1:0] aButtons;
reg bDividedClock;

LEDS UUT (
	.b25MHzClock(b25MHzClock),
	.aButtons(aButtons),

	.bDividedClock(bDividedClock),
	.aLEDs(aLEDs)
);

initial begin

	$dumpvars(0, LEDS_TB);
	#5 aButtons[1:0] = 0;
	#5 aButtons[1:0] = 1;
	#5 aButtons[1:0] = 2;
	#5 aButtons[1:0] = 3;

	#(DURATION) $display("End of simulation");
	$finish;
end

endmodule
