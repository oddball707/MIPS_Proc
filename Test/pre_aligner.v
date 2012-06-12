module pre_aligner	#(
					parameter ADDRESS_WIDTH = 22,
					parameter DATA_WIDTH = 32
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Stall,

					//from I_CACHE
					input [ADDRESS_WIDTH-1:0] i_pc,			//of first instruction (i_inst1)
					input [DATA_WIDTH-1:0] i_inst1,
					input [DATA_WIDTH-1:0] i_inst2,
					input [DATA_WIDTH-1:0] i_inst3,
					input [DATA_WIDTH-1:0] i_inst4,

					// Outputs - to branch predictor
					output reg  o_isbranch,
					output reg [ADDRESS_WIDTH-1:0] o_branch_address,

					//Output - to Fetch
					output reg [ADDRESS_WIDTH-1:0] o_Branch_Target,

					//Output - to jump stack, fetch
					output reg o_j_inst,
					output reg o_jal_inst,
					output reg o_jr_inst
				);

reg [DATA_WIDTH-1:0] o_isn1;
reg [DATA_WIDTH-1:0] o_isn2;
reg [DATA_WIDTH-1:0] o_isn3;
reg [DATA_WIDTH-1:0] o_isn4;

wire [3:0] opcode[0:3];
wire opcodeA[0:3], opcodeB[0:3], opcodeC[0:3];
wire [5:0] fncode[0:3];
wire [3:0] branchInstruction;
wire [3:0] jalInstruction;
wire [3:0] jumpInstruction;
wire [3:0] jrInstruction;

reg [3:0] o_branchInstruction;
reg [3:0] o_jalInstruction;
reg [3:0] o_jumpInstruction;
reg [3:0] o_jrInstruction;


assign opcode[0] = i_inst1[31:29];		//first 3 bits of instruction opcode (000 for branch)
assign opcodeA[0] = i_inst1[28];			//next 3 bits of opcode
assign opcodeB[0] = i_inst1[27];
assign opcodeC[0] = i_inst1[26];
assign fncode[0] = i_inst1[5:0];

assign opcode[1] = i_inst2[31:29];		//first 3 bits of instruction opcode (000 for branch)
assign opcodeA[1] = i_inst2[28];			//next 3 bits of opcode
assign opcodeB[1] = i_inst2[27];
assign opcodeC[1] = i_inst2[26];
assign fncode[1] = i_inst2[5:0];

assign opcode[2] = i_inst3[31:29];		//first 3 bits of instruction opcode (000 for branch)
assign opcodeA[2] = i_inst3[28];			//next 3 bits of opcode
assign opcodeB[2] = i_inst3[27];
assign opcodeC[2] = i_inst3[26];
assign fncode[2] = i_inst3[5:0];

assign opcode[3] = i_inst4[31:29];		//first 3 bits of instruction opcode (000 for branch)
assign opcodeA[3] = i_inst4[28];			//next 3 bits of opcode
assign opcodeB[3] = i_inst4[27];
assign opcodeC[3] = i_inst4[26];
assign fncode[3] = i_inst4[5:0];

assign branchInstruction[0] = !opcode[0] && (opcodeA[0] || (!opcodeB[0] &&  opcodeC[0]));	//1 if branch instruction
assign branchInstruction[1] = !opcode[1] && (opcodeA[1] || (!opcodeB[1] &&  opcodeC[1]));	//1 if branch instruction
assign branchInstruction[2] = !opcode[2] && (opcodeA[2] || (!opcodeB[2] &&  opcodeC[2]));	//1 if branch instruction
assign branchInstruction[3] = !opcode[3] && (opcodeA[3] || (!opcodeB[3] &&  opcodeC[3]));	//1 if branch instruction

assign jalInstruction[0] = !opcode[0] && (!opcodeA[0] && opcodeB[0] && opcodeC[0]);	//1 if jal instruction
assign jalInstruction[1] = !opcode[1] && (!opcodeA[1] && opcodeB[1] && opcodeC[1]);	//1 if jal instruction
assign jalInstruction[2] = !opcode[2] && (!opcodeA[1] && opcodeB[2] && opcodeC[2]);	//1 if jal instruction
assign jalInstruction[3] = !opcode[3] && (!opcodeA[3] && opcodeB[3] && opcodeC[3]);	//1 if jal instruction

assign jumpInstruction[0] = !opcode[0] && (!opcodeA[0] && opcodeB[0]);	//1 if jal or j instruction
assign jumpInstruction[1] = !opcode[1] && (!opcodeA[1] && opcodeB[1]);	//1 if jal or j instruction
assign jumpInstruction[2] = !opcode[2] && (!opcodeA[1] && opcodeB[2]);	//1 if jal or j instruction
assign jumpInstruction[3] = !opcode[3] && (!opcodeA[3] && opcodeB[3]);	//1 if jal or j instruction

assign jrInstruction[0] = !{opcode[0],opcodeA[0],opcodeB[0],opcodeC[0]} && fncode[0] == 01000;	//1 if jr instruction
assign jrInstruction[1] = !{opcode[1],opcodeA[1],opcodeB[1],opcodeC[1]} && fncode[1] == 01000;	//1 if jr instruction
assign jrInstruction[2] = !{opcode[2],opcodeA[2],opcodeB[2],opcodeC[2]} && fncode[2] == 01000;	//1 if jr instruction
assign jrInstruction[3] = !{opcode[3],opcodeA[3],opcodeB[3],opcodeC[3]} && fncode[3] == 01000;	//1 if jr instruction

always@(posedge i_Clk)
begin

	case(i_pc[1:0])
		0:
		begin
			o_isn1 <= i_inst1;
			o_isn2 <= i_inst2;
			o_isn3 <= i_inst3;
			o_isn4 <= i_inst4;
		end

		1:
		begin
			o_isn1 <= i_inst2;
			o_isn2 <= i_inst3;
			o_isn3 <= i_inst4;
			o_isn4 <= 0;
			o_branchInstruction <= branchInstruction << 1;
			o_jalInstruction <= jalInstruction << 1;
			o_jumpInstruction <= jumpInstruction << 1;
			o_jrInstruction <= jrInstruction << 1;
		end

		2:
		begin
			o_isn1 <= i_inst3;
			o_isn2 <= i_inst4;
			o_isn3 <= 0;
			o_isn4 <= 0;
			o_branchInstruction <= branchInstruction << 2;
			o_jalInstruction <= jalInstruction << 2;
			o_jumpInstruction <= jumpInstruction << 2;
			o_jrInstruction <= jrInstruction << 2;
		end

		3:
		begin
			o_isn1 <= i_inst4;
			o_isn2 <= 0;
			o_isn3 <= 0;
			o_isn4 <= 0;
			o_branchInstruction <= branchInstruction << 3;
			o_jalInstruction <= jalInstruction << 3;
			o_jumpInstruction <= jumpInstruction << 3;
			o_jrInstruction <= jrInstruction << 3;
		end
	endcase

	if(o_branchInstruction[0] || o_jumpInstruction[0] || o_jrInstruction[0])		//first instruction is branch/j
	begin
		o_branch_address <= i_pc;
		if(o_branchInstruction[0])
		begin
			o_isbranch <= 1;
			o_Branch_Target <= i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){i_inst1[15]}},i_inst1[15:0]};
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(o_jrInstruction[0])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= i_pc; //junk data - pop address off stack
			o_jr_inst <= 1;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(jalInstruction[0])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn1[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 1;
			o_j_inst <= 0;
		end
		else	//j
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn1[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 1;
		end
	end

	else if(o_branchInstruction[1] || o_jumpInstruction[1] || o_jrInstruction[1])	//second instruction is branch/j
	begin
		o_branch_address <= i_pc+1;
		if(o_branchInstruction[1])
		begin
			o_isbranch <= 1;
			o_Branch_Target <= (i_pc+1) + 22'd1 + {{(ADDRESS_WIDTH-16){i_inst2[15]}},i_inst2[15:0]};
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(o_jrInstruction[1])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= i_pc; //junk data - pop address off stack
			o_jr_inst <= 1;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(jalInstruction[1])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn2[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 1;
			o_j_inst <= 0;
		end
		else	//j
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn2[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 1;
		end
	end

	else if(o_branchInstruction[2] || o_jumpInstruction[2] || o_jrInstruction[2])	//third instruction is branch/j
	begin
		o_branch_address <= i_pc+2;
		if(o_branchInstruction[2])
		begin
			o_isbranch <= 1;
			o_Branch_Target <= (i_pc+2) + 22'd1 + {{(ADDRESS_WIDTH-16){i_inst3[15]}},i_inst3[15:0]};
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(o_jrInstruction[2])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= i_pc+2; //junk data - pop address off stack
			o_jr_inst <= 1;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(jalInstruction[2])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn3[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 1;
			o_j_inst <= 0;
		end
		else	//j
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn3[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 1;
		end
	end

	else if(o_branchInstruction[3] || o_jumpInstruction[3] || o_jrInstruction[3])	//fourth instruction is branch//j
	begin
		o_branch_address <= i_pc+3;
		if(o_branchInstruction[3])
		begin
			o_isbranch <= 1;
			o_Branch_Target <= (i_pc+3) + 22'd1 + {{(ADDRESS_WIDTH-16){i_inst4[15]}},i_inst4[15:0]};
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(o_jrInstruction[3])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= i_pc+3; //junk data - pop address off stack
			o_jr_inst <= 1;
			o_jal_inst <= 0;
			o_j_inst <= 0;
		end
		else if(jalInstruction[3])
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn4[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 1;
			o_j_inst <= 0;
		end
		else	//j
		begin
			o_isbranch <= 0;
			o_Branch_Target <= o_isn4[21:0];
			o_jr_inst <= 0;
			o_jal_inst <= 0;
			o_j_inst <= 1;
		end
	end

	else				//no branches/j
	begin
		o_branch_address <= i_pc;
		o_isbranch <= 0;
		o_Branch_Target <= 0;
		o_jr_inst <= 0;
		o_jal_inst <= 0;
		o_j_inst <= 0;
	end
end

endmodule
