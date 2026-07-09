//------------------------------------------------------------------------------------------------
//---- VIA_6522_TB.v - 2026 Dave Gaunt	                                                  	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - Test Bench For MOS 6522 Versatile Interface Adapter                             ----
//------------------------------------------------------------------------------------------------

`default_nettype none
`define DUMPSTR(x) `"x.vcd`"
`timescale 10ns / 1ns

`define TEST_TIMER_1
`define TEST_PORTS
`define TEST_CAB

`include "VIARegisters.vh"

module VIA_6522_TB();

parameter DURATION = 3000;

reg bFPGACoreClock = 0;					// 25 Mhz FPGA Core Clock
always #2 bFPGACoreClock = ~bFPGACoreClock;

reg bPhase2Clock = 0;					// Vic20 1,108,404 Hz Clock
always #50 bPhase2Clock = ~bPhase2Clock;

reg bReset_n = 0;
reg bCS = 0;
reg bCS_n = 1;
reg bRead = 1;
reg [3:0] nRS = 0;
reg bCA1 = 1;
reg bCB1 = 1;

wire bCA2;
wire bCB2;
wire [7:0] nData;
wire [7:0] nPortA;
wire [7:0] nPortB;
wire bIRQ_n;

reg [7:0] nWriteData = 0;

genvar i;
generate
    for (i = 0; i < 8; i = i + 1)
	begin // : pullup_bus
        pullup (nPortA[i]);
        pullup (nPortB[i]);
    end
endgenerate

assign nData = bRead ? 8'bz : nWriteData;

VIA_6522 UUT (
	.bFPGACoreClock(bFPGACoreClock),
	.bPhase2Clock(bPhase2Clock),
	.bReset_n(bReset_n),
	.bCS(bCS),
	.bCS_n(bCS_n),
	.bRead(bRead),
	.nRS(nRS[3:0]),
	.bCA1(bCA1),
	.bCB1(bCB1),

	.bCA2(bCA2),
	.bCB2(bCB2),
	.nData(nData[7:0]),
	.nPortA(nPortA[7:0]),
	.nPortB(nPortB[7:0]),

	.bIRQ_n(bIRQ_n)
);

initial begin
	$dumpvars(0, VIA_6522_TB);

	#50 bReset_n = 1;					// Release VIA From Reset
	#51

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_IER;
	nWriteData = 8'hC5;
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;						// Disable Interrupts VIA_IER_CA2, VIA_IER_SR 0x40
	bCS_n = 0;
	nRS = VIA_REG_IER;
	nWriteData = 8'h05;
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;						// Read Interrupt Enable Register
	bCS_n = 0;
	nRS = VIA_REG_IER;
	#55 bCS = 0;
	bCS_n = 1;

//------------------------------------------------------------------------------------------------
//---- 																                          ----
//------------------------------------------------------------------------------------------------
`ifdef TEST_CAB
	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_PCR;
	nWriteData = 8'hC0;					// Pull CB2 Low
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_PCR;
	nWriteData = 8'hEC;					// Float CB2 High / Pull CA2 Low
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_PCR;
	nWriteData = 8'hEC;					// Float CB2 High / Pull CA2 Low
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_IER;
	nWriteData = 8'h82;					// Enable IRQ On CA1 Transition
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	bCA1 = 0;							// Trigger CA1 IRQ
	#100

	#45 bCS = 1;						// Read ORA To Clear IRQ
	bCS_n = 0;
	nRS = VIA_REG_ORA;
	#55 bCS = 0;
	bCS_n = 1;

	#100
	bCB1 = 0;
	bCA1 = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_IER;
	nWriteData = 8'h02;					// Disable IRQ On CA1 Transition
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_IER;
	nWriteData = 8'h90;					// Enable IRQ On CB1 Transition
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_PCR;
	nWriteData = 8'hFC;					// Set CB1 Transition From Low To High
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	bCB1 = 1;							// Trigger CA2 IRQ
	#100

	#45 bCS = 1;						// Read ORB To Clear IRQ
	bCS_n = 0;
	nRS = VIA_REG_ORB;
	#55 bCS = 0;
	bCS_n = 1;

`endif // TEST_CAB

//------------------------------------------------------------------------------------------------
//---- 																                          ----
//------------------------------------------------------------------------------------------------
`ifdef TEST_PORTS
	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_DDRB;
	nWriteData = 8'hFF;					// Direction B All Output
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_DDRA;
	nWriteData = 8'h01;					// Direction A All Input
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_ORB;
	nWriteData = 8'hF7;					// Output Port B 0xf7
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;
	bCS_n = 0;
	nRS = VIA_REG_ORB;
	nWriteData = 8'hF6;					// Output Port B 0xf6
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

`endif // TEST_PORTS

//------------------------------------------------------------------------------------------------
//---- 																                          ----
//------------------------------------------------------------------------------------------------
`ifdef TEST_TIMER_1
	#45 bCS = 1;						// Write 0x40 To ACR Putting Timer 1 Into Free Running Mode
	bCS_n = 0;
	nRS = VIA_REG_ACR;
	nWriteData = 8'h40;
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;						// Write 0x26 To Timer 1 Low Order Latch Through Count Register
	bCS_n = 0;
	nRS = VIA_REG_T1CL;
	nWriteData = 8'h06;		// 26
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#45 bCS = 1;						// Write 0x48 To Timer 1 High Order Latch And Start The Timer
	bCS_n = 0;
	nRS = VIA_REG_T1CH;
	nWriteData = 8'h00;		// 48
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	#700								// Count Down 7

	#45 bCS = 1;						// Read Interrupt Flags Register
	bCS_n = 0;
	nRS = VIA_REG_IFR;
	#55 bCS = 0;
	bCS_n = 1;

	if (nData != 8'hC0)
		$error("Interrupt Flag Error!");

	if (bIRQ_n != 0)
		$error("IRQ Set Flag Error!");

	#45 bCS = 1;						// Reset IRQ By Clearing The Timer 1 IFR Bit
	bCS_n = 0;
	nRS = VIA_REG_IFR;
	nWriteData = 8'h40;
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;

	// #45 bCS = 1;						// Reset IRQ By ReWriting Timer 1 High Order Latch
	// bCS_n = 0;
	// nRS = VIA_REG_T1LH;
	// nWriteData = 8'h00;		// 48
	// bRead = 0;
	// #55 bCS = 0;
	// bCS_n = 1;
	// bRead = 1;
/*
	#45 bCS = 1;						// Reset IRQ By Reading Timer 1 Low Order Counter
	bCS_n = 0;
	nRS = VIA_REG_T1CL;
	#55 bCS = 0;
	bCS_n = 1;

	if (bIRQ_n != 1)
		$error("IRQ Reset Flag Error!");

	#45 bCS = 1;						// Switch Timer 1 Into Single Shot Mode
	bCS_n = 0;
	nRS = VIA_REG_ACR;
	nWriteData = 8'h00;
	bRead = 0;
	#55 bCS = 0;
	bCS_n = 1;
	bRead = 1;
*/
`endif // TEST_TIMER_1

	#(DURATION) $display("End of simulation");
	$finish;
end

endmodule
