module aligner	#(	
					parameter ADDRESS_WIDTH = 32,
					parameter DATA_WIDTH = 32,
					parameter INSN_WIDTH = 99
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Stall,
					
					//from I_CACHE
					input [ADDRESS_WIDTH-1:0] i_pc,
					
					//from decoder
					input [INSN_WIDTH-1:0] i_isn1,
					input [INSN_WIDTH-1:0] i_isn2,
					input [INSN_WIDTH-1:0] i_isn3,
					input [INSN_WIDTH-1:0] i_isn4,
					
					// Outputs - back for branches
					output reg [ADDRESS_WIDTH-1:0] o_branch_addr,
					output reg o_isbranch,
					output reg [ADDRESS_WIDTH-1:0] o_branch_target,
					
					// Outputs - to Queues 
					output reg [3:0] o_valid,
					output reg [INSN_WIDTH-1:0] o_isn1,
					output reg [INSN_WIDTH-1:0] o_isn2,
					output reg [INSN_WIDTH-1:0] o_isn3,
					output reg [INSN_WIDTH-1:0] o_isn4,
				);
	
	

always @(posedge i_Clk or negedge i_Reset_n)
begin

end

endmodule
