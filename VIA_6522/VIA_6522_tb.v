//------------------------------------------------------------------------------------------------
//---- VIA_6522_TB.v					                                                  	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - Test Bench For MOS 6522 Versatile Interface Adapter                             ----
//------------------------------------------------------------------------------------------------

`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100ns / 10ns

module VIA_6522_TB();

parameter DURATION = 100;

reg clk = 0;
always #4.5 clk = ~clk;				// 902.1966ns

reg bReset_n = 0;
reg bCS = 0;
reg bCS_n = 1;
reg bRead = 1;
reg [3:0] nRS = 0;
wire [7:0] nData;

assign nData = bRead ? 8'bz : 8'h55;

VIA_6522 UUT (
	.clk(clk),
	.bReset_n(bReset_n),
	.bCS(bCS),
	.bCS_n(bCS_n),
	.bRead(bRead),
	.nRS(nRS[3:0]),
	.nData(nData)
);

initial begin
	$dumpvars(0, VIA_6522_TB);

	bRead = 0;
	#16 bReset_n = 1;				// Release VIA From Reset
	bRead = 1;

	#9 bCS = 1;
	#1 bCS_n = 0;

	#1 nRS = 6;
//	nData = 8'hAA;
	bRead = 0;

	#(DURATION) $display("End of simulation");
	$finish;
end

endmodule
