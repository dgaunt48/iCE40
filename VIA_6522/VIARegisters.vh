//------------------------------------------------------------------------------------------------
//---- VIARegisters.vh - 2023 Dave Gaunt                                                 	  ----
//------------------------------------------------------------------------------------------------
//---- v1.0 - 									                                              ----
//------------------------------------------------------------------------------------------------

parameter VIA_REG_ORB			= 0;			// Output Register A
parameter VIA_OUTPUT_REG_B_MSB			= 7;
parameter VIA_OUTPUT_REG_B_LSB			= 0;
parameter VIA_REG_ORA			= 1;
parameter VIA_OUTPUT_REG_A_MSB			= 7;
parameter VIA_OUTPUT_REG_A_LSB			= 0;
parameter VIA_REG_DDRB			= 2;
parameter VIA_DATA_DIRECTION_B_MSB		= 7;
parameter VIA_DATA_DIRECTION_B_LSB		= 0;
parameter VIA_REG_DDRA			= 3;
parameter VIA_DATA_DIRECTION_A_MSB		= 7;
parameter VIA_DATA_DIRECTION_A_LSB		= 0;
parameter VIA_REG_T1CL			= 4;
parameter VIA_TIMER1_COUNT_L_MSB		= 7;
parameter VIA_TIMER1_COUNT_L_LSB		= 0;
parameter VIA_REG_T1CH			= 5;
parameter VIA_TIMER1_COUNT_H_MSB		= 7;
parameter VIA_TIMER1_COUNT_H_LSB		= 0;
parameter VIA_REG_T1LL			= 6;
parameter VIA_TIMER1_LATCH_L_MSB		= 7;
parameter VIA_TIMER1_LATCH_L_LSB		= 0;
parameter VIA_REG_T1LH			= 7;
parameter VIA_TIMER1_LATCH_H_MSB		= 7;
parameter VIA_TIMER1_LATCH_H_LSB		= 0;
parameter VIA_REG_T2CL			= 8;
parameter VIA_TIMER2_COUNT_L_MSB		= 7;
parameter VIA_TIMER2_COUNT_L_LSB		= 0;
parameter VIA_REG_T2CH			= 9;
parameter VIA_TIMER2_COUNT_H_MSB		= 7;
parameter VIA_TIMER2_COUNT_H_LSB		= 0;
parameter VIA_REG_SR			= 10;
parameter VIA_SHIFT_REGISTER_MSB		= 7;
parameter VIA_SHIFT_REGISTER_LSB		= 0;
parameter VIA_REG_ACR			= 11;				// Auxillary Control Register
parameter VIA_ACR_PA_LATCH_BIT			= 0;		// Port A Latch Enable
parameter VIA_ACR_PB_LATCH_BIT			= 1;		// Port B Latch Enable
parameter VIA_ACR_SRC_MSB				= 4;		// Shift Register Control
parameter VIA_ACR_SRC_LSB				= 2;
parameter VIA_ACR_TIMER2_CTRL_BIT		= 5;		// Timer 2 Control
parameter VIA_ACR_TIMER1_CTRL_MSB		= 7;		// Timer 1 Control
parameter VIA_ACR_TIMER1_CTRL_LSB		= 6;
parameter VIA_REG_PCR			= 12;				// Peripheral Control Register
parameter VIA_PCR_CA1_CONTROL_BIT		= 0;		// CA1 Interrupt Control Pin
parameter VIA_PCR_CA2_CONTROL_MSB		= 3;		// CA2 
parameter VIA_PCR_CA2_CONTROL_LSB		= 1;
parameter VIA_PCR_CB1_CONTROL_BIT		= 4;		// CB1 Interrupt Control Pin
parameter VIA_PCR_CB2_CONTROL_MSB		= 7;		// CB2 
parameter VIA_PCR_CB2_CONTROL_LSB		= 5;
parameter VIA_REG_IFR			= 13;				// Interrupt Flag Register
parameter VIA_IFR_CA2_BIT				= 0;
parameter VIA_IFR_CA1_BIT				= 1;
parameter VIA_IFR_SR_BIT    			= 2;
parameter VIA_IFR_CB2_BIT				= 3;
parameter VIA_IFR_CB1_BIT				= 4;
parameter VIA_IFR_T2_BIT				= 5;
parameter VIA_IFR_T1_BIT				= 6;
parameter VIA_IFR_IRQ_BIT				= 7;
parameter VIA_REG_IER			= 14;				// Interrupt Enable Register
parameter VIA_IER_CA2_BIT				= 0;
parameter VIA_IER_CA1_BIT				= 1;
parameter VIA_IER_SR_BIT				= 2;
parameter VIA_IER_CB2_BIT				= 3;
parameter VIA_IER_CB1_BIT				= 4;
parameter VIA_IER_T2_BIT				= 5;
parameter VIA_IER_T1_BIT				= 6;
parameter VIA_IER_SET_CLR_BIT			= 7;
parameter VIA_REG_ORA_NOHS		= 15;				// Output Register A No Handshake
parameter VIA_OUTPUT_REG_A_NOHS_MSB		= 7;
parameter VIA_OUTPUT_REG_A_NOHA_LSB		= 0;

reg		[7:0]		aVIA		[0:15];		// 8 Bit VIA Control Registers * 16
