//------------------------------------------------------------------------------------------------
//---- VIA_6522_TB.v - 2026 Dave Gaunt	                                                  	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - Test Bench For MOS 6522 Versatile Interface Adapter                             ----
//------------------------------------------------------------------------------------------------

`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 100ns / 10ns

`define TEST_TIMER_1

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

reg [7:0] nWriteData = 0;
wire [7:0] nData;
wire bIRQ_n;

assign nData = bRead ? 8'bz : nWriteData;

VIA_6522 UUT (
	.clk(clk),
	.bReset_n(bReset_n),
	.bCS(bCS),
	.bCS_n(bCS_n),
	.bRead(bRead),
	.nRS(nRS[3:0]),
	.nData(nData[7:0]),
	.bIRQ_n(bIRQ_n)
);

initial begin
	$dumpvars(0, VIA_6522_TB);

	#16 bReset_n = 1;				// Release VIA From Reset
	#9 bCS = 1;
	#2

	#2 bCS_n = 0;					// Enable Interrupts VIA_IER_CA2, VIA_IER_SR and VIA_IER_T1 0x45
	nRS = VIA_REG_IER;
	nWriteData = 8'hC5;
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Disable Interrupts VIA_IER_CA2, VIA_IER_SR 0x40
	nRS = VIA_REG_IER;
	nWriteData = 8'h05;
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

`ifdef TEST_TIMER_1
	#2 bCS_n = 0;					// Write 0x40 To ACR Putting Timer 1 Into Free Running Mode
	nRS = VIA_REG_ACR;
	nWriteData = 8'h40;
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Write 0x26 To Timer 1 Low Order Latch Through Count Register
	nRS = VIA_REG_T1CL;
	nWriteData = 8'h06;		// 26
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#2 bCS_n = 0;					// Write 0x48 To Timer 1 High Order Latch And Start The Timer
	nRS = VIA_REG_T1CH;
	nWriteData = 8'h00;		// 48
	#1 bRead = 0;
	#6 bRead = 1;
	bCS_n = 1;

	#65								// Read Interrupt Flags Register
	nRS = VIA_REG_IFR;
	#1 bCS_n = 0;
	#7 bCS_n = 1;

	if (nData != 8'hC0)
		$error("Interrupt Flag Error!");

	if (bIRQ_n != 0)
		$error("IRQ Set Flag Error!");
/*
	nWriteData = 8'h40;				// Reset IRQ By Clearing The Timer 1 IFR Bit
	#2 bRead = 0;
	bCS_n = 0;
	#7 bCS_n = 1;

	nWriteData = 8'h00;				// Reset IRQ By ReWriting Timer 1 High Order Latch
	nRS = VIA_REG_T1LH;
	#2 bRead = 0;
	bCS_n = 0;
	#7 bCS_n = 1;
*/
	nRS = VIA_REG_T1CL;				// Reset IRQ By Reading Timer 1 Low Order Counter
	#2 bCS_n = 0;
	#7 bCS_n = 1;

	if (bIRQ_n != 1)
		$error("IRQ Reset Flag Error!");

	#20 nRS = VIA_REG_ACR;
	nWriteData = 8'h00;				// Switch Timer 1 Into Single Shot Mode
	bRead = 0;
	#1 bCS_n = 0;
	#6 bRead = 1;
	bCS_n = 1;

`endif // TEST_TIMER_1


	#(DURATION) $display("End of simulation");
	$finish;
end

endmodule
