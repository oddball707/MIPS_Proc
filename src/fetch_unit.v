// Fetch Unit
//	Author: Pravin P. Prabhu
//	Version: 1.0
//	Last Revision: 7/10/10
//	Abstract:
//		This module provides instructions to the rest of the pipeline.

module fetch_unit	#(	
					parameter ADDRESS_WIDTH = 22,
					parameter DATA_WIDTH = 32
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Stall,
					
					//Control Signals
					input [3:0] i_branch_taken,		//from branch predictor X4
					input [7:0] i_branch_mispredict,	//from hazard detection/EX [first bit - if mispredicted, second if taken] x4
					input [1:0] i_thread_choice,		//which thread to take from 
					
					//The next address possibilities,
					//normal execution - PC + (4- PC%4)							//local information
					input [4*(ADDRESS_WIDTH)-1:0] i_current_target,			//from Pre-Aligner
					input [4*(ADDRESS_WIDTH)-1:0] i_mispredict_nottaken,	//from EX, target of mispredicted branch
					input [4*(ADDRESS_WIDTH)-1:0] i_mispredict_pc,			//from EX, pc of mispredicted branch
					
					// Outputs
					output reg [ADDRESS_WIDTH-1:0] o_PC
				);
	
	
reg [ADDRESS_WIDTH-1:0] o_PC1;
reg [ADDRESS_WIDTH-1:0] o_PC2;
reg [ADDRESS_WIDTH-1:0] o_PC3;
reg [ADDRESS_WIDTH-1:0] o_PC4;



	// PC incrementing state machine
always @(posedge i_Clk or negedge i_Reset_n)
begin
	if( !i_Reset_n )
	begin
		o_PC <= 0;
	end
	else
	begin
		if( !i_Stall )
		begin
			// If not stalled, we can change the PC
			case(i_thread_choice)
				0:
				begin
					case({i_branch_taken[0], i_branch_mispredict[1:0]})
						3'b00x:	//not taken, not mispredicted
						begin
							o_PC1 <= {o_PC1[ADDRESS_WIDTH-1:3]+1, 2'b00};	//PC = PC + (4-PC%4) 
						end
						
						3'b10x:	//taken, not mispredicted
						begin
							o_PC1 <= i_current_target[ADDRESS_WIDTH-1:0];
						end
						
						3'bx10:	//mispredicted as not taken
						begin
							o_PC1 <= i_mispredict_nottaken[ADDRESS_WIDTH-1:0];
						end
						
						3'bx11:	//mispredicted as taken
						begin
							o_PC1 <= {i_mispredict_pc[ADDRESS_WIDTH-1:3]+1, 2'b00};	//PC = PC + (4-PC%4)
						end
					endcase
				end
				
				1:
				begin
					case({i_branch_taken[1], i_branch_mispredict[3:2]})
						3'b00x:	//not taken, not mispredicted
						begin
							o_PC2 <= {o_PC2[ADDRESS_WIDTH-1:3]+1, 2'b00};	//PC = PC + (4-PC%4) 
						end
						
						3'b10x:	//taken, not mispredicted
						begin
							o_PC2 <= i_current_target[(2*ADDRESS_WIDTH)-1:ADDRESS_WIDTH];
						end
						
						3'bx10:	//mispredicted as not taken
						begin
							o_PC2 <= i_mispredict_nottaken[(2*ADDRESS_WIDTH)-1:ADDRESS_WIDTH];
						end
						
						3'bx11:	//mispredicted as taken
						begin
							o_PC2 <= {i_mispredict_pc[(2*ADDRESS_WIDTH)-1:ADDRESS_WIDTH+3]+1, 2'b00};	//PC = PC + (4-PC%4)
						end
					endcase
				end
				
				2:
				begin
					case({i_branch_taken[2], i_branch_mispredict[5:4]})
						3'b00x:	//not taken, not mispredicted
						begin
							o_PC3 <= {o_PC3[ADDRESS_WIDTH-1:3]+1, 2'b00};	//PC = PC + (4-PC%4) 
						end
						
						3'b10x:	//taken, not mispredicted
						begin
							o_PC3 <= i_current_target[(3*ADDRESS_WIDTH)-1:2*ADDRESS_WIDTH];
						end
						
						3'bx10:	//mispredicted as not taken
						begin
							o_PC3 <= i_mispredict_nottaken[(3*ADDRESS_WIDTH)-1:2*ADDRESS_WIDTH];
						end
						
						3'bx11:	//mispredicted as taken
						begin
							o_PC3 <= {i_mispredict_pc[(3*ADDRESS_WIDTH)-1:2*ADDRESS_WIDTH+3]+1, 2'b00};	//PC = PC + (4-PC%4)
						end
					endcase
				end
				
				3:
				begin
					case({i_branch_taken[3], i_branch_mispredict[7:6]})
						3'b00x:	//not taken, not mispredicted
						begin
							o_PC4 <= {o_PC4[ADDRESS_WIDTH-1:3]+1, 2'b00};	//PC = PC + (4-PC%4) 
						end
						
						3'b10x:	//taken, not mispredicted
						begin
							o_PC4 <= i_current_target[(4*ADDRESS_WIDTH)-1:3*ADDRESS_WIDTH];
						end
						
						3'bx10:	//mispredicted as not taken
						begin
							o_PC4 <= i_mispredict_nottaken[(4*ADDRESS_WIDTH)-1:3*ADDRESS_WIDTH];
						end
						
						3'bx11:	//mispredicted as taken
						begin
							o_PC4 <= {i_mispredict_pc[(4*ADDRESS_WIDTH)-1:3*ADDRESS_WIDTH+3]+1, 2'b00};	//PC = PC + (4-PC%4)
						end
					endcase
				end
				
			endcase
		end
	end
end



endmodule
