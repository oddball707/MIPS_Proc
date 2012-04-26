// Pipeline stage
module pipe_if_dec 	#(					
						parameter ADDRESS_WIDTH = 32,
						parameter DATA_WIDTH = 32
					)							
					(	
						// Inputs
						input i_Clk,
						input i_Reset_n,	// Async reset (highest priority)
						input i_Flush,			// Flush (lowest priority)
						input i_Stall,		// Stall (2nd highest priority)
						
							// Pipe in/out
						input [ADDRESS_WIDTH-1:0] i_PC,
						output reg [ADDRESS_WIDTH-1:0] o_PC,
						input [DATA_WIDTH-1:0] i_Instruction,
						output reg [DATA_WIDTH-1:0] o_Instruction,
						input i_prediction,				//prediction from branch predictor
						output reg o_prediction 
					);
		
		// Asynchronous output driver
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			// Initialize outputs to 0s
			o_Instruction <= 0;
			o_PC <= 0;
			o_prediction <= 0;
		end
		else
		begin
			if( !i_Stall )
			begin
				if( i_Flush )
				begin
					// Pass through all 0s
					o_Instruction <= 0;
					o_PC <= 0;
					o_prediction <= 0;
				end
				else
				begin
					// Pass through signals
					o_Instruction <= i_Instruction;
					o_PC <= i_PC;
					o_prediction <= i_prediction;
				end
			end
		end
	end
	
endmodule
		