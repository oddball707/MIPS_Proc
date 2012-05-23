module branch_predictor#(	
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter GHR_SIZE = 8
				)
				(
					////Inputs from current stage
					input i_Clk,
					input [GHR_SIZE-1:0] i_IMEM_address,	//address in memory (for hash)
					
					input [DATA_WIDTH-1:0] i_IMEM_inst,		//instruction from icache, for branch determination logic
					
					////Inputs from ALU stage
					input i_ALU_outcome,								//1 if taken 0 not taken (from ALU computation)
					input [GHR_SIZE-1:0] i_ALU_pc,			//pc from branch in ALU stage
					input i_ALU_isbranch,							//if inst in ALU stage is a branch
					input i_ALU_prediction,							//prediction for branch in ALU
					
					input i_Reset_n,
					
					output reg o_taken								//prediction
					//output o_valid										//is it a branch?

				);
				
reg [1:0] branch_history[0:(2**GHR_SIZE)-1];												//hash table for branch histories - 7 indexing bits
wire [1:0] bimodal_index;
wire [1:0] bimodal_index2;
assign bimodal_index = branch_history[i_IMEM_address];			//index into this table (for bimodal 7 bits of PC)
assign bimodal_index2 = branch_history[i_ALU_pc];

reg [GHR_SIZE-1:0] GHR;															//index for global - shift register
wire [1:0] GHR_index;
reg [GHR_SIZE-1:0] GHR_saved;													//holds GHR from last prediction
reg GHR_saved_shift;													//holds bit that was shifted out, in case prediction was wrong
assign GHR_index = branch_history[GHR];

wire [GHR_SIZE-1:0] gselect_index;
wire [1:0] gselect_counter;
assign gselect_index = {GHR[GHR_SIZE-2:0], i_IMEM_address[1:0]};
assign gselect_counter = branch_history[gselect_index];

wire [GHR_SIZE-1:0] gshare_index;
wire [1:0] gshare_counter;
assign gshare_index = GHR[GHR_SIZE-1:0] ^ i_IMEM_address;
assign gshare_counter = branch_history[gshare_index];


localparam SCHEME = 1;												//use this for selecting scheme
localparam BIMODAL = 0;
localparam GLOBAL = 1;
localparam GSELECT = 2;
localparam GSHARE = 3;

integer i;	//for loops
wire [3:0] opcode1;
wire opcodeA, opcodeB, opcodeC;
reg branchInstruction;							//1 if instruction is a branch

assign opcode1 = i_IMEM_inst[31:29];		//first 3 bits of instruction opcode (000 for branch)
assign opcodeA = i_IMEM_inst[28];			//next 3 bits of opcode (CBA)
assign opcodeB = i_IMEM_inst[27];
assign opcodeC = i_IMEM_inst[26];


//assign o_valid = branchInstruction;

initial begin
	for(i=0; i<GHR_SIZE; i = i+1) begin
		branch_history[i] <= 2;
	end
	GHR <= 8'b11111111;
end

always @(posedge i_Clk)
begin
		branchInstruction <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction 
		
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
				//next save GHR+addr for indexing
				GHR_saved <= gselect_index;
				
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
					GHR <= {GHR[GHR_SIZE-2:0], gselect_counter[1]};														//shift in prediction
				end
				
				//and update bimodal counter to reflect current branch
				case(gselect_counter[1])
					0:
					begin 
							branch_history[gselect_index] <= branch_history[gselect_index] + 1;
					end
					1:
					begin
							branch_history[gselect_index] <= branch_history[gselect_index] - 1;
					end
				endcase			
			end
			
			GSHARE:
			begin
				//next save GHR+addr for indexing
				GHR_saved <= gshare_index;
				
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
					GHR <= {GHR[GHR_SIZE-2:0], gshare_counter[1]};														//shift in prediction
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
			
		endcase
		
		
end		

//Drive output prediction
always@(*)
begin
	if(branchInstruction)
	begin
		o_taken <= 0;
	end
	else
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
					
					GSELECT:
					begin
						//first predict current branch
						o_taken <= gselect_counter[1];
					end
					
					GSHARE:
					begin
						//first predict current branch
						o_taken <= gshare_counter[1];
					end
					default:
					begin
						o_taken <= 0;
					end
		endcase
	end
end
endmodule