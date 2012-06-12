module branch_predictor#(
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter GHR_SIZE = 8
				)
				(
					////Inputs from current stage
					input i_Clk,
					input [ADDRESS_WIDTH-1:0] i_IMEM_address,	//address in memory (for hash)

					////Inputs from ALU stage
					input i_isbranch_check,					//don't want to update tables for a non-branch
					input i_ALU_outcome,					//1 if taken 0 not taken (from ALU computation)
					input [ADDRESS_WIDTH-1:0] i_ALU_pc,			//pc from branch in ALU stage
					input i_ALU_isbranch,					//if inst in ALU stage is a branch
					input i_ALU_prediction,					//prediction for branch in ALU

					input i_Reset_n,
					input i_Stall,

					output reg o_taken						//prediction
				);

//-----Branch history table-----
reg [1:0] branch_history[0:(2**GHR_SIZE)-1];				//hash table for branch histories - 7 indexing bits

//-----GSHARE-----
reg [GHR_SIZE-1:0] GHR;										//shift register
wire [GHR_SIZE-1:0] gshare_index;
wire [1:0] gshare_counter;									//base bimodal counter
wire [1:0] GHR_index;
reg [GHR_SIZE-1:0] GHR_saved;								//holds GHR from last prediction
assign gshare_index = GHR[GHR_SIZE-1:0] ^ i_IMEM_address[GHR_SIZE-1:0];
assign gshare_counter = branch_history[gshare_index];		//holds bit that was shifted out, in case prediction was wrong

integer i;	//for loops

initial begin
	for(i=0; i<GHR_SIZE; i = i+1) begin
		branch_history[i] <= 2;
	end
	GHR <= 8'b11111111;
end

always @(posedge i_Clk)
begin
	if( !i_Reset_n )
	begin
		GHR <= 0;
		GHR_saved <= 0;
		o_taken <= 0;
	end
	else
	begin
		if(!i_Stall && i_isbranch_check)
		begin
			//next save GHR XOR addr for indexing
			GHR_saved <= gshare_index;

			//then reconcile branch from 2 cycles ago
			if((i_ALU_outcome != i_ALU_prediction) && i_ALU_isbranch)
			begin
				case(i_ALU_prediction)
					0:
					begin
						branch_history[GHR_saved] <= branch_history[GHR_saved] + 2;		//+2 to compensate for incorrect -1
						GHR[1:0] <= {1'b1, GHR_index[1]};								//shift in corrected old guess and current prediction
						end
					1:
					begin
						branch_history[GHR_saved] <= branch_history[GHR_saved] - 2;		//-2 to compensate for incorrect +1
						GHR[1:0] <= {1'b0, GHR_index[1]};								//shift in corrected old guess and current prediction
					end
				endcase
			end
			else
			begin
				GHR <= {GHR[GHR_SIZE-2:0], gshare_counter[1]};							//shift in prediction
			end

			//and update bimodal counter to reflect current branch
			case(gshare_counter[1])
				0:
				begin
						branch_history[gshare_index] <= branch_history[gshare_index] + 1;
				end
				1:
				begin
						branch_history[gshare_index] <= branch_history[gshare_index] - 1;
				end
			endcase
		end
	end
end

//Drive output prediction
always@(*)
begin

		//first predict current branch
		o_taken <= gshare_counter[1];

end
endmodule