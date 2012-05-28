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
					input [ADDRESS_WIDTH-1:0] i_pc,			//of first instruction (i_isn1)

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
					output reg [3:0] o_valid,				//which instructions are  valid (4321)
					output [INSN_WIDTH-1:0] o_isn1,
					output [INSN_WIDTH-1:0] o_isn2,
					output [INSN_WIDTH-1:0] o_isn3,
					output [INSN_WIDTH-1:0] o_isn4
					//output reg [ISN_WIDTH*4-1:0] o_isn4to1
				);

//assign o_isn4to1 = {i_isn4, i_isn3, i_isn2, i_isn1};
assign o_isn1 = i_isn1;
assign o_isn2 = i_isn2;
assign o_isn3 = i_isn3;
assign o_isn4 = i_isn4;

always @(posedge i_Clk or negedge i_Reset_n)
begin

	//note - this doesn't account for consecutive branches - I don't think this will ever occur, given branch delay slot

	if(i_isn1[9])	//first instruction is branch
	begin
		o_valid <= 4'b0011;
		o_branch_addr <= i_pc;
		o_isbranch <= 1'b1;
		o_branch_target <= o_isn1[41:10];
	end

	else if(i_isn2[9])	//second instruction is branch
	begin
		o_valid <= 4'b0111;
		o_branch_addr <= i_pc + DATA_WIDTH;
		o_isbranch <= 1'b1;
		o_branch_target <= o_isn2[41:10];
	end

	else if(i_isn3[9])	//third instruction is branch
	begin
		o_valid <= 4'b1111;
		o_branch_addr <= i_pc + DATA_WIDTH*2;
		o_isbranch <= 1'b1;
		o_branch_target <= o_isn3[41:10];
	end

	else if(i_isn4[9])	//fourth instruction is branch
	begin
		o_valid <= 4'b1111;
		o_branch_addr <= i_pc + DATA_WIDTH*3;
		o_isbranch <= 1'b1;
		o_branch_target <= o_isn4[41:10];
	end

	else				//no branches
	begin
		o_valid <= 4'b1111;
		o_branch_addr <= i_pc;				//junk data
		o_isbranch <= 1'b0;
		o_branch_target <= o_isn4[41:10];	//junk data
	end
end

endmodule
