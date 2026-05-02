//------------------------------------------------------------------------------------------------
//---- VIA_6522.v					                                                     	  ----
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

reg bCSTest = 0;

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
		if ((!bCS_n) && (bCS))
		begin
			if (bRead)
			begin
			end
			else
			begin
			end

			bCSTest <= 1;
		end
	end
end

endmodule
