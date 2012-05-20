module branch_target_buffer#(
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter BUFFER_SIZE = 8
				)
				(
					input i_Clk,
					
					//handle current stage target
					input [BUFFER_SIZE-1:0] i_pc,
					
					//handle write back from EX stage
					input [BUFFER_SIZE-1:0] i_ALU_pc,
					input [ADDRESS_WIDTH-1:0] i_ALU_target,
					
					//output target for current stage branch
					output [ADDRESS_WIDTH-1:0] o_target
				);
		
reg [ADDRESS_WIDTH-1:0] bt_buffer[0:(2**BUFFER_SIZE)-1];


always@(posedge i_Clk)
begin
	bt_buffer[i_ALU_pc] <= i_ALU_target;
end

assign o_target = bt_buffer[i_pc];


endmodule