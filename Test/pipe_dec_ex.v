// Pipeline stage
module pipe_dec_ex	#(					
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
						input [ADDRESS_WIDTH-1:0] i_PC,
						output reg [ADDRESS_WIDTH-1:0] o_PC,
						input i_Uses_ALU,
						output reg o_Uses_ALU,
						input [ALU_CTLCODE_WIDTH-1:0] i_ALUCTL,
						output reg [ALU_CTLCODE_WIDTH-1:0] o_ALUCTL,
						input i_Is_Branch,
						output reg o_Is_Branch,
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
						output reg [REG_ADDR_WIDTH-1:0] o_Write_Addr,
						input [DATA_WIDTH-1:0] i_Operand1,
						output reg [DATA_WIDTH-1:0] o_Operand1,
						input [DATA_WIDTH-1:0] i_Operand2,
						output reg [DATA_WIDTH-1:0] o_Operand2,
						input [ADDRESS_WIDTH-1:0] i_Branch_Target,
						output reg [ADDRESS_WIDTH-1:0] o_Branch_Target
					);
		
		// Asynchronous output driver
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			// Initialize outputs to 0s
			o_PC <= 0;
			o_Uses_ALU <= 0;
			o_ALUCTL <= 0;
			o_Is_Branch <= 0;
			o_Mem_Valid <= 0;
			o_Mem_Read_Write_n <= 0;
			o_Writes_Back <= 0;
			o_Write_Addr <= 0;
			o_Operand1 <= 0;
			o_Operand2 <= 0;
			o_Branch_Target <= 0;
			o_Mem_Write_Data <= 0;
			o_Mem_Mask <= 0;
		end
		else
		begin
			if( !i_Stall )
			begin
				if( i_Flush )
				begin
					// Pass through all 0s
					o_PC <= 0;
					o_Uses_ALU <= 0;
					o_ALUCTL <= 0;
					o_Is_Branch <= 0;
					o_Mem_Valid <= 0;
					o_Mem_Read_Write_n <= 0;
					o_Writes_Back <= 0;
					o_Write_Addr <= 0;
					o_Operand1 <= 0;
					o_Operand2 <= 0;
					o_Branch_Target <= 0;
					o_Mem_Write_Data <= 0;
					o_Mem_Mask <= 0;
				end
				else
				begin
					// Pass through signals
					o_PC <= i_PC;
					o_Uses_ALU <= i_Uses_ALU;
					o_ALUCTL <= i_ALUCTL;
					o_Is_Branch <= i_Is_Branch;
					o_Mem_Valid <= i_Mem_Valid;
					o_Mem_Mask <= i_Mem_Mask;
					o_Mem_Read_Write_n <= i_Mem_Read_Write_n;
					o_Mem_Write_Data <= i_Mem_Write_Data;
					o_Writes_Back <= i_Writes_Back;
					o_Write_Addr <= i_Write_Addr;
					o_Operand1 <= i_Operand1;
					o_Operand2 <= i_Operand2;
					o_Branch_Target <= i_Branch_Target;
				end
			end
		end
	end
	
endmodule
		