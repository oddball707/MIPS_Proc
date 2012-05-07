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
					input [ADDRESS_WIDTH-1:0] i_ALU_pc,			//pc from branch in ALU stage
					input i_ALU_isbranch,							//if inst in ALU stage is a branch
					input i_ALU_prediction,							//prediction for branch in ALU
					
					input i_Reset_n,
					
					output reg o_taken,
					output reg o_valid,								//1 if a branch instruction
					output reg o_flush								//1 if i_outcome != prediction
				);
				
reg [1:0] branch_history[128];												//hash table for branch histories - 7 indexing bits
wire [1:0] bimodal_index;
wire [1:0] bimodal_index2;
assign bimodal_index = branch_history[i_IMEM_address[6:0]];			//index into this table (for bimodal 7 bits of PC)
assign bimodal_index2 = branch_history[i_ALU_pc[6:0]];

reg [6:0] GHR;															//index for global - shift register
wire [1:0] GHR_index;
reg [6:0] GHR_saved;													//holds GHR from last prediction
reg GHR_saved_shift;													//holds bit that was shifted out, in case prediction was wrong
assign GHR_index = branch_history[GHR];

localparam SCHEME = 00;												//use this for selecting scheme
localparam BIMODAL = 00;
localparam GLOBAL = 01;
localparam GSELECT = 10;
localparam GSHARE = 11;

integer i;	//for loops
//wire [3:0] opcode1;
//wire opcodeA, opcodeB, opcodeC;
//reg branchInstruction;							//1 if instruction is a branch

//assign opcode1 = i_IMEM_inst[31:29];		//first 3 bits of instruction opcode (000 for branch)
//assign opcodeA = i_IMEM_inst[28];			//next 3 bits of opcode (CBA)
//assign opcodeB = i_IMEM_inst[27];
//assign opcodeC = i_IMEM_inst[26];

//assign valid = branchInstruction;

initial begin
	for(i=0; i<128; i = i+1) begin
		branch_history[i] <= 11;
	end
	GHR = 1111111;
end

always @(*)
begin
		//branchInstruction <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction 
		
		case(SCHEME)
			
			BIMODAL:
			begin
				//first predict current branch
				o_taken <= bimodal_index[1];
				
				//then reconcile branch from 2 cycles ago
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					o_flush <= 1;
					case(i_ALU_prediction)
						0:
						begin 
							branch_history[i_ALU_pc[6:0]] <= bimodal_index2 + 2;
						end
						1:
						begin
							branch_history[i_ALU_pc[6:0]] <= bimodal_index2 - 2;
						end
					endcase
				end
				
				//and update bimodal counter to reflect current branch
				case(bimodal_index[1])
					0:
					begin 
						branch_history[i_IMEM_address[6:0]] <= bimodal_index + 1;
					end
					1:
					begin
						branch_history[i_IMEM_address[6:0]] <= bimodal_index - 1;
					end
				endcase
				
			end
			
			GLOBAL:
			begin
				//first predict current branch
				o_taken <= GHR_index[1];
				
				//next save GHR
				GHR_saved <= GHR;
				
				//then reconcile branch from 2 cycles ago
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					o_flush <= 1;
					case(i_ALU_prediction)
						0:
						begin 
							branch_history[GHR_saved] <= branch_history[GHR_saved] + 2;
							GHR[1:0] <= {1, GHR_index[1]};								//shift in corrected old guess and current prediction
							end
						1:
						begin
							branch_history[GHR_saved] <= branch_history[GHR_saved] - 2;
							GHR[1:0] <= {1, GHR_index[1]};								//shift in corrected old guess and current prediction
						end
					endcase
				end
				else
				begin
					GHR <= GHR << GHR_index[1];														//shift in prediction
				end
				
				//and update bimodal counter to reflect current branch
				case(GHR_index[1])
					0:
					begin 
							branch_history[GHR] <= branch_history[GHR] + 1;
					end
					1:
					begin
							branch_history[GHR] <= branch_history[GHR] - 1;
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