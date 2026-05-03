//------------------------------------------------------------------------------------------------
//---- VIA_6522_TB.v - 2026 Dave Gaunt	                                                  	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - Test Bench For MOS 6522 Versatile Interface Adapter                             ----
//------------------------------------------------------------------------------------------------

`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100ns / 10ns

`include "VIARegisters.vh"

module VIA_6522_TB();

parameter DURATION = 100;

reg clk = 0;
always #4.5 clk = ~clk;				// 902.1966ns

reg bReset_n = 0;
reg bCS = 0;
reg bCS_n = 1;
reg bRead = 1;
reg [3:0] nRS = 0;

reg [7:0] mWriteData = 0;
wire [7:0] nData;

assign nData = bRead ? 8'bz : mWriteData;

VIA_6522 UUT (
	.clk(clk),
	.bReset_n(bReset_n),
	.bCS(bCS),
	.bCS_n(bCS_n),
	.bRead(bRead),
	.nRS(nRS[3:0]),
	.nData(nData[7:0])
);

initial begin
	$dumpvars(0, VIA_6522_TB);

	#16 bReset_n = 1;				// Release VIA From Reset
	#9 bCS = 1;
	#2

	#2 bCS_n = 0;					// Enable Interrupts VIA_IER_CA2, VIA_IER_SR and VIA_IER_T1 0x45
	nRS = VIA_REG_IER;
	mWriteData = 8'hC5;
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Disable Interrupts VIA_IER_CA2, VIA_IER_SR 0x40
	nRS = VIA_REG_IER;
	mWriteData = 8'h05;
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Write 0x40 To ACR Putting Timer 1 Into Free Running Mode
	nRS = VIA_REG_ACR;
	mWriteData = 8'h40;
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Write 0x26 To Timer 1 Low Order Latch Through Count Register
	nRS = VIA_REG_T1CL;
	mWriteData = 8'h06;		// 26
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Write 0x48 To Timer 1 High Order Latch And Start The Timer
	nRS = VIA_REG_T1CH;
	mWriteData = 8'h00;		// 48
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;
	nRS = VIA_REG_T1CH;


	#(DURATION) $display("End of simulation");
	$finish;
end

endmodule
