module branch_predictor#(	
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22
				)
				(
					////Inputs from current stage
					input i_Clk,
					input [ADDRESS_WIDTH-1:0] i_IMEM_address,	//address in memory (for hash)
					input i_IMEM_isbranch,							//Is it a branch?
					
					////Inputs from ALU stage
					input i_ALU_outcome,								//1 if taken 0 not taken (from ALU computation)
					input i_ALU_pc,									//pc from branch in ALU stage
					input i_ALU_isbranch,							//if inst in ALU stage is a branch
					input i_ALU_prediction,							//prediction for branch in ALU
					
					input i_Reset_n,
					
					output reg o_taken,
					output reg o_valid,								//1 if a branch instruction
					output reg o_flush								//1 if i_outcome != prediction
				);
				
reg [1:0] branch_history[128];												//hash table for branch histories
reg [6:0] bimodal_index;											//index into this table (for bimodal 7 bits of PC)
assign bimodal_index = i_IMEM_address[6:0];
reg [1:0] counter <= branch_history[i_IMEM_address];
reg [1:0] counter2 <= branch_history[i_ALU_pc];
reg [3:0] GHR;															//index for global - shift register

localparam SCHEME = 00;												//use this for selecting scheme
localparam BIMODAL = 00;
localparam GLOBAL = 01;
localparam GSELECT = 10;
localparam GSHARE = 11;

//wire [3:0] opcode1;
//wire opcodeA, opcodeB, opcodeC;
//reg branchInstruction;							//1 if instruction is a branch

//assign opcode1 = i_IMEM_inst[31:29];		//first 3 bits of instruction opcode (000 for branch)
//assign opcodeA = i_IMEM_inst[28];			//next 3 bits of opcode (CBA)
//assign opcodeB = i_IMEM_inst[27];
//assign opcodeC = i_IMEM_inst[26];

//assign valid = branchInstruction;

always @(*)
begin
		branch_history[1:0] <= 11;
		//branchInstruction <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction 
		
		
		case(SCHEME)
		
			BIMODAL:
			begin
				//first predict current branch
				o_taken <= counter[1];
				
				//then reconcile branch from 2 cycles ago
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					o_flush <= 1;
					case(i_ALU_prediction)
						0:
						begin 
							branch_history[i_ALU_pc] <= counter2 + 2;
						end
						1:
						begin
							branch_history[i_ALU_pc] <= counter2 - 2;
						end
					endcase
				end
				
				//and update bimodal counter to reflect current branch
				case(counter[1])
					0:
					begin 
						branch_history[i_IMEM_address] <= counter + 1;
					end
					1:
					begin
						branch_history[i_IMEM_address] <= counter - 1;
					end
				endcase
				
			end
			
			GLOBAL:
			begin
				//first predict current branch
				o_taken <= counter[1];
				
				//then reconcile branch from 2 cycles ago
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					o_flush <= 1;
					case(i_ALU_prediction)
						0:
						begin 
							branch_history[i_ALU_pc] <= counter2 + 2;
						end
						1:
						begin
							branch_history[i_ALU_pc] <= counter2 - 2;
						end
					endcase
				end
				
				//and update bimodal counter to reflect current branch
				case(counter[1])
					0:
					begin 
						branch_history[i_IMEM_address] <= counter + 1;
					end
					1:
					begin
						branch_history[i_IMEM_address] <= counter - 1;
					end
				endcase
			end
			
			GSELECT:
			begin
			
			end
			
			GSHARE:
			begin
			
			end
			
		endcase
		
		
end		
endmodule