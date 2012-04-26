/* i_cache.v
* Author: Pravin P. Prabhu
* Last Revision: 1/5/11
* Abstract:
*	Provides caching of instructions from imem for quick access. Note that this
* is a read only cache, and thus self-modifying code is not supported.
*/
module i_cache	#(	parameter DATA_WIDTH = 32,
					parameter TAG_WIDTH = 14,
					parameter INDEX_WIDTH = 5,
					parameter BLOCK_OFFSET_WIDTH = 2
				)
				(
					// General
					input i_Clk,
					input i_Reset_n,
					
					// Requests
					input i_Valid,
					input [TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH:0] i_Address,
					
					// DMEM Transaction
					output reg o_MEM_Valid,						// If request to DMEM is valid
					output reg [TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH:0] o_MEM_Address,	// Address request to DMEM
					input i_MEM_Valid,						// If data from main mem is valid
					input i_MEM_Last,							// If main mem is sending the last piece of data
					input [DATA_WIDTH-1:0] i_MEM_Data,		// Data from main mem
					
					// Outputs
					output o_Ready,
					output reg o_Valid,							// If the output is correct.
					output reg o_isbranch,						// if the instruction is a branch
					output reg [DATA_WIDTH-1:0] o_Data		// The data requested.
				);
				
	// consts
	localparam FALSE = 1'b0;
	localparam TRUE = 1'b1;
	
	// Internal
		// Reg'd inputs
	reg [BLOCK_OFFSET_WIDTH-1:0] r_i_BlockOffset;
	reg [INDEX_WIDTH-1:0] r_i_Index;
	reg [TAG_WIDTH-1:0] r_i_Tag;
	
		// Parsing
	wire [BLOCK_OFFSET_WIDTH-1:0] i_BlockOffset = i_Address[BLOCK_OFFSET_WIDTH-1:0];
	wire [INDEX_WIDTH-1:0] i_Index = i_Address[INDEX_WIDTH+BLOCK_OFFSET_WIDTH-1:BLOCK_OFFSET_WIDTH];
	wire [TAG_WIDTH-1:0] i_Tag = i_Address[TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH-1:INDEX_WIDTH+BLOCK_OFFSET_WIDTH];
	
		// Tags
	reg [TAG_WIDTH-1:0] Tag_Array [0:(1<<INDEX_WIDTH)-1];
		// Data
	reg [(DATA_WIDTH*4)-1:0] Data_Array [0:(1<<INDEX_WIDTH)-1];
		// Valid
	reg Valid_Array [0:(1<<INDEX_WIDTH)-1];
	
		// States
	reg [5:0] State;
	reg [5:0] NextState;
	
	localparam STATE_READY = 0;				// Ready for incoming requests
	localparam STATE_MISS_READ = 1;				// Missing on a read
	
		// Counters
	integer i;
	reg [8:0] Gen_Count;					// General counter
	
		//branch detection
	wire [3:0] opcode1;
	wire opcodeA, opcodeB, opcodeC;

	assign opcode1 = o_Data[31:29];		//first 3 bits of instruction opcode (000 for branch)
	assign opcodeA = o_Data[28];			//next 3 bits of opcode (CBA)
	assign opcodeB = o_Data[27];
	assign opcodeC = o_Data[26];
	
		// Hardwired assignments
	assign o_Ready = (State==STATE_READY);
	
	
	
	// Combinatorial logic: What state are we in? How should we handle I/O?
	always @(*)
	begin
		// Set defaults to avoid latch inference
		NextState <= State;
		o_Valid <= FALSE;
		o_Data <= {DATA_WIDTH{1'bx}};
		o_MEM_Valid <= FALSE;
		o_MEM_Address <= {TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH{1'bx}};
		 
		
		// Act asynchronously based on state
		case(State)
			// We're ready for requests
			STATE_READY:
			begin
				// Valid request?
				if( i_Valid )
				begin
					if( Valid_Array[i_Index] &&
						Tag_Array[i_Index] == i_Tag
						)
					begin
						// Hit!
						o_Valid <= TRUE;

						case( i_BlockOffset )
							// Verilog doesn't allow generic indexing into arrays with operators..
							0:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*1)-1:0];
							1:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
							2:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
							3:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];
							default:	o_Data <= {DATA_WIDTH{1'bx}};
						endcase
						
						o_isbranch <= !opcode1 && (!opcodeB || (opcodeB && !opcodeC));	//1 if branch instruction
					end
					else
					begin
						// Miss. Will proceed to Miss state.
						NextState <= STATE_MISS_READ;
					end
				end
				else
				begin
					// Invalid output
				end
			end
			
			// We are handling a read miss
			STATE_MISS_READ:
			begin
				// Submit our request.
				o_MEM_Valid <= TRUE;
				o_MEM_Address <= {r_i_Tag,r_i_Index,{BLOCK_OFFSET_WIDTH{1'b0}},1'b0};
				
				// Mem is communicating?
				if( i_MEM_Valid )
				begin
				
					// Is this the data we were waiting on?
					if( Gen_Count == r_i_BlockOffset )
					begin
						// Yes
						o_Valid <= TRUE;
						o_Data <= i_MEM_Data;
					end
				
					// Last piece of transaction?
					if( i_MEM_Last )
					begin
						// This is the last piece of data. We will transition on the next cycle.
						NextState <= STATE_READY;
					end
				end
			end
			
			// Invalid state
			default:
			begin
				$display("Warning: Invalid state @ i_cache.v: %d",$time);
			end
		endcase
	end
	
	// State driver
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
		if( !i_Reset_n )
		begin
			State <= STATE_READY;
		end
		else
		begin
			State <= NextState;
			
			// Initialize for next state
			case( State )
				STATE_READY:
				begin
					if( NextState == STATE_MISS_READ )
					begin		
						// Prepare counter
						Gen_Count <= 0;
						
						// Latch inputs
						r_i_BlockOffset <= i_BlockOffset;
						r_i_Index <= i_Index;
						r_i_Tag <= i_Tag;	
					end
				end
				
				STATE_MISS_READ:
				begin
					if( NextState == STATE_READY )
					begin
						// Record info about transaction in tags & valid bits
						Tag_Array[r_i_Index] <= r_i_Tag;
						Valid_Array[r_i_Index] <= TRUE;
					end
				
					if( i_MEM_Valid )
					begin
						case( Gen_Count )
							0:	Data_Array[r_i_Index][(DATA_WIDTH*1)-1:0] <= i_MEM_Data;
							1:	Data_Array[r_i_Index][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)] <= i_MEM_Data;
							2:	Data_Array[r_i_Index][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)] <= i_MEM_Data;
							3:	Data_Array[r_i_Index][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)] <= i_MEM_Data;
							default:	$display("Warning: Invalid Gen Count value @ i_cache");
						endcase
						
						// Account for the input
						Gen_Count <= Gen_Count + 9'b1;										
					end
				end
				
				default:
				begin
				end
			endcase
		end
	end
	
	initial
	begin
		// Mark everything as invalid
		for(i=0;i<(1<<INDEX_WIDTH);i=i+1)
		begin
			Valid_Array[i] = FALSE;
		end
	end
	
endmodule
				