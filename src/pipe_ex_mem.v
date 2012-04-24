// Pipeline stage
module pipe_ex_mem	#(					
						parameter ADDRESS_WIDTH = 32,
						parameter DATA_WIDTH = 32,
						parameter REG_ADDR_WIDTH = 5,
						parameter ALU_CTLCODE_WIDTH = 8,
						parameter MEM_MASK_WIDTH = 3
					)							
					(	
						// Inputs
						input i_Clk,
						input i_Reset_n,	// Async reset (highest priority)
						input i_Flush,			// Flush (2nd highest priority)
						input i_Stall,		// Stall (lowest priority)
						
							// Pipe in/out
						input [DATA_WIDTH-1:0] i_ALU_Result,
						output reg [DATA_WIDTH-1:0] o_ALU_Result,
						input i_Mem_Valid,
						output reg o_Mem_Valid,
						input [MEM_MASK_WIDTH-1:0] i_Mem_Mask,
						output reg [MEM_MASK_WIDTH-1:0] o_Mem_Mask,
						input i_Mem_Read_Write_n,
						output reg o_Mem_Read_Write_n,
						input [DATA_WIDTH-1:0] i_Mem_Write_Data,
						output reg [DATA_WIDTH-1:0] o_Mem_Write_Data,
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
			o_ALU_Result <= 0;
			o_Mem_Valid <= 0;
			o_Mem_Read_Write_n <= 0;
			o_Mem_Write_Data <= 0;
			o_Writes_Back <= 0;
			o_Write_Addr <= 0;
			o_Mem_Mask <= 0;
		end
		else
		begin
			if( !i_Stall )
			begin
				if( i_Flush )
				begin
					// Pass through all 0s
					o_ALU_Result <= 0;
					o_Mem_Valid <= 0;
					o_Mem_Read_Write_n <= 0;
					o_Mem_Write_Data <= 0;
					o_Writes_Back <= 0;
					o_Write_Addr <= 0;
					o_Mem_Mask <= 0;
				end
				else
				begin
					// Pass through signals
					o_ALU_Result <= i_ALU_Result;
					o_Mem_Valid <= i_Mem_Valid;
					o_Mem_Mask <= i_Mem_Mask;
					o_Mem_Read_Write_n <= i_Mem_Read_Write_n;
					o_Mem_Write_Data <= i_Mem_Write_Data;
					o_Writes_Back <= i_Writes_Back;
					o_Write_Addr <= i_Write_Addr;
				end
			end
		end
	end
	
endmodule
		