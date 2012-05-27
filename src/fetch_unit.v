// Fetch Unit
//	Author: Pravin P. Prabhu
//	Version: 1.0
//	Last Revision: 7/10/10
//	Abstract:
//		This module provides instructions to the rest of the pipeline.

module fetch_unit	#(	
					parameter ADDRESS_WIDTH = 32,
					parameter DATA_WIDTH = 32
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Stall,
					
					//Control Signals
					input i_branch_taken,				//from branch predictor
					input [1:0] i_branch_mispredict,	//from hazard detection/EX [first bit - if mispredicted, second if taken]
					input [1:0] i_thread_choice,		//which thread to take from
					
					//The next address possibilities,
					input [ADDRESS_WIDTH-1:0] i_current_target,			//from Aligner
					input [ADDRESS_WIDTH-1:0] i_mispredict_nottaken,	//from EX, old target
					
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
					if( i_branch_mispredict[0] )
					begin
						if( i_branch_mispredict[1] )
						begin
							o_PC1 <= o_PC1 + 8;		//advance 4 (fetch 4 at a time) x2 (branch delay slot)
						end
						else
						begin
							o_PC1 <= i_mispredict_nottaken;	//goto the target of that branch (older branch)
						end
					end
					else if( i_branch_taken )
					begin
						o_PC1 <= i_current_target;		//bp says take the branch, aligner gives target
					end
					else
					begin
						o_PC1 <= o_PC1 + 4;			//standard increment of pc
					end
					o_PC <= o_PC1;
				end
				
				1:
				begin
					if( i_branch_mispredict[0] )
					begin
						if( i_branch_mispredict[1] )
						begin
							o_PC2 <= o_PC2 + 8;		//advance 4 (fetch 4 at a time) x2 (branch delay slot)
						end
						else
						begin
							o_PC2 <= i_mispredict_nottaken;	//goto the target of that branch (older branch)
						end
					end
					else if( i_branch_taken )
					begin
						o_PC2 <= i_current_target;		//bp says take the branch, aligner gives target
					end
					else
					begin
						o_PC2 <= o_PC2 + 4;			//standard increment of pc
					end
					o_PC <= o_PC2;
				end
				
				2:
				begin
					if( i_branch_mispredict[0] )
					begin
						if( i_branch_mispredict[1] )
						begin
							o_PC3 <= o_PC3 + 8;		//advance 4 (fetch 4 at a time) x2 (branch delay slot)
						end
						else
						begin
							o_PC3 <= i_mispredict_nottaken;	//goto the target of that branch (older branch)
						end
					end
					else if( i_branch_taken )
					begin
						o_PC3 <= i_current_target;		//bp says take the branch, aligner gives target
					end
					else
					begin
						o_PC3 <= o_PC3 + 4;			//standard increment of pc
					end	
					o_PC <= o_PC3;
				end
				
				3:
				begin
					if( i_branch_mispredict[0] )
					begin
						if( i_branch_mispredict[1] )
						begin
							o_PC4 <= o_PC4 + 8;		//advance 4 (fetch 4 at a time) x2 (branch delay slot)
						end
						else
						begin
							o_PC4 <= i_mispredict_nottaken;	//goto the target of that branch (older branch)
						end
					end
					else if( i_branch_taken )
					begin
						o_PC4 <= i_current_target;		//bp says take the branch, aligner gives target
					end
					else
					begin
						o_PC4 <= o_PC4 + 4;			//standard increment of pc
					end	
					o_PC <= o_PC4;
				end
				
			endcase
		end
	end
end

//always@(*)
//begin
//	case(i_thread_choice)
//		0:
//		begin
//			o_PC <= o_PC1;
//		end
//		
//		1:
//		begin
//			o_PC <= o_PC2;
//		end
//		
//		2:
//		begin
//			o_PC <= o_PC3;
//		end
//		
//		3:
//		begin
//			o_PC <= o_PC4;		
//		end
//		
//		default:
//		begin
//			o_PC <= o_PC + 4;
//		end
//	endcase
//end

endmodule
