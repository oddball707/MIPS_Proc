module icache_mux#(
					parameter ADDRESS_WIDTH = 22
				)
				(
					input i_Clk,
					
					//input from fetch unit
					input [ADDRESS_WIDTH-1:0] i_pc,
					
					//input from branch predictor/btb
					input [ADDRESS_WIDTH-1:0] i_branch_pc,		//branch target from btb
					input i_predictor_taken,						//prediction from branch predictor
					
					//output target for current stage branch
					output [ADDRESS_WIDTH-1:0] o_target			//result based on prediction
				);
		
reg [ADDRESS_WIDTH-1:0] result;


always@(posedge i_Clk)
begin
	if(i_predictor_taken)
	begin
		result <= i_branch_pc;
	end
	else
	begin
		result <= i_pc;
	end
end

assign o_target = result;


endmodule