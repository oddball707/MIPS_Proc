module branch_predictor#(	
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter GHR_SIZE = 3
				)
				(
					////Inputs from current stage
					input i_Clk,
					input [ADDRESS_WIDTH-1:0] i_IMEM_address,	//address in memory (for hash)
					
					////Inputs from ALU stage
					input i_ALU_outcome,								//1 if taken 0 not taken (from ALU computation)
					input [ADDRESS_WIDTH-1:0] i_ALU_pc,			//pc from branch in ALU stage
					input i_ALU_isbranch,							//if inst in ALU stage is a branch
					input i_ALU_prediction,							//prediction for branch in ALU
					
					input i_Reset_n,
					
					output reg o_taken

				);
				
reg [1:0] branch_history[0:7];												//hash table for branch histories - 7 indexing bits
wire [1:0] bimodal_index;
wire [1:0] bimodal_index2;
assign bimodal_index = branch_history[i_IMEM_address[GHR_SIZE-1:0]];			//index into this table (for bimodal 7 bits of PC)
assign bimodal_index2 = branch_history[i_ALU_pc[GHR_SIZE-1:0]];

reg [GHR_SIZE-1:0] GHR;															//index for global - shift register
wire [1:0] GHR_index;
reg [GHR_SIZE-1:0] GHR_saved;													//holds GHR from last prediction
reg GHR_saved_shift;													//holds bit that was shifted out, in case prediction was wrong
assign GHR_index = branch_history[GHR];

localparam SCHEME = 1;												//use this for selecting scheme
localparam BIMODAL = 0;
localparam GLOBAL = 1;
localparam GSELECT = 2;
localparam GSHARE = 3;

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
		branch_history[i] <= 3;
	end
	GHR = 3'b111;
end

always @(posedge i_Clk)
begin
		//branchInstruction <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction 
		
		case(SCHEME)
			
			BIMODAL:
			begin
			
				//then reconcile branch from 2 cycles ago
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					case(i_ALU_prediction)
						0:
						begin 
							branch_history[i_ALU_pc[GHR_SIZE-1:0]] <= bimodal_index2 + 2;
						end
						1:
						begin
							branch_history[i_ALU_pc[GHR_SIZE-1:0]] <= bimodal_index2 - 2;
						end
					endcase
				end
				
				//and update bimodal counter to reflect current branch
				case(bimodal_index[1])
					0:
					begin 
						branch_history[i_IMEM_address[GHR_SIZE-1:0]] <= bimodal_index + 1;
					end
					1:
					begin
						branch_history[i_IMEM_address[GHR_SIZE-1:0]] <= bimodal_index - 1;
					end
				endcase
				
			end
			
			GLOBAL:
			begin
				
				//next save GHR
				GHR_saved <= GHR;
				
				//then reconcile branch from 2 cycles ago
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					case(i_ALU_prediction)
						0:
						begin 
							branch_history[GHR_saved] <= branch_history[GHR_saved] + 2;
							GHR[1:0] <= {1'b1, GHR_index[1]};								//shift in corrected old guess and current prediction
							end
						1:
						begin
							branch_history[GHR_saved] <= branch_history[GHR_saved] - 2;
							GHR[1:0] <= {1'b0, GHR_index[1]};								//shift in corrected old guess and current prediction
						end
					endcase
				end
				else
				begin
					GHR <= {GHR[GHR_SIZE-2:0], GHR_index[1]};														//shift in prediction
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

always@(*)
begin
case(SCHEME)
			
			BIMODAL:
			begin
				//first predict current branch
				o_taken <= bimodal_index[1];
			end
			
			GLOBAL:
			begin
				//first predict current branch
				o_taken <= GHR_index[1];
			end
			
			default:
			begin
				o_taken <= 0;
			end
endcase
end
endmodule