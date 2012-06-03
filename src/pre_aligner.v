module pre_aligner	#(
					parameter ADDRESS_WIDTH = 32,
					parameter DATA_WIDTH = 32,
					parameter INSN_WIDTH = 99
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Stall,

					//from I_CACHE
					input [ADDRESS_WIDTH-1:0] i_pc,			//of first instruction (i_isn1)
					input [DATA_WIDTH-1:0] i_isn1,
					input [DATA_WIDTH-1:0] i_isn2,
					input [DATA_WIDTH-1:0] i_isn3,
					input [DATA_WIDTH-1:0] i_isn4,

					// Outputs - to branch predictor
					output reg  o_isbranch,
					output reg [ADDRESS_WIDTH-1:0] o_branch_address,

					//Output - to Fetch
					output reg [ADDRESS_WIDTH-1:0] o_Branch_Target,
				);


always@(*)
begin

	if(i_isn1[9])		//first instruction is branch
	begin
		o_branch_address <= i_pc;
		o_isbranch <= 1;
		o_Branch_Target <= i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){i_isn1[15]}},i_isn1[15:0]};
	end

	else if(i_isn2[9])	//second instruction is branch
	begin
		o_branch_address <= i_pc+1;
		o_isbranch <= 1;
		o_Branch_Target <= i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){i_isn1[15]}},i_isn2[15:0]};
	end

	else if(i_isn3[9])	//third instruction is branch
	begin
		o_branch_address <= i_pc+2;
		o_isbranch <= 1;
		o_Branch_Target <= i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){i_isn1[15]}},i_isn3[15:0]};
	end

	else if(i_isn4[9])	//fourth instruction is branch
	begin
		o_branch_address <= i_pc+3;
		o_isbranch <= 1;
		o_Branch_Target <= i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){i_isn1[15]}},i_isn4[15:0]};
	end

	else				//no branches
	begin
		o_branch_address <= i_pc;
		o_isbranch <= 0;
		o_Branch_Target <= i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){i_isn1[15]}},i_isn4[15:0]};
	end
end

endmodule
