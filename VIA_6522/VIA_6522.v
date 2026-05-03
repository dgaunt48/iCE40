//------------------------------------------------------------------------------------------------
//---- VIA_6522.v - 2026 Dave Gaunt	                                                     	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - MOS 6522 Versatile Interface Adapter                                            ----
//------------------------------------------------------------------------------------------------

module VIA_6522(
	input wire clk,
	input wire bReset_n,
	input wire bCS,
	input wire bCS_n,
	input wire bRead,
	input wire [3:0] nRS,
	inout wire [7:0] nData
);

`include "VIARegisters.vh"

`ifndef SYNTHESIS
	wire [7:0] sim_T1CL;	// 4	Timer 1 Count Low
	wire [7:0] sim_T1CH;	// 5	Timer 1 Count High
	wire [7:0] sim_T1LL;	// 6	Timer 1 Latch Low
	wire [7:0] sim_T1LH;	// 7	Timer 1 Latch High
	wire [7:0] sim_ACR;		// 11	Auxillary Control Register
	wire [7:0] sim_IFR;		// 13	Interrupt Flag Register
	wire [7:0] sim_IER;		// 14	Interrupt Enable Register

	assign sim_T1CL = aVIA[VIA_REG_T1CL];
	assign sim_T1CH = aVIA[VIA_REG_T1CH];
	assign sim_T1LL = aVIA[VIA_REG_T1LL];
	assign sim_T1LH = aVIA[VIA_REG_T1LH];
	assign sim_ACR = aVIA[VIA_REG_ACR];
	assign sim_IER = aVIA[VIA_REG_IER];
	assign sim_IFR = aVIA[VIA_REG_IFR];

	reg [7:0] nTestData = 0;
`endif

assign nData = bRead ? 8'hAA : 8'bz;

always @ (posedge clk)		// Vic20 1,108,404 Hz clock
begin
	if (0 == bReset_n)		// Reset all VIA Registers to 0 except T1, T2 and SR
	begin
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
		// Decrement Timer 1 Counter
		aVIA[VIA_REG_T1CL] <= aVIA[VIA_REG_T1CL] - 1;

		if (0 == aVIA[VIA_REG_T1CL])
			aVIA[VIA_REG_T1CH] <= aVIA[VIA_REG_T1CH] - 1;

		if ((!bCS_n) && (bCS))
		begin
			if (bRead)
			begin
			end
			else
			begin
				case (nRS)
					VIA_REG_T1CL:		// RS 4
					begin
						// Any Writes To Timer 1 Counter Low Are Stored In Timer 1 Latch Low
						aVIA[VIA_REG_T1LL] <= nData;
					end

					VIA_REG_T1CH:		// RS 5
					begin
						// Write To Timer 1 High Order Latch
						aVIA[VIA_REG_T1LH] <= nData;

						// Write To Timer 1 High Order Counter
						aVIA[VIA_REG_T1CH] <= nData;

						// Transfer Timer 1 Low Order Latch Into Low Order Counter
						aVIA[VIA_REG_T1CL] <= aVIA[VIA_REG_T1LL];

						// Reset Timer 1 Interrupt Flag
						aVIA[VIA_REG_IFR][VIA_IFR_T1_LSB] <= 1'b0;
					end

					VIA_REG_ACR:		// RS 11
					begin
						// Write Value To Auxillary Control Register
						aVIA[VIA_REG_ACR] <= nData;
					end

					VIA_REG_IER:		// RS 14
					begin
						// Set / Clear Flags In Interrupt Enable Register
						if (nData[VIA_IER_SET_CLR_LSB])
							aVIA[VIA_REG_IER][VIA_IER_T1_LSB:VIA_IER_CA2_LSB] <= aVIA[VIA_REG_IER][VIA_IER_T1_LSB:VIA_IER_CA2_LSB] | nData[VIA_IER_T1_LSB:VIA_IER_CA2_LSB];
						else
							aVIA[VIA_REG_IER][VIA_IER_T1_LSB:VIA_IER_CA2_LSB] <= aVIA[VIA_REG_IER][VIA_IER_T1_LSB:VIA_IER_CA2_LSB] & ~nData[VIA_IER_T1_LSB:VIA_IER_CA2_LSB];
					end
				endcase
			end
		end

		if (0 == aVIA[VIA_REG_ACR][VIA_ACR_TIMER1_CTRL_LSB])
		begin
			// Timer 1 - One Shot Mode
		end
		else
		begin
			// Timer 1 - Free Running Mode
			if ((0 == aVIA[VIA_REG_T1CH]) && (0 == aVIA[VIA_REG_T1CL]))
			begin
				// Transfer Timer 1 High Order Latch Into High Order Counter
				aVIA[VIA_REG_T1CH] <= aVIA[VIA_REG_T1LH];

				// Transfer Timer 1 Low Order Latch Into Low Order Counter
				aVIA[VIA_REG_T1CL] <= aVIA[VIA_REG_T1LL];

				// If The Timer 1 Interrupt Enable Bit Is Set - Set The Timer 1 Interrupt Flag Bit.
				aVIA[VIA_REG_IFR][VIA_IFR_T1_LSB] <= aVIA[VIA_REG_IER][VIA_IER_T1_LSB];
			end
		end
	end
end

endmodule
