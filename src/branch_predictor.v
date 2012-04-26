module branch_predictor#(	parameter DATA_WIDTH = 32,
					parameter ADDR_LENGTH = 22
				)
				(

					input i_Clk,
					input [ADDR_LENGTH-1:0] i_IMEM_address,		//address in memory (for hash)
					input [DATA_WIDTH-1:0]i_IMEM_inst,			//instruction
					input i_outcome,								//1 if taken 0 not taken
					input i_Reset_n,
					
					output reg o_taken,
					output reg o_valid,								//1 if a branch instruction
					output reg o_flush									//1 if i_outcome != prediction
				);
				
reg [1:0] bimodal;

localparam SCHEME = 00;
localparam BIMODAL = 00;
localparam GLOBAL = 01;
localparam GSELECT = 10;
localparam GSHARE = 11;

reg last_guess;									//1 if guessed taken last time
wire [3:0] opcode1;
wire opcodeA, opcodeB, opcodeC;
reg branchInstruction;							//1 if instruction is a branch

assign opcode1 = i_IMEM_inst[31:29];		//first 3 bits of instruction opcode (000 for branch)
assign opcodeA = i_IMEM_inst[28];			//next 3 bits of opcode (CBA)
assign opcodeB = i_IMEM_inst[27];
assign opcodeC = i_IMEM_inst[26];

assign valid = branchInstruction;

always @(*)
begin
		bimodal[1:0] <= 11;
		branchInstruction <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction 
		
		case(SCHEME)
		
			BIMODAL:
			begin
				o_taken <= bimodal[1];
				last_guess <= bimodal[1];
				if(i_outcome != last_guess)
				begin
					o_flush <= 1;
					case(last_guess)
						0:
						begin 
							bimodal = bimodal + 2;
						end
						1:
						begin
							bimodal = bimodal - 2;
						end
					endcase
				end
				
				case(last_guess)
					0:
					begin 
						bimodal = bimodal + 1;
					end
					1:
					begin
						bimodal = bimodal - 1;
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