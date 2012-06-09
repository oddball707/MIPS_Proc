// Pipeline stage
module pipe_dec_qr 	#(
						parameter ADDRESS_WIDTH = 32,
						parameter ISN_WIDTH = 99
					)
					(
						// Inputs
						input i_Clk,
						input i_Reset_n,	// Async reset (highest priority)
						input i_Flush,			// Flush (lowest priority)
						input i_Stall,		// Stall (2nd highest priority)
						
						input [ADDRESS_WIDTH-1:0] i_PC,
						output reg [ADDRESS_WIDTH-1:0] o_PC,
						input [ISN_WIDTH-1:0] i_Instruction1,
						input [ISN_WIDTH-1:0] i_Instruction2,
						input [ISN_WIDTH-1:0] i_Instruction3,
						input [ISN_WIDTH-1:0] i_Instruction4,
						output reg [ISN_WIDTH-1:0] o_Instruction1,
						output reg [ISN_WIDTH-1:0] o_Instruction2,
						output reg [ISN_WIDTH-1:0] o_Instruction3,
						output reg [ISN_WIDTH-1:0] o_Instruction4,
						input i_prediction,				//prediction from branch predictor
						output reg o_prediction,
						input [ADDRESS_WIDTH-1:0] i_branch_target,
						output reg [ADDRESS_WIDTH-1:0] o_branch_target,
						input [1:0] i_thread,
						output reg [1:0] o_thread, 
						input [3:0] i_valid,
						output reg [3:0] o_valid
					);

		// Asynchronous output driver
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			// Initialize outputs to 0s
			o_Instruction1 <= 0;
			o_Instruction2 <= 0;
			o_Instruction3 <= 0;
			o_Instruction4 <= 0;
			o_PC <= 0;
			o_prediction <= 0;
			o_branch_target <= 0;
			o_thread <= 0;
			o_valid <= 0;
		end
		else
		begin
			if( !i_Stall )
			begin
				if( i_Flush )
				begin
					// Pass through all 0s
					o_Instruction1 <= 0;
					o_Instruction2 <= 0;
					o_Instruction3 <= 0;
					o_Instruction4 <= 0;
					o_PC <= 0;
					o_prediction <= 0;
					o_branch_target <= 0;
					o_thread <= 0;
					o_valid <= 0;
				end
				else
				begin
					// Pass through signals
					o_Instruction1 <= i_Instruction1;
					o_Instruction2 <= i_Instruction2;
					o_Instruction3 <= i_Instruction3;
					o_Instruction4 <= i_Instruction4;
					o_PC <= i_PC;
					o_prediction <= i_prediction;
					o_branch_target <= i_branch_target;
					o_thread <= i_thread;
					o_valid <= i_valid;
				end
			end
		end
	end

endmodule
