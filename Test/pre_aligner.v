module pre_aligner	#(
					parameter ADDRESS_WIDTH = 22,
					parameter DATA_WIDTH = 32
				)
				(	// Inputs
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
					output reg o_delay_slot,		//if 4th slot is branch/jump notify fetch of delay slot in next bunch

					//Output - to jump stack, fetch
					output reg o_j_inst,
					output reg o_jal_inst,
					output reg o_jr_inst
				);

reg [DATA_WIDTH-1:0] o_isn1;
reg [DATA_WIDTH-1:0] o_isn2;
reg [DATA_WIDTH-1:0] o_isn3;
reg [DATA_WIDTH-1:0] o_isn4;

wire [3:0] branchInstruction;
wire [3:0] jalInstruction;
wire [3:0] jumpInstruction;
wire [3:0] jrInstruction;

reg in1st, in2nd, in3rd, in4th;

reg [3:0] o_branchInstruction;
reg [3:0] o_jalInstruction;
reg [3:0] o_jumpInstruction;
reg [3:0] o_jrInstruction;

wire opcode_0 = i_inst1[31:29];		//first 3 bits of instruction opcode (000 for branch)
wire opcodeA_0 = i_inst1[28];			//next 3 bits of opcode
wire opcodeB_0 = i_inst1[27];
wire opcodeC_0 = i_inst1[26];
wire fncode_0 = i_inst1[5:0];

wire opcode_1 = i_inst2[31:29];		//first 3 bits of instruction opcode (000 for branch)
wire opcodeA_1 = i_inst2[28];			//next 3 bits of opcode
wire opcodeB_1 = i_inst2[27];
wire opcodeC_1 = i_inst2[26];
wire fncode_1 = i_inst2[5:0];

wire opcode_2 = i_inst3[31:29];		//first 3 bits of instruction opcode (000 for branch)
wire opcodeA_2 = i_inst3[28];			//next 3 bits of opcode
wire opcodeB_2 = i_inst3[27];
wire opcodeC_2 = i_inst3[26];
wire fncode_2 = i_inst3[5:0];

wire opcode_3 = i_inst4[31:29];		//first 3 bits of instruction opcode (000 for branch)
wire opcodeA_3 = i_inst4[28];			//next 3 bits of opcode
wire opcodeB_3 = i_inst4[27];
wire opcodeC_3 = i_inst4[26];
wire fncode_3 = i_inst4[5:0];

wire WTF = !opcode_1 && (!opcodeA_1 && opcodeB_1 && opcodeC_1);

assign branchInstruction[0] = !opcode_0 && (opcodeA_0 || (!opcodeB_0 &&  opcodeC_0));	//1 if branch instruction
assign branchInstruction[1] = !opcode_1 && (opcodeA_1 || (!opcodeB_1 &&  opcodeC_1));	//1 if branch instruction
assign branchInstruction[2] = !opcode_2 && (opcodeA_2 || (!opcodeB_2 &&  opcodeC_2));	//1 if branch instruction
assign branchInstruction[3] = !opcode_3 && (opcodeA_3 || (!opcodeB_3 &&  opcodeC_3));	//1 if branch instruction

assign jalInstruction[0] = !opcode_0 && (!opcodeA_0 && opcodeB_0 && opcodeC_0);	//1 if jal instruction
assign jalInstruction[1] = !opcode_1 && (!opcodeA_1 && opcodeB_1 && opcodeC_1);	//1 if jal instruction
assign jalInstruction[2] = !opcode_2 && (!opcodeA_2 && opcodeB_2 && opcodeC_2);	//1 if jal instruction
assign jalInstruction[3] = !opcode_3 && (!opcodeA_3 && opcodeB_3 && opcodeC_3);	//1 if jal instruction

assign jumpInstruction[0] = !opcode_0 && (!opcodeA_0 && opcodeB_0);	//1 if jal or j instruction
assign jumpInstruction[1] = !opcode_1 && (!opcodeA_1 && opcodeB_1);	//1 if jal or j instruction
assign jumpInstruction[2] = !opcode_2 && (!opcodeA_2 && opcodeB_2);	//1 if jal or j instruction
assign jumpInstruction[3] = !opcode_3 && (!opcodeA_3 && opcodeB_3);	//1 if jal or j instruction

assign jrInstruction[0] = !{opcode_0,opcodeA_0,opcodeB_0,opcodeC_0} && fncode_0 == 01000;	//1 if jr instruction
assign jrInstruction[1] = !{opcode_1,opcodeA_1,opcodeB_1,opcodeC_1} && fncode_1 == 01000;	//1 if jr instruction
assign jrInstruction[2] = !{opcode_2,opcodeA_2,opcodeB_2,opcodeC_2} && fncode_2 == 01000;	//1 if jr instruction
assign jrInstruction[3] = !{opcode_3,opcodeA_3,opcodeB_3,opcodeC_3} && fncode_3 == 01000;	//1 if jr instruction

reg WTF2;

always@(*)
begin
   WTF2 = 0;
	in1st = 0;
	in2nd = 0;
	in3rd = 0;
	in4th = 0;
	o_branch_address = 0;
	o_isbranch = 0;
	o_Branch_Target = 0;
	o_jr_inst = 0;
	o_jal_inst = 0;
	o_j_inst = 0;
	case(i_pc[1:0])
		0:
		begin
			o_isn1 = i_inst1;
			o_isn2 = i_inst2;
			o_isn3 = i_inst3;
			o_isn4 = i_inst4;
			o_branchInstruction = branchInstruction;
			o_jalInstruction = jalInstruction;
			o_jumpInstruction = jumpInstruction;
			o_jrInstruction = jrInstruction;
		end

		1:
		begin
			o_isn1 = i_inst2;
			o_isn2 = i_inst3;
			o_isn3 = i_inst4;
			o_isn4 = 0;
			o_branchInstruction = branchInstruction >> 1;
			o_jalInstruction = jalInstruction >> 1;
			o_jumpInstruction = jumpInstruction >> 1;
			o_jrInstruction = jrInstruction >> 1;
		end

		2:
		begin
			o_isn1 = i_inst3;
			o_isn2 = i_inst4;
			o_isn3 = 0;
			o_isn4 = 0;
			o_branchInstruction = branchInstruction >> 2;
			o_jalInstruction = jalInstruction >> 2;
			o_jumpInstruction = jumpInstruction >> 2;
			o_jrInstruction = jrInstruction >> 2;
		end

		3:
		begin
			o_isn1 = i_inst4;
			o_isn2 = 0;
			o_isn3 = 0;
			o_isn4 = 0;
			o_branchInstruction = branchInstruction >> 3;
			o_jalInstruction = jalInstruction >> 3;
			o_jumpInstruction = jumpInstruction >> 3;
			o_jrInstruction = jrInstruction >> 3;
		end
	endcase

	if(o_branchInstruction[0] || o_jumpInstruction[0] || o_jrInstruction[0])		//first instruction is branch/j
	begin
		in1st = 1;
		o_delay_slot = 0;
		o_branch_address = i_pc;
		if(o_branchInstruction[0])
		begin
			o_isbranch = 1;
			o_Branch_Target = i_pc + 22'd1 + {{(ADDRESS_WIDTH-16){o_isn1[15]}},o_isn1[15:0]};
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jrInstruction[0])
		begin
			o_isbranch = 0;
			o_Branch_Target = i_pc; //junk data - pop address off stack
			o_jr_inst = 1;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jalInstruction[0])
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn1[21:0];
			o_jr_inst = 0;
			o_jal_inst = 1;
			o_j_inst = 0;
		end
		else	//j
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn1[21:0];
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 1;
			WTF2 = 1;
		end
	end

	else if(o_branchInstruction[1] || o_jumpInstruction[1] || o_jrInstruction[1])	//second instruction is branch/j
	begin
		in2nd = 1;
		o_delay_slot = 0;
		o_branch_address = i_pc+1;
		if(o_branchInstruction[1])
		begin
			o_isbranch = 1;
			o_Branch_Target = (i_pc+1) + 22'd1 + {{(ADDRESS_WIDTH-16){o_isn2[15]}},o_isn2[15:0]};
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jrInstruction[1])
		begin
			o_isbranch = 0;
			o_Branch_Target = i_pc; //junk data - pop address off stack
			o_jr_inst = 1;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jalInstruction[1])
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn2[21:0];
			o_jr_inst = 0;
			o_jal_inst = 1;
			o_j_inst = 0;
		end
		else	//j
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn2[21:0];
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 1;
		end
	end

	else if(o_branchInstruction[2] || o_jumpInstruction[2] || o_jrInstruction[2])	//third instruction is branch/j
	begin
		in3rd = 1;
		o_delay_slot = 0;
		o_branch_address = i_pc+2;
		if(o_branchInstruction[2])
		begin
			o_isbranch = 1;
			o_Branch_Target = (i_pc+2) + 22'd1 + {{(ADDRESS_WIDTH-16){o_isn3[15]}},o_isn3[15:0]};
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jrInstruction[2])
		begin
			o_isbranch = 0;
			o_Branch_Target = i_pc+2; //junk data - pop address off stack
			o_jr_inst = 1;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jalInstruction[2])
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn3[21:0];
			o_jr_inst = 0;
			o_jal_inst = 1;
			o_j_inst = 0;
		end
		else	//j
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn3[21:0];
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 1;
		end
	end

	else if(o_branchInstruction[3] || o_jumpInstruction[3] || o_jrInstruction[3])	//fourth instruction is branch//j
	begin
		in4th = 1;
		o_delay_slot = 1;
		o_branch_address = i_pc+3;
		if(o_branchInstruction[3])
		begin
			o_isbranch = 1;
			o_Branch_Target = (i_pc+3) + 22'd1 + {{(ADDRESS_WIDTH-16){o_isn4[15]}},o_isn4[15:0]};
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jrInstruction[3])
		begin
			o_isbranch = 0;
			o_Branch_Target = i_pc+3; //junk data - pop address off stack
			o_jr_inst = 1;
			o_jal_inst = 0;
			o_j_inst = 0;
		end
		else if(o_jalInstruction[3])
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn4[21:0];
			o_jr_inst = 0;
			o_jal_inst = 1;
			o_j_inst = 0;
		end
		else	//j
		begin
			o_isbranch = 0;
			o_Branch_Target = o_isn4[21:0];
			o_jr_inst = 0;
			o_jal_inst = 0;
			o_j_inst = 1;
		end
	end

	else				//no branches/j
	begin
		o_branch_address = i_pc;
		o_isbranch = 0;
		o_Branch_Target = 0;
		o_jr_inst = 0;
		o_jal_inst = 0;
		o_j_inst = 0;
	end
end

endmodule
