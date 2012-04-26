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
					input i_ALU_outcome,								//1 if taken 0 not taken
					input i_ALU_pc,									//pc from branch in ALU stage
					input i_ALU_isbranch,
					input i_ALU_prediction,							//prediction for branch in ALU
					
					input i_Reset_n,
					
					output reg o_taken,
					output reg o_valid,								//1 if a branch instruction
					output reg o_flush								//1 if i_outcome != prediction
				);
				
reg [1:0] bimodal;

localparam SCHEME = 00;
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
		bimodal[1:0] <= 11;
		//branchInstruction <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction 
		
		case(SCHEME)
		
			BIMODAL:
			begin
				o_taken <= bimodal[1];
				
				if(i_ALU_outcome != i_ALU_prediction)
				begin
					o_flush <= 1;
					case(i_ALU_prediction)
						0:
						begin 
							bimodal <= bimodal + 2;
						end
						1:
						begin
							bimodal <= bimodal - 2;
						end
					endcase
				end
				
				case(i_ALU_prediction)
					0:
					begin 
						bimodal <= bimodal + 1;
					end
					1:
					begin
						bimodal <= bimodal - 1;
					end
				endcase
				
			end
			
			GLOBAL:
			begin
			
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