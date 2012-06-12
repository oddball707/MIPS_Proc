/* mips_cpu.v
* Author: Pravin P. Prabhu
* Last Revision: 1/5/11
* Abstract:
*	The top level module for the MIPS32 processor. This is a classic 5-stage
* MIPS pipeline architecture which is intended to follow heavily from the model
* presented in Hennessy and Patterson's Computer Organization and Design.
*/
module mips_cpu(// General
				input CLOCK_50,	//These inputs are all pre-defined input/output pin names
				//input Global_Reset_n,		// TEMP - Remove this after testing
				input [3:0] KEY,	// which correspond to the DE2_pin_assignments,csv file.  This
				input [17:0] SW,	// way, the mapping is automatically taken care of if we get the
				output [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, // name right.
				output [7:0] LEDG,
				output [17:0] LEDR,

				//SDRAM interface
				output [11:0] DRAM_ADDR,
				output DRAM_BA_0,
				output DRAM_BA_1,
				output DRAM_CAS_N,
				output DRAM_CKE,
				output DRAM_CLK,
				output DRAM_CS_N,
				inout [15:0] DRAM_DQ,
				output DRAM_LDQM,
				output DRAM_UDQM,
				output DRAM_RAS_N,
				output DRAM_WE_N,

				//Flash RAM interface
				output [21:0] FL_ADDR,
				inout [7:0] FL_DQ,
				output FL_CE_N,
				output FL_OE_N,
				output FL_RST_N,
				output FL_WE_N,

				 //SRAM interface
				output [17:0] SRAM_ADDR,
				inout [15:0] SRAM_DQ,
				output SRAM_UB_N,
				output SRAM_LB_N,
				output SRAM_WE_N,
				output SRAM_OE_N,
				output SRAM_CE_N
			);

//===================================================================
//	Internal Wiring
//===================================================================

//===================================================================
// General Signals
localparam FALSE = 1'b0;
localparam TRUE = 1'b1;
localparam ADDRESS_WIDTH = 22;
localparam DATA_WIDTH = 32;
localparam STACK_SIZE = 16;
localparam GHR_SIZE = 8;
//wire Global_Reset_n;			// Global reset
wire Global_Reset_n = KEY[0];

	// MTC0 codes - Did we pass/fail a test or reach the done state?
localparam MTC0_NOOP = 0;		// No significance
localparam MTC0_PASS = 1;			// Passed a test
localparam MTC0_FAIL = 2;		// Failed a test
localparam MTC0_DONE = 3;			// Have completed execution

assign LEDG[7:1] = 0;
assign LEDR[17:1] = 0;

assign SRAM_ADDR = 0;
assign SRAM_UB_N = 0;
assign SRAM_LB_N = 0;
assign SRAM_WE_N = 0;
assign SRAM_OE_N = 0;
assign SRAM_CE_N = 0;

//===================================================================
// IFetch Signals

wire IFetch_i_Flush;			// Flush for IFetch
wire Hazard_Stall_IF;				// Stall for IFetch
wire IFetch_i_Load;			// Load signal - if high, load pc with vector
wire [ADDRESS_WIDTH-1:0] IFetch_i_PCSrc;	// Vector to branch to

wire [ADDRESS_WIDTH-1:0] IMEM_i_Address;	// Current PC


wire IMEM_o_Ready;
wire IMEM_o_Valid;
wire [4*DATA_WIDTH-1:0] IMEM_o_Instruction;
wire [DATA_WIDTH-1:0] IMEM_o_Instruction1 = IMEM_o_Instruction[DATA_WIDTH-1:0];

					// Outputs - to branch predictor
wire PA_o_isbranch;
wire [ADDRESS_WIDTH-1:0] PA_o_branch_address;

					//Output - to Fetch
wire [ADDRESS_WIDTH-1:0] PA_o_branch_target;

					//Output - to jump stack, fetch
wire PA_o_j_inst;
wire PA_o_jal_inst;
wire PA_o_jr_inst;
wire PA_o_delay_slot;

wire [ADDRESS_WIDTH-1:0] JS_o_address;

wire BP_o_prediction;

	//==============
	// Pipe signals: IF->ID
wire Hazard_Flush_IF;			// 1st pipe flush
wire Hazard_Stall_DEC;		// 1st pipe stall

//===================================================================
// Decoder Signals
localparam ALU_CTLCODE_WIDTH = 8;
localparam REG_ADDR_WIDTH = 5;
localparam MEM_MASK_WIDTH = 3;
wire [ADDRESS_WIDTH-1:0] DEC_i_PC;					// PC of inst
wire [DATA_WIDTH-1:0] DEC_i_Instruction;				// Inst into decode
wire DEC_Noop = (DEC_i_Instruction != 32'd0);

wire DEC_o_Uses_ALU;
wire [ALU_CTLCODE_WIDTH-1:0] DEC_o_ALUCTL;			// ALU control code
wire DEC_o_Is_Branch;									// If it's a branch
wire [ADDRESS_WIDTH-1:0] DEC_o_Branch_Target;		// Where we will branch to
wire DEC_o_Jump_Reg;									// If this is a special case where we jump TO a register value

wire DEC_o_Mem_Valid;
wire DEC_o_Mem_Read_Write_n;
wire [MEM_MASK_WIDTH-1:0] DEC_o_Mem_Mask;			// Used for masking individual memory ops - such as byte and halfword transactions

wire DEC_o_Writes_Back;
wire [REG_ADDR_WIDTH-1:0] DEC_o_Write_Addr;
wire DEC_o_Uses_RS;
wire [REG_ADDR_WIDTH-1:0] DEC_o_Read_Register_1;
wire DEC_o_Uses_RT;
wire [REG_ADDR_WIDTH-1:0] DEC_o_Read_Register_2;

wire [DATA_WIDTH-1:0] DEC_o_Read_Data_1;
wire [DATA_WIDTH-1:0] DEC_o_Read_Data_2;

wire DEC_o_Uses_Immediate;
wire [DATA_WIDTH-1:0] DEC_o_Immediate;

wire [DATA_WIDTH-1:0] FORWARD_o_Forwarded_Data_1,FORWARD_o_Forwarded_Data_2;	// Looked up regs

	//==============
	// Pipe signals: ID->EX
wire Hazard_Flush_DEC;		// 2nd pipe flush
wire Hazard_Stall_EX;			// 2nd pipe stall

wire [ADDRESS_WIDTH-1:0] DEC_o_PC;
assign DEC_o_PC = DEC_i_PC;

//===================================================================
// Execute Signals

wire [ADDRESS_WIDTH-1:0] ALU_i_PC;

wire EX_i_Is_Branch;
wire EX_i_Mem_Valid;
wire [MEM_MASK_WIDTH-1:0] EX_i_Mem_Mask;
wire EX_i_Mem_Read_Write_n;
wire [DATA_WIDTH-1:0] EX_i_Mem_Write_Data;
wire EX_i_Writes_Back;
wire [REG_ADDR_WIDTH-1:0] EX_i_Write_Addr;

wire ALU_i_Valid;										// Whether input to ALU is valid or not
wire ALU_o_Valid;
wire [ALU_CTLCODE_WIDTH-1:0] ALU_i_ALUOp;					// Control bus to ALU
wire [DATA_WIDTH-1:0] ALU_i_Operand1,ALU_i_Operand2;	// Ops for ALU
wire [ADDRESS_WIDTH-1:0] EX_i_Branch_Target;
wire [DATA_WIDTH-1:0] ALU_o_Result;							// Computation of ALU
wire ALU_o_Branch_Valid;								// Whether branch is valid or not
wire ALU_o_Branch_Outcome;									// Whether branch is taken or not
wire [15:0] ALU_o_Pass_Done_Value;						// reports the value of a PASS/FAIL/DONE instruction
wire [1:0] ALU_o_Pass_Done_Change;							// indicates the above signal is meaningful
															// 1 = pass, 2 = fail, 3 = done

	// Cumulative signals
wire EX_Take_Branch = ALU_o_Valid && ALU_o_Branch_Valid && ALU_o_Branch_Outcome;		// Whether we should branch or not.

	//==============
	// Pipe signals: EX->MEM
wire Hazard_Flush_EX;		// 3rd pipe flush
wire Hazard_Stall_MEM;			// 3rd pipe stall


//===================================================================
// Memory Signals
wire [DATA_WIDTH-1:0] DMEM_i_Result;					// Result from the ALU
wire [DATA_WIDTH-1:0] DMEM_i_Mem_Write_Data;		// What we will write back to mem (if applicable)
wire DMEM_i_Mem_Valid;								// If the memory operation is valid
wire [MEM_MASK_WIDTH-1:0] DMEM_i_Mem_Mask;		// Mem mask for sub-word operations
wire DMEM_i_Mem_Read_Write_n;					// Type of memop
wire DMEM_i_Writes_Back;								// If the result should be written back to regfile
wire [REG_ADDR_WIDTH-1:0] DMEM_i_Write_Addr;		// Which reg in the regfile to write to
wire [DATA_WIDTH-1:0] DMEM_o_Read_Data;				// The data READ from DMEM
wire DMEM_o_Mem_Ready;							// If the DMEM is ready to service another request
wire DMEM_o_Mem_Valid;								// If the value read from DMEM is valid
reg DMEM_o_Done;									// If MEM's work is finalized
reg [DATA_WIDTH-1:0] DMEM_o_Write_Data;				// Data we should write back to regfile

wire MemToReg = DMEM_i_Mem_Valid;			// Selects what we will write back -- mem or ALU result

	//==============
	// Pipe signals: MEM->WB
wire Hazard_Flush_MEM;		// 4th pipe flush
wire Hazard_Stall_WB;	// 4th pipe stall


//===================================================================
// Write-Back Signals
wire WB_i_Writes_Back;							// If we will write back
wire [REG_ADDR_WIDTH-1:0] DEC_i_Write_Register;			// Where we will write back to
wire [DATA_WIDTH-1:0] WB_i_Write_Data;			// What we will write back
wire Hazard_Flush_WB;									// Request to squash WB contents

wire DEC_i_RegWrite = WB_i_Writes_Back && !Hazard_Flush_WB;

//===================================================================
// Flash Signals
wire o_FlashLoader_Done;						// Raised when the loader finishes
wire o_FlashLoader_SDRAM_Read_Write_n;		// FlashLoader's actual request to dmem
wire o_FlashLoader_SDRAM_Req_Valid;				// FlashLoader's verification of request to dmem
wire [ADDRESS_WIDTH-1:0] o_FlashLoader_SDRAM_Addr;		// FlashLoader's request addrto dmem
wire [DATA_WIDTH-1:0] o_FlashLoader_SDRAM_Data;			// FlashLoader's output data
wire i_FlashLoader_SDRAM_Data_Read;			// FlashLoader's input callback from dmem
wire i_FlashLoader_SDRAM_Last;					// ""
wire [21:0] o_FlashLoader_FL_Addr;			// FlashLoader's addr request to flash
wire [7:0] i_FlashLoader_FL_Data;				// FlashLoader's data coming back from flash
wire o_FlashLoader_FL_Chip_En_n;			// FlashLoader's chip enable to flash
wire o_FlashLoader_FL_Output_En_n;				// "" (output enable)
wire o_FlashLoader_FL_Reset_n;				// "" (flash reset)
wire o_FlashLoader_FL_Write_En_n;				// Write enable going out to flash

	// Top level connections
assign FL_ADDR = o_FlashLoader_FL_Addr;					// Addr we're requesting to deal with
assign i_FlashLoader_FL_Data = FL_DQ;						// Incoming data from flash (for reads)
assign FL_CE_N = o_FlashLoader_FL_Chip_En_n;			// Flash chip enable
assign FL_OE_N = o_FlashLoader_FL_Output_En_n;				// Flash output enable
assign FL_WE_N = o_FlashLoader_FL_Write_En_n;			// Flash write enable
assign FL_RST_N	= o_FlashLoader_FL_Reset_n;					// Flash reset


//===================================================================
// Arbiter Signals
wire Arbiter_i_IMEM_Valid;
wire [ADDRESS_WIDTH-1:0] Arbiter_i_IMEM_Address;
wire Arbiter_o_IMEM_Valid;
wire Arbiter_o_IMEM_Last;
wire [DATA_WIDTH-1:0] Arbiter_o_IMEM_Data;

wire Arbiter_i_DMEM_Valid;
wire Arbiter_i_DMEM_Read_Write_n;
wire [ADDRESS_WIDTH-1:0] Arbiter_i_DMEM_Address;
wire [DATA_WIDTH-1:0] Arbiter_i_DMEM_Data;
wire [DATA_WIDTH-1:0] Arbiter_o_DMEM_Data;
wire Arbiter_o_DMEM_Data_Read;
wire Arbiter_o_DMEM_Valid;
wire Arbiter_o_DMEM_Last;

wire Arbiter_i_Flash_Valid;
wire [DATA_WIDTH-1:0] Arbiter_i_Flash_Data;
wire [ADDRESS_WIDTH-1:0] Arbiter_i_Flash_Address;
wire Arbiter_o_Flash_Data_Read;
//wire [DATA_WIDTH-1:0] Arbiter_o_Flash_Data_Read;
wire Arbiter_o_Flash_Last;

assign Arbiter_i_Flash_Valid = o_FlashLoader_SDRAM_Req_Valid;
assign Arbiter_i_Flash_Data = o_FlashLoader_SDRAM_Data;
assign Arbiter_i_Flash_Address = o_FlashLoader_SDRAM_Addr;
assign i_FlashLoader_SDRAM_Data_Read = Arbiter_o_Flash_Data_Read;
assign i_FlashLoader_SDRAM_Last = Arbiter_o_Flash_Last;


//====================================================================
// Controller Signals
wire [ADDRESS_WIDTH-1:0] SDRAM_i_Address;				// Transact address
wire SDRAM_i_Valid;									// If request is valid
wire SDRAM_i_Read_Write_n;								// Request type

wire [DATA_WIDTH-1:0] SDRAM_i_Data;					// What to write
wire SDRAM_o_Data_Read;									// If data was read or not

wire [DATA_WIDTH-1:0] SDRAM_o_Data;					// Read in data from SDRAM
wire SDRAM_o_Data_Valid;								// If read in data is valid

wire SDRAM_o_Last;									// If we're on the last part of the burst


wire i_Clk;
//===================================================================
// Top-level Connections
	// Clock handling for mem & processor
wire Done = (ALU_o_Pass_Done_Change == MTC0_DONE);
wire Local_Clock;
wire Internal_Reset_n;

`ifdef MODEL_TECH
assign Internal_Reset_n = Global_Reset_n;
assign Local_Clock = CLOCK_50;

`else
wire PLL_Locked;
pll my_pll(
	.areset(!Global_Reset_n),
	.inclk0(CLOCK_50),
	.c0(Local_Clock),
	.locked(PLL_Locked)
	);
assign Internal_Reset_n = PLL_Locked && Global_Reset_n;

`endif

assign i_Clk = Local_Clock;

// Performance metrics
reg [31:0] CycleCount;					// # of cycles that have passed since reset
reg [31:0] InstructionsExecuted;	// # of insts that have went through WB stage since reset

always @(posedge i_Clk or negedge Internal_Reset_n)
begin
	if( !Internal_Reset_n )
	begin
		// Asynch. reset on counters
		CycleCount <= 32'b0;
		InstructionsExecuted <= 32'b0;
	end
	else
	begin
		// If we're currently executing instructions...
		if( o_FlashLoader_Done && !Done )
		begin
			// If we have a valid instruction that is finishing up execution in Decode, then count it
			if( !Hazard_Stall_DEC && !Hazard_Flush_DEC && !DEC_Noop )
				InstructionsExecuted <= InstructionsExecuted + 32'b1;
			CycleCount <= CycleCount + 32'b1;	// Always count another cycle
		end
	end
end

	// Visual output
assign LEDG[0] = (Done);
assign LEDR[0] = (!Done);

reg[3:0] HEX_Buf [7:0];	// Buffers for visualization of data

always @(posedge i_Clk)
begin
	HEX_Buf[0] <= 4'd0;
	HEX_Buf[1] <= 4'd0;
	HEX_Buf[2] <= 4'd0;
	HEX_Buf[3] <= 4'd0;
	HEX_Buf[4] <= 4'd0;
	HEX_Buf[5] <= 4'd0;
	HEX_Buf[6] <= 4'd0;
	HEX_Buf[7] <= 4'd0;

	case(SW[1:0])
		2'd0:	// Default: Display Pass/Done/Fail, PC, and PDF Value information
		begin
			HEX_Buf[0] <= ALU_o_Pass_Done_Value[3:0];
			HEX_Buf[1] <= ALU_o_Pass_Done_Value[7:4];
			HEX_Buf[6] <= IMEM_i_Address[3:0];
			HEX_Buf[7] <= IMEM_i_Address[7:4];
		end

		2'd1:	// Cycle Count
		begin
			HEX_Buf[0] <= CycleCount[3:0];
			HEX_Buf[1] <= CycleCount[7:4];
			HEX_Buf[2] <= CycleCount[11:8];
			HEX_Buf[3] <= CycleCount[15:12];
			HEX_Buf[4] <= CycleCount[19:16];
			HEX_Buf[5] <= CycleCount[23:20];
			HEX_Buf[6] <= CycleCount[27:24];
			HEX_Buf[7] <= CycleCount[31:28];
		end

		2'd2:	// Instructions Executed
		begin
			HEX_Buf[0] <= InstructionsExecuted[3:0];
			HEX_Buf[1] <= InstructionsExecuted[7:4];
			HEX_Buf[2] <= InstructionsExecuted[11:8];
			HEX_Buf[3] <= InstructionsExecuted[15:12];
			HEX_Buf[4] <= InstructionsExecuted[19:16];
			HEX_Buf[5] <= InstructionsExecuted[23:20];
			HEX_Buf[6] <= InstructionsExecuted[27:24];
			HEX_Buf[7] <= InstructionsExecuted[31:28];
		end

		2'd3: // (free for any other metric)
		begin
		end

	endcase
end

wire [6:0] HEX2_SSD, HEX2_PFD;
SevenSegmentDisplayDecoder SSD0 (i_Clk, HEX0, HEX_Buf[0]);
SevenSegmentDisplayDecoder SSD1 (i_Clk, HEX1, HEX_Buf[1]);
SevenSegmentDisplayDecoder SSD2 (i_Clk, HEX2_SSD, HEX_Buf[2]);
SevenSegmentDisplayDecoder SSD3 (i_Clk, HEX3, HEX_Buf[3]);
SevenSegmentDisplayDecoder SSD4 (i_Clk, HEX4, HEX_Buf[4]);
SevenSegmentDisplayDecoder SSD5 (i_Clk, HEX5, HEX_Buf[5]);
SevenSegmentDisplayDecoder SSD6 (i_Clk, HEX6, HEX_Buf[6]);
SevenSegmentDisplayDecoder SSD7 (i_Clk, HEX7, HEX_Buf[7]);
SevenSegmentPFD PFD2 (i_Clk, HEX2_PFD, ALU_o_Pass_Done_Change);	// display pass/done/fail status

	// Special case: If SW is 0, then HEX2 output comes from PFD. Else, comes from SSD.
assign HEX2 = (SW[1:0]==2'd0 ? HEX2_PFD : HEX2_SSD);

/*
SevenSegmentPFD SSD3 (i_Clk, HEX2, ALU_o_Pass_Done_Change);	// display pass/done/fail status

SevenSegmentDisplayDecoder SSD0 (i_Clk, HEX0, ALU_o_Pass_Done_Value[3:0]);
SevenSegmentDisplayDecoder SSD1 (i_Clk, HEX1, ALU_o_Pass_Done_Value[7:4]);

SevenSegmentDisplayDecoder SSD7 (i_Clk, HEX7, IMEM_i_Address[7:4]);
SevenSegmentDisplayDecoder SSD6 (i_Clk, HEX6, IMEM_i_Address[3:0]);

*/

//===================================================================
//	Structural Description - Overhead
//===================================================================


//===================================================================
//	Structural Description - Pipeline stages
//===================================================================

//===================================================================
//	Instruction Fetch
fetch_unit #(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
				.DATA_WIDTH(DATA_WIDTH)
				)
				IFETCH
				(	// Inputs
					.i_Clk(i_Clk),
					.i_Reset_n(Internal_Reset_n),
					.i_Stall(Hazard_Stall_IF),

					.i_branch_taken(BP_o_prediction),		//from branch predictor
					.i_jump_inst(PA_o_j_inst | PA_o_jal_inst),			//from pre-align
					.i_jr_inst(PA_o_jr_inst),			//from pre-align
					.i_branch_inst(PA_o_isbranch),
					.i_branch_mispredict(0),	//from hazard detection/EX [first bit - if mispredicted, second if taken, 3rd/4th bits for thread]
					.i_thread_choice(0),		//which thread to take from - from Queue

					//The next address possibilities,
					//normal execution - PC + (4- PC%4)							//local information
					.i_current_target(PA_o_branch_target),			//from Pre-Aligner
					.i_mispredict_nottaken(0),	//from EX, target of mispredicted branch
					.i_mispredict_pc(22'b0),			//from EX, pc of mispredicted branch
					.i_jstack_jrtarget(22'b0),		//from jump stack, address for jr

					// Outputs
					.o_PC(IMEM_i_Address)
				);

// fetch_unit #(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
// 				.DATA_WIDTH(DATA_WIDTH)
// 				)
// 				IFETCH
// 				(	// Inputs
// 					.i_Clk(i_Clk),
// 					.i_Reset_n(Internal_Reset_n),
// 					.i_Stall(Hazard_Stall_IF),

// 					.i_Load(IFetch_i_Load),
// 					.i_Load_Address(IFetch_i_PCSrc),

// 					// Outputs
// 					.o_PC(IMEM_i_Address)
// 				);


i_cache	#(	.DATA_WIDTH(DATA_WIDTH)
		)
		I_CACHE
		(
			// General
			.i_Clk(i_Clk),
			.i_Reset_n(Internal_Reset_n),

			// Requests
			.i_Valid(o_FlashLoader_Done),
			.i_Address(IMEM_i_Address),

			// Mem Transaction
			.o_MEM_Valid(Arbiter_i_IMEM_Valid),
			.o_MEM_Address(Arbiter_i_IMEM_Address),
			.i_MEM_Valid(Arbiter_o_IMEM_Valid),		// If data from main mem is valid
			.i_MEM_Last(Arbiter_o_IMEM_Last),			// If main mem is sending the last piece of data
			.i_MEM_Data(Arbiter_o_IMEM_Data),		// Data from main mem

			// Outputs
			.o_Ready(IMEM_o_Ready),
			.o_Valid(IMEM_o_Valid),					// If the output is correct.
			.o_Data(IMEM_o_Instruction)					// The data requested.
		);

pre_aligner	#(
					.ADDRESS_WIDTH(ADDRESS_WIDTH),
					.DATA_WIDTH(DATA_WIDTH)
				)
				PRE_ALIGNER
				(	// Inputs

					//from I_CACHE
					.i_pc(IMEM_i_Address),			//of first instruction (i_inst1)
					.i_inst1(IMEM_o_Instruction[DATA_WIDTH-1:0]),
					.i_inst2(IMEM_o_Instruction[2*DATA_WIDTH-1:DATA_WIDTH]),
					.i_inst3(IMEM_o_Instruction[3*DATA_WIDTH-1:2*DATA_WIDTH]),
					.i_inst4(IMEM_o_Instruction[4*DATA_WIDTH-1:3*DATA_WIDTH]),

					// Outputs - to branch predictor
					.o_isbranch(PA_o_isbranch),
					.o_branch_address(PA_o_branch_address),

					//Output - to Fetch
					.o_Branch_Target(PA_o_branch_target),

					//Output - to jump stack, fetch
					.o_j_inst(PA_o_j_inst),
					.o_jal_inst(PA_o_jal_inst),
					.o_jr_inst(PA_o_jr_inst),
					.o_delay_slot(PA_o_delay_slot)
				);


jump_stack	#(
					.DATA_WIDTH(DATA_WIDTH),
					.ADDRESS_WIDTH(ADDRESS_WIDTH),
					.STACK_SIZE(STACK_SIZE)
				)
				JUMP_STACK
				(
					.i_Clk(i_Clk),
					.i_Reset_n(Internal_Reset_n),

					////Inputs from pre-align
					.i_address(IMEM_i_Address),	//address in memory (for hash)
					.i_thread(2'b00),					//to choose which thread to use
					.i_pop(PA_o_jr_inst),							//push if jal - 0, pop if jr - 1
					.i_push(PA_o_jal_inst),							//1 if jal or jr, 0 otherwise

					.o_address(JS_o_address)	//popped value - if jr
				);

branch_predictor #(
					.DATA_WIDTH(DATA_WIDTH),
					.ADDRESS_WIDTH(ADDRESS_WIDTH),
					.GHR_SIZE(GHR_SIZE)
				)
				BRANCH_PREDICTOR
				(
					////Inputs from current stage
					.i_Clk(i_Clk),
					.i_Reset_n(Internal_Reset_n),
					.i_Stall(Hazard_Stall_IF),

					.i_IMEM_address(IMEM_i_Address),	//address in memory (for hash)

					////Inputs from ALU stage
					.i_isbranch_check(PA_o_isbranch),					//don't want to update tables for a non-branch
					.i_ALU_outcome(0),					//1 if taken 0 not taken (from ALU computation)
					.i_ALU_pc(22'b0),			//pc from branch in ALU stage
					.i_ALU_isbranch(0),					//if inst in ALU stage is a branch
					.i_ALU_prediction(0),					//prediction for branch in ALU

					.o_taken(BP_o_prediction)						//prediction
				);


//===================================================================
//	Decode
pipe_if_dec	#(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
				.DATA_WIDTH(DATA_WIDTH)
			)
			PIPE_IF_DEC
			(		// Inputs
				.i_Clk(i_Clk),
				.i_Reset_n(Internal_Reset_n),
				.i_Flush(Hazard_Flush_IF),
				.i_Stall(Hazard_Stall_DEC),

					// Pipe signals
				.i_PC(IMEM_i_Address),
				.o_PC(DEC_i_PC),
				.i_Instruction(IMEM_o_Instruction1),
				.o_Instruction(DEC_i_Instruction)
			);

decoder #(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
			.DATA_WIDTH(DATA_WIDTH),
			.REG_ADDRESS_WIDTH(REG_ADDR_WIDTH),
			.ALUCTL_WIDTH(ALU_CTLCODE_WIDTH),
			.MEM_MASK_WIDTH(MEM_MASK_WIDTH)
		)
		DECODE
		(		// Inputs
			.i_PC(DEC_i_PC),
			.i_Instruction(DEC_i_Instruction),
			.i_Stall(Hazard_Stall_DEC),

				// Outputs
			.o_Uses_ALU(DEC_o_Uses_ALU),
			.o_ALUCTL(DEC_o_ALUCTL),
			.o_Is_Branch(DEC_o_Is_Branch),
			.o_Jump_Reg(DEC_o_Jump_Reg),

			.o_Mem_Valid(DEC_o_Mem_Valid),
			.o_Mem_Read_Write_n(DEC_o_Mem_Read_Write_n),
			.o_Mem_Mask(DEC_o_Mem_Mask),

			.o_Writes_Back(DEC_o_Writes_Back),
			.o_Write_Addr(DEC_o_Write_Addr),

			.o_Uses_RS(DEC_o_Uses_RS),
			.o_RS_Addr(DEC_o_Read_Register_1),
			.o_Uses_RT(DEC_o_Uses_RT),
			.o_RT_Addr(DEC_o_Read_Register_2),
			.o_Uses_Immediate(DEC_o_Uses_Immediate),
			.o_Immediate(DEC_o_Immediate),
			.o_Branch_Target(DEC_o_Branch_Target)
		);


regfile #(	.DATA_WIDTH(DATA_WIDTH),
			.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
		)
		REGFILE
		(		// Inputs
			.i_Clk(i_Clk),

			.i_RS_Addr(DEC_o_Read_Register_1),
			.i_RT_Addr(DEC_o_Read_Register_2),

			.i_Write_Enable(DEC_i_RegWrite),	// Account for squashing WB stage
			.i_Write_Data(WB_i_Write_Data),
			.i_Write_Addr(DEC_i_Write_Register),

				// Outputs
			.o_RS_Data(DEC_o_Read_Data_1),
			.o_RT_Data(DEC_o_Read_Data_2)
		);

//===================================================================
//	Execute
pipe_dec_ex #(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
				.DATA_WIDTH(DATA_WIDTH),
				.REG_ADDR_WIDTH(REG_ADDR_WIDTH),
				.ALU_CTLCODE_WIDTH(ALU_CTLCODE_WIDTH),
				.MEM_MASK_WIDTH(MEM_MASK_WIDTH)
			)
			PIPE_DEC_EX
			(		// Inputs
				.i_Clk(i_Clk),
				.i_Reset_n(Internal_Reset_n),
				.i_Flush(Hazard_Flush_DEC),
				.i_Stall(Hazard_Stall_EX),

					// Pipeline
				.i_PC(DEC_o_PC),
				.o_PC(ALU_i_PC),
				.i_Uses_ALU(DEC_o_Uses_ALU),
				.o_Uses_ALU(ALU_i_Valid),
				.i_ALUCTL(DEC_o_ALUCTL),
				.o_ALUCTL(ALU_i_ALUOp),
				.i_Is_Branch(DEC_o_Is_Branch),
				.o_Is_Branch(EX_i_Is_Branch),
				.i_Mem_Valid(DEC_o_Mem_Valid),
				.o_Mem_Valid(EX_i_Mem_Valid),
				.i_Mem_Mask(DEC_o_Mem_Mask),
				.o_Mem_Mask(EX_i_Mem_Mask),
				.i_Mem_Read_Write_n(DEC_o_Mem_Read_Write_n),
				.o_Mem_Read_Write_n(EX_i_Mem_Read_Write_n),
				.i_Mem_Write_Data(FORWARD_o_Forwarded_Data_2),
				.o_Mem_Write_Data(EX_i_Mem_Write_Data),
				.i_Writes_Back(DEC_o_Writes_Back),
				.o_Writes_Back(EX_i_Writes_Back),
				.i_Write_Addr(DEC_o_Write_Addr),
				.o_Write_Addr(EX_i_Write_Addr),
				.i_Operand1(FORWARD_o_Forwarded_Data_1),
				.o_Operand1(ALU_i_Operand1),
				.i_Operand2(DEC_o_Uses_Immediate?DEC_o_Immediate:FORWARD_o_Forwarded_Data_2),		// Convention - Operand2 mapped to immediates
				.o_Operand2(ALU_i_Operand2),
				.i_Branch_Target(DEC_o_Jump_Reg?FORWARD_o_Forwarded_Data_1[ADDRESS_WIDTH-1:0]:DEC_o_Branch_Target),
				.o_Branch_Target(EX_i_Branch_Target)
			);

alu	#(	.DATA_WIDTH(DATA_WIDTH),
		.CTLCODE_WIDTH(ALU_CTLCODE_WIDTH)
	)
	ALU
	(		// Inputs
		.i_Valid(ALU_i_Valid),
		.i_ALUCTL(ALU_i_ALUOp),
		.i_Operand1(ALU_i_Operand1),
		.i_Operand2(ALU_i_Operand2),

			// Outputs
		.o_Valid(ALU_o_Valid),
		.o_Result(ALU_o_Result),
		.o_Branch_Valid(ALU_o_Branch_Valid),
		.o_Branch_Outcome(ALU_o_Branch_Outcome),
		.o_Pass_Done_Value(ALU_o_Pass_Done_Value),
		.o_Pass_Done_Change(ALU_o_Pass_Done_Change)
	);

//===================================================================
//	Mem
pipe_ex_mem #(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
				.DATA_WIDTH(DATA_WIDTH),
				.REG_ADDR_WIDTH(REG_ADDR_WIDTH),
				.ALU_CTLCODE_WIDTH(ALU_CTLCODE_WIDTH)
			)
			PIPE_EX_MEM
			(		// Inputs
				.i_Clk(i_Clk),
				.i_Reset_n(Internal_Reset_n),
				.i_Flush(Hazard_Flush_EX),
				.i_Stall(Hazard_Stall_MEM),

				// Pipe in/out
				.i_ALU_Result(ALU_o_Result),
				.o_ALU_Result(DMEM_i_Result),
				.i_Mem_Valid(EX_i_Mem_Valid),
				.o_Mem_Valid(DMEM_i_Mem_Valid),
				.i_Mem_Mask(EX_i_Mem_Mask),
				.o_Mem_Mask(DMEM_i_Mem_Mask),
				.i_Mem_Read_Write_n(EX_i_Mem_Read_Write_n),
				.o_Mem_Read_Write_n(DMEM_i_Mem_Read_Write_n),
				.i_Mem_Write_Data(EX_i_Mem_Write_Data),
				.o_Mem_Write_Data(DMEM_i_Mem_Write_Data),
				.i_Writes_Back(EX_i_Writes_Back),
				.o_Writes_Back(DMEM_i_Writes_Back),
				.i_Write_Addr(EX_i_Write_Addr),
				.o_Write_Addr(DMEM_i_Write_Addr)
			);

d_cache	#(
			.DATA_WIDTH(32),
			.MEM_MASK_WIDTH(3)
		)
		D_CACHE
		(	// Inputs
			.i_Clk(i_Clk),
			.i_Reset_n(Internal_Reset_n),
			.i_Valid(DMEM_i_Mem_Valid),
			.i_Mem_Mask(DMEM_i_Mem_Mask),
			.i_Address(DMEM_i_Result[ADDRESS_WIDTH:2]),
			.i_Read_Write_n(DMEM_i_Mem_Read_Write_n),	//1=MemRead, 0=MemWrite
			.i_Write_Data(DMEM_i_Mem_Write_Data),

			// Outputs
			.o_Ready(DMEM_o_Mem_Ready),
			.o_Valid(DMEM_o_Mem_Valid),
			.o_Data(DMEM_o_Read_Data),

			// Mem Transaction
			.o_MEM_Valid(Arbiter_i_DMEM_Valid),
			.o_MEM_Read_Write_n(Arbiter_i_DMEM_Read_Write_n),
			.o_MEM_Address(Arbiter_i_DMEM_Address),
			.o_MEM_Data(Arbiter_i_DMEM_Data),
			.i_MEM_Valid(Arbiter_o_DMEM_Valid),
			.i_MEM_Data_Read(Arbiter_o_DMEM_Data_Read),
			.i_MEM_Last(Arbiter_o_DMEM_Last),
			.i_MEM_Data(Arbiter_o_DMEM_Data)
		);

	// Multiplexor - Select what we will write back
always @(*)
begin
	if( MemToReg )		// If it was a memory operation
	begin
		DMEM_o_Write_Data <= DMEM_o_Read_Data;		// We will write back value from memory
		DMEM_o_Done <= DMEM_o_Mem_Valid;				// Write back only if value is valid
	end
	else
	begin
		DMEM_o_Write_Data <= DMEM_i_Result;		// Else we will write back value from ALU
		DMEM_o_Done <= TRUE;
	end
end

//===================================================================
//	Write-Back
pipe_mem_wb #(	.ADDRESS_WIDTH(ADDRESS_WIDTH),
				.DATA_WIDTH(DATA_WIDTH),
				.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
			)
			PIPE_MEM_WB
			(		// Inputs
				.i_Clk(i_Clk),
				.i_Reset_n(Internal_Reset_n),
				.i_Flush(Hazard_Flush_MEM),
				.i_Stall(Hazard_Stall_WB),

					// Pipe in/out
				.i_WriteBack_Data(DMEM_o_Write_Data),
				.o_WriteBack_Data(WB_i_Write_Data),
				.i_Writes_Back(DMEM_i_Writes_Back),
				.o_Writes_Back(WB_i_Writes_Back),
				.i_Write_Addr(DMEM_i_Write_Addr),
				.o_Write_Addr(DEC_i_Write_Register)
			);


	// Write-Back is simply wires feeding back into regfile to perform writes
	// (SEE REGFILE)



//===================================================================
//	Arbitration Logic

// Memory arbiter
memory_arbiter	#(	.DATA_WIDTH(DATA_WIDTH),
					.ADDRESS_WIDTH(ADDRESS_WIDTH)
				)
				ARBITER
				(
					// General
					.i_Clk(i_Clk),
					.i_Reset_n(Internal_Reset_n),

					// Requests to/from IMEM - Assume we always read
					.i_IMEM_Valid(Arbiter_i_IMEM_Valid),						// If IMEM request is valid
					.i_IMEM_Address(Arbiter_i_IMEM_Address),		// IMEM request addr.
					.o_IMEM_Valid(Arbiter_o_IMEM_Valid),
					.o_IMEM_Last(Arbiter_o_IMEM_Last),
					.o_IMEM_Data(Arbiter_o_IMEM_Data),

					// Requests to/from DMEM
					.i_DMEM_Valid(Arbiter_i_DMEM_Valid),
					.i_DMEM_Read_Write_n(Arbiter_i_DMEM_Read_Write_n),
					.i_DMEM_Address(Arbiter_i_DMEM_Address),
					.i_DMEM_Data(Arbiter_i_DMEM_Data),
					.o_DMEM_Valid(Arbiter_o_DMEM_Valid),
					.o_DMEM_Data_Read(Arbiter_o_DMEM_Data_Read),
					.o_DMEM_Last(Arbiter_o_DMEM_Last),
					.o_DMEM_Data(Arbiter_o_DMEM_Data),

					// Requests to/from FLASH - Assume we always write
					.i_Flash_Valid(Arbiter_i_Flash_Valid),
					.i_Flash_Data(Arbiter_i_Flash_Data),
					.i_Flash_Address(Arbiter_i_Flash_Address),
					.o_Flash_Data_Read(Arbiter_o_Flash_Data_Read),
					.o_Flash_Last(Arbiter_o_Flash_Last),

					// Interface with SDRAM Controller
					.o_MEM_Valid(SDRAM_i_Valid),
					.o_MEM_Address(SDRAM_i_Address),
					.o_MEM_Read_Write_n(SDRAM_i_Read_Write_n),

						// Write data interface
					.o_MEM_Data(SDRAM_i_Data),
					.i_MEM_Data_Read(SDRAM_o_Data_Read),

						// Read data interface
					.i_MEM_Data(SDRAM_o_Data),
					.i_MEM_Data_Valid(SDRAM_o_Data_Valid),

					.i_MEM_Last(SDRAM_o_Last)
				);

sdram_controller memory_controller(
					.i_Clk(i_Clk),
					.i_Reset(!Internal_Reset_n),

					// Request interface
					.i_Addr(SDRAM_i_Address),
					.i_Req_Valid(SDRAM_i_Valid),
					.i_Read_Write_n(SDRAM_i_Read_Write_n),

					// Write .data interface
					.i_Data(SDRAM_i_Data),
					.o_Data_Read(SDRAM_o_Data_Read),

					// Read data .interface
					.o_Data(SDRAM_o_Data),
					.o_Data_Valid(SDRAM_o_Data_Valid),

					// output
					.o_Last(SDRAM_o_Last),

						// SDRAM interface
					.b_Dq(DRAM_DQ),
					.o_Addr(DRAM_ADDR),
					.o_Ba({DRAM_BA_0,DRAM_BA_1}),
					.o_Clk(DRAM_CLK),
					.o_Cke(DRAM_CKE),
					.o_Cs_n(DRAM_CS_N),
					.o_Ras_n(DRAM_RAS_N),
					.o_Cas_n(DRAM_CAS_N),
					.o_We_n(DRAM_WE_N),
					.o_Dqm({DRAM_UDQM,DRAM_LDQM})
				);


// Forwarding logic
forwarding_unit	#(	.DATA_WIDTH(DATA_WIDTH),
					.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
				)
				FORWARDING_UNIT
				(
					// Feedback from DEC
					.i_DEC_Uses_RS(DEC_o_Uses_RS),
					.i_DEC_RS_Addr(DEC_o_Read_Register_1),
					.i_DEC_Uses_RT(DEC_o_Uses_RT),								// DEC wants to use RT
					.i_DEC_RT_Addr(DEC_o_Read_Register_2),							// RT request addr.
					.i_DEC_RS_Data(DEC_o_Read_Data_1),
					.i_DEC_RT_Data(DEC_o_Read_Data_2),

					// Feedback from EX
					.i_EX_Writes_Back(EX_i_Writes_Back),								// EX is valid for analysis
					.i_EX_Valid(ALU_i_Valid),								// If it's a valid ALU op or not
					.i_EX_Write_Addr(EX_i_Write_Addr),							// What EX will write to
					.i_EX_Write_Data(ALU_o_Result),

					// Feedback from MEM
					.i_MEM_Writes_Back(DMEM_i_Writes_Back),								// MEM is valid for analysis
					.i_MEM_Write_Addr(DMEM_i_Write_Addr),							// What MEM will write to
					.i_MEM_Write_Data(DMEM_o_Write_Data),

					// Feedback from WB
					.i_WB_Writes_Back(WB_i_Writes_Back),								// WB is valid for analysis
					.i_WB_Write_Addr(DEC_i_Write_Register),							// What WB will write to
					.i_WB_Write_Data(WB_i_Write_Data),

					//===============================================
					// IFetch forwarding

						// None

					// DEC forwarding
					.o_DEC_RS_Override_Data(FORWARD_o_Forwarded_Data_1),
					.o_DEC_RT_Override_Data(FORWARD_o_Forwarded_Data_2)
				);

// Hazard detection unit / Stall logic
hazard_detection_unit 	#(  .DATA_WIDTH(DATA_WIDTH),
							.ADDRESS_WIDTH(ADDRESS_WIDTH),
							.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
						)
						HAZARD_DETECTION_UNIT
						(
							.i_Clk(i_Clk),
							.i_Reset_n(Internal_Reset_n),

							//==============================================
							// Overall state
							.i_FlashLoader_Done(o_FlashLoader_Done),				// Info about if flashloader is done
							.i_Done(Done),													// If we have observed the 'done' signal from the code yet

							//==============================================
							// Hazard in DECODE?
							.i_DEC_Uses_RS(DEC_o_Uses_RS),								// DEC wants to use RS
							.i_DEC_RS_Addr(DEC_o_Read_Register_1),							// RS request addr.
							.i_DEC_Uses_RT(DEC_o_Uses_RT),								// DEC wants to use RT
							.i_DEC_RT_Addr(DEC_o_Read_Register_2),							// RT request addr.
							.i_DEC_Branch_Instruction(DEC_o_Is_Branch),

							//===============================================
							// Feedback from IF
							.i_IF_Done(IMEM_o_Valid),						// If IF's value has reached steady state

							// Feedback from EX
							.i_EX_Writes_Back(EX_i_Writes_Back),					// EX is valid for data dependency analysis
							.i_EX_Uses_Mem(EX_i_Mem_Valid),
							.i_EX_Write_Addr(EX_i_Write_Addr),							// What EX will write to
							.i_EX_Branch(EX_Take_Branch),							// If EX says we are branching
							.i_EX_Branch_Target(EX_i_Branch_Target),

							// Feedback from MEM
							.i_MEM_Uses_Mem(DMEM_i_Mem_Valid),								// If it's a memop
							.i_MEM_Writes_Back(DMEM_i_Writes_Back),						// MEM is valid for analysis
							.i_MEM_Write_Addr(DMEM_i_Write_Addr),							// What MEM will write to
							.i_MEM_Done(DMEM_o_Done),									// If MEM's value has reached steady state

							// Feedback from WB
							.i_WB_Writes_Back(WB_i_Writes_Back),
							.i_WB_Write_Addr(DEC_i_Write_Register),

							//===============================================
							// Branch hazard handling
							.o_IF_Branch(IFetch_i_Load),
							.o_IF_Branch_Target(IFetch_i_PCSrc),

							//===============================================
							// IFetch validation
							.o_IF_Stall(Hazard_Stall_IF),
							.o_IF_Smash(Hazard_Flush_IF),

							// DECODE validation
							.o_DEC_Stall(Hazard_Stall_DEC),
							.o_DEC_Smash(Hazard_Flush_DEC),

							// EX validation
							.o_EX_Stall(Hazard_Stall_EX),
							.o_EX_Smash(Hazard_Flush_EX),

							// MEM validation
							.o_MEM_Stall(Hazard_Stall_MEM),
							.o_MEM_Smash(Hazard_Flush_MEM),

							.o_WB_Stall(Hazard_Stall_WB),
							.o_WB_Smash(Hazard_Flush_WB)
						);



//===================================================================
//	Initialization

//	Flash Loader
// speed ups for simulation
`ifdef MODEL_TECH
flashreader#(.WORDS_TO_LOAD(32'h00008000),
			.FLASH_READ_WAIT_TIME_PS(0))
`else
flashreader
`endif
flashloader2(	.i_Clk(i_Clk),
				.i_Reset_n(Internal_Reset_n),
				.o_Done(o_FlashLoader_Done),
				.o_SDRAM_Addr(o_FlashLoader_SDRAM_Addr),
				.o_SDRAM_Req_Valid(o_FlashLoader_SDRAM_Req_Valid),
				.o_SDRAM_Read_Write_n(o_FlashLoader_SDRAM_Read_Write_n),
				.o_SDRAM_Data(o_FlashLoader_SDRAM_Data),
				.i_SDRAM_Data_Read(i_FlashLoader_SDRAM_Data_Read),
				.i_SDRAM_Last(i_FlashLoader_SDRAM_Last),
				.o_FL_Addr(o_FlashLoader_FL_Addr),
				.i_FL_Data(i_FlashLoader_FL_Data),
				.o_FL_Chip_En_n(o_FlashLoader_FL_Chip_En_n),
				.o_FL_Output_En_n(o_FlashLoader_FL_Output_En_n),
				.o_FL_Write_En_n(o_FlashLoader_FL_Write_En_n),
				.o_FL_Reset_n(o_FlashLoader_FL_Reset_n)
			);

initial
begin
end

endmodule
