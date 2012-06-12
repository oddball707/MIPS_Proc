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
					input i_branch_taken,		//from branch predictor
					input i_jump_inst,			//from pre-align
					input i_jr_inst,			//from pre-align
					input i_branch_inst,
					input [3:0] i_branch_mispredict,	//from hazard detection/EX [first bit - if mispredicted, second if taken, 3rd/4th bits for thread]
					input [1:0] i_thread_choice,		//which thread to take from - from Queue

					//The next address possibilities,
					//normal execution - PC + (4- PC%4)							//local information
					input [(ADDRESS_WIDTH)-1:0] i_current_target,			//from Pre-Aligner
					input [(ADDRESS_WIDTH)-1:0] i_mispredict_nottaken,	//from EX, target of mispredicted branch
					input [(ADDRESS_WIDTH)-1:0] i_mispredict_pc,			//from EX, pc of mispredicted branch
					input [(ADDRESS_WIDTH)-1:0] i_jstack_jrtarget,		//from jump stack, address for jr

					// Outputs
					output reg [ADDRESS_WIDTH-1:0] o_PC
				);


reg [ADDRESS_WIDTH-1:0] o_PC1;
reg [ADDRESS_WIDTH-1:0] o_PC2;
reg [ADDRESS_WIDTH-1:0] o_PC3;
reg [ADDRESS_WIDTH-1:0] o_PC4;

reg [1:0] last_thread;

	// PC incrementing state machine
always @(posedge i_Clk or negedge i_Reset_n)
begin
	if( !i_Reset_n )
	begin
		o_PC <= 0;
		o_PC1 <= 0;
		o_PC2 <= 0;
		o_PC3 <= 0;
		o_PC4 <= 0;
		last_thread <= 0;
	end
	else
	begin
		if( !i_Stall )
		begin
			// If not stalled, we can change the PC
			last_thread <= i_thread_choice;

			//update first thread
			if(i_branch_mispredict[3] && i_branch_mispredict[1:0] == 2'b00) //check for mispredict
			begin
				if(i_branch_mispredict[2]) //mispredict not taken
				begin
					o_PC1 <= i_mispredict_nottaken;
				end
				else	//mispredicted taken
				begin
					o_PC1 <= {i_mispredict_pc[ADDRESS_WIDTH-1:3], 2'b00};	//PC = PC + (4-PC%4)
				end
			end
			else if(last_thread == 2'b00 && ((i_branch_taken &&  i_branch_inst) || i_jump_inst))	//check if branched/jal/j
			begin
				o_PC1 <= i_current_target;
			end
			else if(last_thread == 2'b00 && i_jr_inst)	//check if jr'ed
			begin
				o_PC1 <= i_jstack_jrtarget;
			end
			else if(i_thread_choice == 2'b00)	//check if this thread is selected
			begin
				o_PC1 <= o_PC1+4;
			end

			//update 2nd thread
			if(i_branch_mispredict[3] && i_branch_mispredict[1:0] == 2'b01) //check for mispredict
			begin
				if(i_branch_mispredict[2]) //mispredict not taken
				begin
					o_PC2 <= i_mispredict_nottaken;
				end
				else	//mispredicted taken
				begin
					o_PC2 <= {i_mispredict_pc[ADDRESS_WIDTH-1:3], 2'b00};	//PC = PC + (4-PC%4)
				end
			end
			else if(last_thread == 2'b01 && ((i_branch_taken &&  i_branch_inst) || i_jump_inst))	//check if branched/jal/j
			begin
				o_PC2 <= i_current_target;
			end
			else if(last_thread == 2'b01 && i_jr_inst)	//check if jr'ed
			begin
				o_PC2 <= i_jstack_jrtarget;
			end
			else if(i_thread_choice == 2'b01)	//check if this thread is selected
			begin
				o_PC2 <= o_PC2+4;
			end

			//update 3nd thread
			if(i_branch_mispredict[3] && i_branch_mispredict[1:0] == 2'b10) //check for mispredict
			begin
				if(i_branch_mispredict[2]) //mispredict not taken
				begin
					o_PC3 <= i_mispredict_nottaken;
				end
				else	//mispredicted taken
				begin
					o_PC3 <= {i_mispredict_pc[ADDRESS_WIDTH-1:3], 2'b00};	//PC = PC + (4-PC%4)
				end
			end
			else if(last_thread == 2'b10 && ((i_branch_taken &&  i_branch_inst) || i_jump_inst))	//check if branched/jal/j
			begin
				o_PC3 <= i_current_target;
			end
			else if(last_thread == 2'b10 && i_jr_inst)	//check if jr'ed
			begin
				o_PC3 <= i_jstack_jrtarget;
			end
			else if(i_thread_choice == 2'b10)	//check if this thread is selected
			begin
				o_PC3 <= o_PC3+4;
			end

			//update 4nd thread
			if(i_branch_mispredict[3] && i_branch_mispredict[1:0] == 2'b11) //check for mispredict
			begin
				if(i_branch_mispredict[2]) //mispredict not taken
				begin
					o_PC4 <= i_mispredict_nottaken;
				end
				else	//mispredicted taken
				begin
					o_PC4 <= {i_mispredict_pc[ADDRESS_WIDTH-1:3], 2'b00};	//PC = PC + (4-PC%4)
				end
			end
			else if(last_thread == 2'b11 && ((i_branch_taken &&  i_branch_inst) || i_jump_inst))	//check if branched/jal/j
			begin
				o_PC4 <= i_current_target;
			end
			else if(last_thread == 2'b11 && i_jr_inst)	//check if jr'ed
			begin
				o_PC4 <= i_jstack_jrtarget;
			end
			else if(i_thread_choice == 2'b11)	//check if this thread is selected
			begin
				o_PC4 <= o_PC4+4;
			end


		end
	end
end

always@(*)
begin
	//finally drive output based on thread choice
	case(i_thread_choice)
		0:
		begin
			o_PC = o_PC1;
		end

		1:
		begin
			o_PC = o_PC2;
		end

		2:
		begin
			o_PC = o_PC3;
		end

		3:
		begin
			o_PC = o_PC4;
		end

	endcase
end

endmodule
