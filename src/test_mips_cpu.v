/* test_mips_cpu.v
* Author: Pravin P. Prabhu
* Last Revision: 1/5/11
* Abstract:
*	The simulation level module that is intended to be used in modelsim for
* debugging and testing designs. This module simulates a flash memory by
* reading from a file on disk. To change the program to be run in simulation,
* simply change the parameter to readmemh below.
*/
`timescale 1ns/1ps
module test_mips_cpu();

reg clk;
reg Reset_n;

wire [15:0] SDRAM_Dq;
wire [11:0] SDRAM_Addr;
wire [1:0] SDRAM_Ba;
wire SDRAM_Clk;
wire SDRAM_Cke;
wire SDRAM_Cs_n;
wire SDRAM_Ras_n;
wire SDRAM_Cas_n;
wire SDRAM_We_n;
wire [1:0] SDRAM_Dqm;

wire [21:0] FL_ADDR;
reg [7:0] FL_Data;
wire [7:0] FL_DQ_Data;
assign FL_DQ_Data = FL_Data;

reg[3:0] KEYS;


// UUT - Unit Under Test
mips_cpu MIPS_CPU(	// General	 
				.CLOCK_50(clk),
				//.Global_Reset_n(Reset_n),
				.KEY(KEYS),	
				.SW(),	
				.HEX7(), 
				.HEX6(), 
				.HEX5(), 
				.HEX4(), 
				.HEX3(), 
				.HEX2(),
				.HEX1(), 
				.HEX0(),
				.LEDG(),
				.LEDR(),
				
				//SDRAM interface
				.DRAM_ADDR(SDRAM_Addr),   
				.DRAM_BA_0(SDRAM_Ba[0]),
				.DRAM_BA_1(SDRAM_Ba[1]),
				.DRAM_CAS_N(SDRAM_Cas_n),
				.DRAM_CKE(SDRAM_Cke),
				.DRAM_CLK(SDRAM_Clk),
				.DRAM_CS_N(SDRAM_Cs_n),
				.DRAM_DQ(SDRAM_Dq),
				.DRAM_LDQM(SDRAM_Dqm[0]),
				.DRAM_UDQM(SDRAM_Dqm[1]),
				.DRAM_RAS_N(SDRAM_Ras_n),
				.DRAM_WE_N(SDRAM_We_n),
				
				//Flash RAM interface
				.FL_ADDR(FL_ADDR), 	   
				.FL_DQ(FL_DQ_Data),
				.FL_CE_N(),
				.FL_OE_N(),
				.FL_RST_N(),
				.FL_WE_N(),
				
				 //SRAM interface
				.SRAM_ADDR(),  
				.SRAM_DQ(),
				.SRAM_UB_N(),
				.SRAM_LB_N(),
				.SRAM_WE_N(),
				.SRAM_OE_N(),
				.SRAM_CE_N()
			);			
			
mt48lc4m16a2 SDRAM(
					.Dq(SDRAM_Dq),
					.Addr(SDRAM_Addr), 
					.Ba(SDRAM_Ba), 
					.Clk(SDRAM_Clk), 
					.Cke(SDRAM_Cke), 
					.Cs_n(SDRAM_Cs_n), 
					.Ras_n(SDRAM_Ras_n), 
					.Cas_n(SDRAM_Cas_n), 
					.We_n(SDRAM_We_n), 
					.Dqm(SDRAM_Dqm)
				);


//=====================
// Flash mem simulator
reg [31:0] flash_mem_sim [0:32767];
initial 
begin
	$readmemh("C:/Users/Eli/Documents/ucsd/148/src/hexfiles/nqueens.hex",flash_mem_sim);		// Change the path in readmemh to load a different benchmark	
end

always @(*)
begin
	case( FL_ADDR[1:0] )
		0:	FL_Data <= flash_mem_sim[ FL_ADDR[21:2] ][31:24];
		1:	FL_Data <= flash_mem_sim[ FL_ADDR[21:2] ][23:16];
		2:	FL_Data <= flash_mem_sim[ FL_ADDR[21:2] ][15:8];
		3:	FL_Data <= flash_mem_sim[ FL_ADDR[21:2] ][7:0];
		default:
			FL_Data <= {8{1'bx}};	// screw it
	endcase
	
end

//=================
// Probe generator
initial
begin
	clk = 0;
	KEYS[0] = 1;
	KEYS[1] = 0;
	KEYS[2] = 0;
	KEYS[2] = 0;
		// Reset spike
	#1000 KEYS[0] = 1;
	#1000 KEYS[0] = 0;
	#1000 KEYS[0] = 1;
end

always
begin
	#5 clk = !clk;
end

endmodule
