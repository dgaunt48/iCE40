//------------------------------------------------------------------------------------------------
//---- VIA_6522.v - 2026 Dave Gaunt	                                                     	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - MOS 6522 Versatile Interface Adapter                                            ----
//------------------------------------------------------------------------------------------------

// FPGA Usage 315 LC 4% @ 139 Mhz

module VIA_6522(
	input wire bFPGACoreClock,
	input wire bPhase2Clock,
	input wire bReset_n,
	input wire bCS,
	input wire bCS_n,
	input wire bRead,
	input wire [3:0] nRS,

	inout wire [7:0] nData,
	inout wire [7:0] nPortA,
	inout wire [7:0] nPortB,

	output reg bIRQ_n
);

`include "VIARegisters.vh"

wire [7:0] nPortIRA;
wire [7:0] nPortIRB;

SB_IO #(
	.PIN_TYPE(6'b1010_01), 
	.PULLUP(1'b1)           
) io_port_a [7:0] (
	.PACKAGE_PIN(nPortA),
	.OUTPUT_ENABLE(aVIA[VIA_REG_DDRA] & ~aVIA[VIA_REG_ORA]),
	.D_OUT_0(aVIA[VIA_REG_ORA]),
	.D_IN_0(nPortIRA),
	.LATCH_INPUT_VALUE(8'h00),		// Silence the linter
	.CLOCK_ENABLE(8'h00),
	.INPUT_CLK(8'h00),
	.OUTPUT_CLK(8'h00),
	.D_OUT_1(8'h00),
	.D_IN_1()
);

SB_IO #(
	.PIN_TYPE(6'b1010_01), 
	.PULLUP(1'b1)           
) io_port_b [7:0] (
	.PACKAGE_PIN(nPortB),
	.OUTPUT_ENABLE(aVIA[VIA_REG_DDRB] & ~aVIA[VIA_REG_ORB]),
	.D_OUT_0(8'h00), 
	.D_IN_0(nPortIRB),
	.LATCH_INPUT_VALUE(8'h00),		// Silence the linter
	.CLOCK_ENABLE(8'h00),
	.INPUT_CLK(8'h00),
	.OUTPUT_CLK(8'h00),
	.D_OUT_1(8'h00),
	.D_IN_1()
);

`ifndef SYNTHESIS
	wire [7:0] sim_ORB;		// 0	Output Register B
	wire [7:0] sim_ORA;		// 1	Output Register B
	wire [7:0] sim_DDRB;	// 2	Data Direction Register B
	wire [7:0] sim_DDRA;	// 3	Data Direction Register A
	wire [7:0] sim_T1CL;	// 4	Timer 1 Count Low
	wire [7:0] sim_T1CH;	// 5	Timer 1 Count High
	wire [7:0] sim_T1LL;	// 6	Timer 1 Latch Low
	wire [7:0] sim_T1LH;	// 7	Timer 1 Latch High
	wire [7:0] sim_ACR;		// 11	Auxillary Control Register
	wire [7:0] sim_IFR;		// 13	Interrupt Flag Register
	wire [7:0] sim_IER;		// 14	Interrupt Enable Register

	assign sim_ORB = aVIA[VIA_REG_ORB];
	assign sim_ORA = aVIA[VIA_REG_ORA];
	assign sim_DDRB = aVIA[VIA_REG_DDRB];
	assign sim_DDRA = aVIA[VIA_REG_DDRA];
	assign sim_T1CL = aVIA[VIA_REG_T1CL];
	assign sim_T1CH = aVIA[VIA_REG_T1CH];
	assign sim_T1LL = aVIA[VIA_REG_T1LL];
	assign sim_T1LH = aVIA[VIA_REG_T1LH];
	assign sim_ACR = aVIA[VIA_REG_ACR];
	assign sim_IER = aVIA[VIA_REG_IER];
	assign sim_IFR = aVIA[VIA_REG_IFR];
`endif

reg bCopyNextClock;
reg [3:0] nReadDelay;
//reg bDriveBus = 1'b0;
reg [7:0] nBusOutput;
reg [2:0] nPhase2Sync;
//reg [7:0] nWriteBufferData;
//reg [3:0] nWriteBufferAddress;

assign nData = (bPhase2Clock & bRead & bCS & ~bCS_n) ? nBusOutput : 8'bz;

wire bAnyEdge;
assign bAnyEdge = (nPhase2Sync[1] ^ nPhase2Sync[0]);

//reg bWriteEdge;

always @ (posedge bFPGACoreClock)
begin
	if (0 == bReset_n)				// Reset all VIA Registers to 0 except T1, T2 and SR
	begin
		nPhase2Sync <= 3'b0;
		nBusOutput <= 8'h00;
		bCopyNextClock <= 1'b0;
//		bDriveBus <= 1'b0;
		nReadDelay <= 4'b0;
//		nWriteBufferData <= 0;
//		nWriteBufferAddress <= 0;
//		bWriteEdge <= 0;

`ifndef SYNTHESIS
		// aVIA[VIA_REG_T1CL] <= 8'h00;
		// aVIA[VIA_REG_T1CH] <= 8'h00;
		// aVIA[VIA_REG_T1LL] <= 8'h00;
		// aVIA[VIA_REG_T1LH] <= 8'h00;
		// aVIA[VIA_REG_ACR] <= 8'h00;
		// aVIA[VIA_REG_IER] <= 8'h00;
		// aVIA[VIA_REG_IFR] <= 8'h00;
`endif
		aVIA[VIA_REG_ORB] <= 8'h00;
		aVIA[VIA_REG_ORA] <= 8'h00;
		aVIA[VIA_REG_DDRB] <= 8'h00;
		aVIA[VIA_REG_DDRA] <= 8'h00;
		aVIA[VIA_REG_ACR] <= 8'h00;
		aVIA[VIA_REG_PCR] <= 8'h00;
		aVIA[VIA_REG_IFR] <= 8'h00;
		aVIA[VIA_REG_IER] <= 8'h00;
	end
	else
	begin
		nPhase2Sync <= { nPhase2Sync[1:0], bPhase2Clock };

		if (bAnyEdge)
		begin
			if (bPhase2Clock)	// Rising Edge Of Phase 2 Clock
			begin
				//------------------------------------------------------------------------------------
				//---- 6522 Do Timing & Interrupts Reguardless Of Chip Select State               ----
				//------------------------------------------------------------------------------------

				// Decrement Timer 1 Counter
				aVIA[VIA_REG_T1CL] <= aVIA[VIA_REG_T1CL] - 1;

				if (0 == aVIA[VIA_REG_T1CL])
					aVIA[VIA_REG_T1CH] <= aVIA[VIA_REG_T1CH] - 1;

				if (0 == aVIA[VIA_REG_ACR][VIA_ACR_TIMER1_CTRL_LSB])
				begin
					// Timer 1 - One Shot Mode
					if ((0 == aVIA[VIA_REG_T1CH]) && (0 == aVIA[VIA_REG_T1CL]))
					begin
						// If The Timer 1 Interrupt Enable Bit Is Set - Set The Timer 1 Interrupt Flag Bit and IRQ bit.
						aVIA[VIA_REG_IFR][VIA_IFR_T1_BIT] <= aVIA[VIA_REG_IER][VIA_IER_T1_BIT];
						aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT] <= aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT] | aVIA[VIA_REG_IER][VIA_IER_T1_BIT];
					end
				end
				else
				begin
					// Timer 1 - Free Running Mode
					if ((0 == aVIA[VIA_REG_T1CH]) && (0 == aVIA[VIA_REG_T1CL]))
					begin
						bCopyNextClock <= 1;

						// If The Timer 1 Interrupt Enable Bit Is Set - Set The Timer 1 Interrupt Flag Bit and IRQ bit.
						aVIA[VIA_REG_IFR][VIA_IFR_T1_BIT] <= aVIA[VIA_REG_IER][VIA_IER_T1_BIT];
						aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT] <= aVIA[VIA_REG_IER][VIA_IER_T1_BIT];

						bIRQ_n <= ~aVIA[VIA_REG_IER][VIA_IER_T1_BIT];
					end
				end

				if (bCopyNextClock)
				begin
					bCopyNextClock <= 0;

					// Transfer Timer 1 High Order Latch Into High Order Counter
					aVIA[VIA_REG_T1CH] <= aVIA[VIA_REG_T1LH];

					// Transfer Timer 1 Low Order Latch Into Low Order Counter
					aVIA[VIA_REG_T1CL] <= aVIA[VIA_REG_T1LL];

					bIRQ_n <= ~aVIA[VIA_REG_IER][VIA_IER_T1_BIT];
				end

				if (!aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT])
					bIRQ_n <= 1;

				nReadDelay <= 9;
			end
			else
			begin
			// 	bDriveBus <= 1'b0;
			end
		end

		if (nReadDelay > 0)
			nReadDelay <= nReadDelay - 1;

		if (bCS && !bCS_n)
		begin
			if ((nReadDelay == 8) && bRead)
			begin
			//------------------------------------------------------------------------------------
			//---- 6522 Selected And At The Rising Clock Edge So Put Data On The Bus		  ----
			//------------------------------------------------------------------------------------
//			bDriveBus <= 1'b1;

			case (nRS)
				VIA_REG_ORB:		// RS 0
				begin
					nBusOutput <= ((nPortIRB & ~aVIA[VIA_REG_DDRB]) | (aVIA[VIA_REG_ORB] & aVIA[VIA_REG_DDRB]));
				end

				VIA_REG_ORA:		// RS 1
				begin
					nBusOutput <= ((nPortIRA & ~aVIA[VIA_REG_DDRA]) | (aVIA[VIA_REG_ORA] & aVIA[VIA_REG_DDRA]));
				end

				VIA_REG_DDRB:		// RS 2
				begin
					nBusOutput <= aVIA[VIA_REG_DDRB];
				end

				VIA_REG_DDRA:		// RS 3
				begin
					nBusOutput <= aVIA[VIA_REG_DDRA];
				end

				VIA_REG_T1CL:		// RS 4
				begin
					nBusOutput <= aVIA[VIA_REG_T1CL];

					// Reset Timer 1 Interrupt Flag
					aVIA[VIA_REG_IFR][VIA_IFR_T1_BIT] <= 1'b0;

					// Update The IRQ Bit Skipping The T1 Bit (6) Which Is Now Clear.
					aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT] <= |aVIA[VIA_REG_IFR][5:0];
				end

				VIA_REG_T1CH:		// RS 5
				begin
					nBusOutput <= aVIA[VIA_REG_T1CH];
				end

				VIA_REG_T1LL:		// RS 6
				begin
					nBusOutput <= aVIA[VIA_REG_T1LL];
				end

				VIA_REG_T1LH:		// RS 7
				begin
					nBusOutput <= aVIA[VIA_REG_T1LH];
				end

				VIA_REG_ACR:		// RS 11
				begin
					nBusOutput <= aVIA[VIA_REG_ACR];
				end

				VIA_REG_PCR:		// RS 12
				begin
					nBusOutput <= aVIA[VIA_REG_PCR];
				end

				VIA_REG_IFR:		// RS 13
				begin
					nBusOutput <= aVIA[VIA_REG_IFR];
				end

				VIA_REG_IER:		// RS 14
				begin
					nBusOutput <= aVIA[VIA_REG_IER];
				end

				VIA_REG_ORA_NOHS:	// RS 15
				begin
//					nBusOutput <= nPortIRA;
					nBusOutput <= ((nPortIRA & ~aVIA[VIA_REG_DDRA]) | (aVIA[VIA_REG_ORA] & aVIA[VIA_REG_DDRA]));
				end
			endcase
			end
			else if ((nReadDelay == 1) && !bRead)
			begin
//				nWriteBufferData <= nData;
//				nWriteBufferAddress <= nRS[3:0];
//				bWriteEdge <= 1;

		//----------------------------------------------------------------------------------------
		//---- 6522 Selected And At The Falling Clock Edge So Do Buffered Data Writes     	  ----
		//----------------------------------------------------------------------------------------
		// if (bWriteEdge)
		// begin
		// 	bWriteEdge <= 0;
			case (nRS[3:0])
				VIA_REG_ORB:		// RS 0
				begin
					aVIA[VIA_REG_ORB] <= nData;
				end

				VIA_REG_ORA:		// RS 1
				begin
					aVIA[VIA_REG_ORA] <= nData;
				end

				VIA_REG_DDRB:		// RS 2
				begin
					aVIA[VIA_REG_DDRB] <= nData;
				end

				VIA_REG_DDRA:		// RS 3
				begin
					aVIA[VIA_REG_DDRA] <= nData;
				end

				VIA_REG_T1CL:		// RS 4
				begin
					// Any Writes To Timer 1 Counter Low Are Stored In Timer 1 Latch Low
					aVIA[VIA_REG_T1LL] <= nData;
				end

				VIA_REG_T1CH:		// RS 5
				begin
					// Write To Timer 1 High Order Counter
					aVIA[VIA_REG_T1CH] <= nData;

					// Transfer Timer 1 Low Order Latch Into Low Order Counter
					aVIA[VIA_REG_T1CL] <= aVIA[VIA_REG_T1LL];

					// Write To Timer 1 High Order Latch
					aVIA[VIA_REG_T1LH] <= nData;

					// Reset Timer 1 Interrupt Flag
					aVIA[VIA_REG_IFR][VIA_IFR_T1_BIT] <= 1'b0;

					// Update The IRQ Bit Skipping The T1 Bit (6) Which Is Now Clear.
					aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT] <= |aVIA[VIA_REG_IFR][5:0];
				end

				VIA_REG_T1LL:		// RS 6
				begin
					// Write To Timer 1 Low Order Latch
					aVIA[VIA_REG_T1LL] <= nData;
				end

				VIA_REG_T1LH:		// RS 7
				begin
					// Write To Timer 1 High Order Latch
					aVIA[VIA_REG_T1LH] <= nData;

					// Reset Timer 1 Interrupt Flag
					aVIA[VIA_REG_IFR][VIA_IFR_T1_BIT] <= 1'b0;

					// Update The IRQ Bit Skipping The T1 Bit (6) Which Is Now Clear.
					aVIA[VIA_REG_IFR][VIA_IFR_IRQ_BIT] <= |aVIA[VIA_REG_IFR][5:0];
				end

				VIA_REG_ACR:		// RS 11
				begin
					// Write Value To Auxillary Control Register
					aVIA[VIA_REG_ACR] <= nData;
				end

				VIA_REG_PCR:		// RS 12
				begin
					// Write Value To Auxillary Control Register
					aVIA[VIA_REG_PCR] <= nData;
				end

				VIA_REG_IFR:		// RS 13
				begin
					// Writing A 1 In The Low 7 Bits Of the Interrupt Flags Register Will Clear That Flag.
					// Bit 7 Is The IRQ Flag, It Can Only Be Cleared By Clearing All Other Flags.
					aVIA[VIA_REG_IFR][6:0] <= aVIA[VIA_REG_IFR][6:0] & ~nData[6:0];
					aVIA[VIA_REG_IFR][7] <= |(aVIA[VIA_REG_IFR][6:0] & ~nData[6:0]);
				end

				VIA_REG_IER:		// RS 14
				begin
					// Set / Clear Flags In Interrupt Enable Register
					if (nData[7])
						aVIA[VIA_REG_IER][6:0] <= aVIA[VIA_REG_IER][6:0] | nData[6:0];
					else
						aVIA[VIA_REG_IER][6:0] <= aVIA[VIA_REG_IER][6:0] & ~nData[6:0];
				end

				VIA_REG_ORA_NOHS:	// RS 15
				begin
					aVIA[VIA_REG_ORA] <= nData;
				end
			endcase
		end


//			end
		end
	end
end

endmodule
