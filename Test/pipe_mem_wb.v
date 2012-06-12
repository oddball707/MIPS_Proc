// Pipeline stage
module pipe_mem_wb	#(	parameter ADDRESS_WIDTH = 32,
						parameter DATA_WIDTH = 32,
						parameter REG_ADDR_WIDTH = 5
					)							
					(	
						// Inputs
						input i_Clk,
						input i_Reset_n,	// Async reset (highest priority)
						input i_Flush,			// Flush (2nd highest priority)
						input i_Stall,		// Stall (lowest priority)
						
							// Pipe in/out
						input [DATA_WIDTH-1:0] i_WriteBack_Data,
						output reg [DATA_WIDTH-1:0] o_WriteBack_Data,
						input i_Writes_Back,
						output reg o_Writes_Back,
						input [REG_ADDR_WIDTH-1:0] i_Write_Addr,
						output reg [REG_ADDR_WIDTH-1:0] o_Write_Addr
					);
		
		// Asynchronous output driver
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			// Initialize outputs to 0s
			o_WriteBack_Data <= 0;
			o_Writes_Back <= 0;
			o_Write_Addr <= 0;
		end
		else
		begin
			if( !i_Stall )
			begin
				if( i_Flush )
				begin
					// Pass through all 0s
					o_WriteBack_Data <= 0;
					o_Writes_Back <= 0;
					o_Write_Addr <= 0;
				end
				else
				begin
					// Pass through signals
					o_WriteBack_Data <= i_WriteBack_Data;
					o_Writes_Back <= i_Writes_Back;
					o_Write_Addr <= i_Write_Addr;
				end
			end
		end
	end
	
endmodule
		