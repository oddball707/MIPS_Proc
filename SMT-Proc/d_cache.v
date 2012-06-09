/* d_cache.v
* Author: Pravin P. Prabhu
* Last Revision: 1/5/11
* Abstract:
*	Provides a simple data cache implementation. Fetches data from main memory
* and caches it for quick access. This cache does not implement write-through
* and does not support byte-select (i.e. all accesses are full words).
*/
module d_cache	#(	
					parameter DATA_WIDTH = 32,
					parameter TAG_WIDTH = 14,
					parameter INDEX_WIDTH = 5,
					parameter BLOCK_OFFSET_WIDTH = 2,
					parameter MEM_MASK_WIDTH = 3
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Valid,
					input [MEM_MASK_WIDTH-1:0] i_Mem_Mask,
					input [(TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH)-1:0] i_Address,	// 32-bit aligned address
					input i_Read_Write_n,
					input [DATA_WIDTH-1:0] i_Write_Data,

					// Outputs
					output o_Ready,
					output reg o_Valid,					// If done reading out a value.
					output reg [DATA_WIDTH-1:0] o_Data,
					
					// Mem Transaction
					output reg o_MEM_Valid,
					output reg o_MEM_Read_Write_n,
					output reg [(TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH):0] o_MEM_Address,	// output 2-byte aligned addresses
					output reg [DATA_WIDTH-1:0] o_MEM_Data,
					input i_MEM_Valid,
					input i_MEM_Data_Read,
					input i_MEM_Last,
					input [DATA_WIDTH-1:0] i_MEM_Data
				);

	// consts
	localparam FALSE = 1'b0;
	localparam TRUE = 1'b1;
	localparam UNKNOWN = 1'bx;
	
	localparam READ = 1'b1;
	localparam WRITE = 1'b0;	
	
	localparam ADDRESS_WIDTH = TAG_WIDTH+INDEX_WIDTH+BLOCK_OFFSET_WIDTH;
	
	// Internal
		// Reg'd inputs
	reg [BLOCK_OFFSET_WIDTH-1:0] r_i_BlockOffset;
	reg [INDEX_WIDTH-1:0] r_i_Index;
	reg [TAG_WIDTH-1:0] r_i_Tag;
	reg [DATA_WIDTH-1:0] r_i_Write_Data;
	reg r_i_Read_Write_n;
	
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
		// Dirty
	reg Dirty_Array [0:(1<<INDEX_WIDTH)-1];
	
		// Hacks
	reg [DATA_WIDTH-1:0] Populate_Data; 		// Override so we write user data to the cache instead of data from MEM
	
		// States
	reg [5:0] State;
	
	localparam STATE_READY = 0;				// Ready for incoming requests
	localparam STATE_WRITE_HIT = 1;
	localparam STATE_POPULATE = 2;				// Cache miss - Populate cache line
	localparam STATE_WRITEOUT = 3;			// Writes out dirty cache lines
	
	
		// Counters
	integer i;
	reg [8:0] Gen_Count;					// General counter
	
		// Hardwired assignments
	assign o_Ready = (State==STATE_READY);
	
	
	
	// Combinatorial logic: What state are we in? How should we handle I/O?
	always @(*)
	begin
		// Set defaults to avoid latch inference
		o_Valid <= FALSE;
		o_Data <= {DATA_WIDTH{UNKNOWN}};
		Populate_Data <= i_MEM_Data;
		
		// Act asynchronously based on state
		case(State)
			// We're ready for requests
			STATE_READY:
			begin
				// Support for single-cycle hits
				if( i_Valid &&
					Valid_Array[i_Index] &&
					Tag_Array[i_Index] == i_Tag
					)
				begin
					// Read hit.
					o_Valid <= TRUE;

					case( i_BlockOffset )
						// Verilog doesn't allow generic indexing into arrays with operators..
						0:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*1)-1:0];
						1:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
						2:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
						3:	o_Data <= Data_Array[i_Index][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];
						default:	o_Data <= {DATA_WIDTH{UNKNOWN}};
					endcase
				end
			end
			
			// We are handling a read miss - Repopulate cache line
			STATE_POPULATE:
			begin
				if( i_MEM_Valid )
				begin
					// Is this the data we were waiting on?
					if( Gen_Count == r_i_BlockOffset )
					begin
						o_Valid <= TRUE;
						
						if( r_i_Read_Write_n == READ )
						begin
							o_Data <= i_MEM_Data;
						end
						else
						begin
							Populate_Data <= r_i_Write_Data;	// Override with write data
						end
					end
				end
			end
			
			default:
			begin
			end
		endcase
	end

	//reg [31:0] DebugMemory [(2**21)-1:0];
		
	// Stateful actions
	always @(posedge i_Clk or negedge i_Reset_n)
	begin

	/*
		if (i_Valid && i_Read_Write_n && o_Valid && DebugMemory[i_Address] != o_Data)
			$display("Invalid DCache read at %x value is %x expected ", i_Address, o_Data, DebugMemory[i_Address]);
		else if (i_Valid && !i_Read_Write_n)
		begin
			DebugMemory[i_Address] <= i_Write_Data;
			$display("DCache write at %x value is %x", i_Address, i_Write_Data);
		end
		*/
		
		// Asynch. reset
		if( !i_Reset_n )
		begin
			State <= STATE_READY;
			o_MEM_Valid <= FALSE;
		end
		else
		begin
			case( State )
				STATE_READY:
				begin
					// Populate an existing clean or nonexistant cache line.
					if( (i_Valid && !Valid_Array[i_Index]) ||
						(i_Valid && Valid_Array[i_Index] && !Dirty_Array[i_Index] && (Tag_Array[i_Index] != i_Tag)) )
					begin	
						o_MEM_Valid <= TRUE;
						o_MEM_Address <= {i_Tag,i_Index,{BLOCK_OFFSET_WIDTH+1{1'b0}}};
						o_MEM_Read_Write_n <= READ;	
						
						// Prepare counter
						Gen_Count <= 0;
						
						// Latch inputs
						r_i_BlockOffset <= i_BlockOffset;
						r_i_Index <= i_Index;
						r_i_Tag <= i_Tag;
						r_i_Write_Data <= i_Write_Data;
						r_i_Read_Write_n <= i_Read_Write_n;
						
						State <= STATE_POPULATE;
					end
					else if( i_Valid && 
						Valid_Array[i_Index] &&
						Tag_Array[i_Index] != i_Tag )
					begin
						// Going to Writeout
						if( Dirty_Array[i_Index] )
						begin	
							o_MEM_Valid <= TRUE;
							o_MEM_Address <= {Tag_Array[i_Index],i_Index,{BLOCK_OFFSET_WIDTH+1{1'b0}}};	
							o_MEM_Data <= Data_Array[i_Index][(DATA_WIDTH*1)-1:0];
							o_MEM_Read_Write_n <= WRITE;

							// Prepare counter
							Gen_Count <= 1;
							
							// Latch inputs
							r_i_BlockOffset <= i_BlockOffset;
							r_i_Index <= i_Index;
							r_i_Tag <= i_Tag;
							r_i_Write_Data <= i_Write_Data;
							r_i_Read_Write_n <= i_Read_Write_n;
								
							State <= STATE_WRITEOUT;
						end
					end
					else if( i_Valid &&
							 Valid_Array[i_Index] &&
							 Tag_Array[i_Index] == i_Tag &&
							 i_Read_Write_n == WRITE )
					begin
						// Write hit! Perform write.
						case( i_BlockOffset )
							0:	Data_Array[i_Index][(DATA_WIDTH*1)-1:0] <= i_Write_Data;
							1:	Data_Array[i_Index][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)] <= i_Write_Data;
							2:	Data_Array[i_Index][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)] <= i_Write_Data;
							3:	Data_Array[i_Index][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)] <= i_Write_Data;
							default:	$display("Warning: Invalid Gen Count value @ d_cache");						
						endcase
						
						Dirty_Array[i_Index] <= TRUE;
					end
				end
				
				STATE_WRITEOUT:
				begin
					if( i_MEM_Data_Read )
					begin
						case( Gen_Count )
							1:	o_MEM_Data <= Data_Array[r_i_Index][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)];
							2:	o_MEM_Data <= Data_Array[r_i_Index][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)];
							3:	o_MEM_Data <= Data_Array[r_i_Index][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)];
							4:	o_MEM_Data <= {DATA_WIDTH{UNKNOWN}};		// We are done on this cycle.
							default:	$display("Warning: Invalid Gen Count value @ d_cache writeout");
						endcase

						// Account for the input
						if( i_MEM_Last )
						begin
							Gen_Count <= 0;
							State <= STATE_POPULATE;
							o_MEM_Valid <= TRUE;
							o_MEM_Address <= {r_i_Tag,r_i_Index,{BLOCK_OFFSET_WIDTH+1{1'b0}}};
							o_MEM_Read_Write_n <= READ;								
							Dirty_Array[r_i_Index] <= FALSE;	// Cache line was cleaned
						end
						else
						begin
							Gen_Count <= Gen_Count + 9'd1;
						end
					end
				end
				
				STATE_POPULATE:
				begin
					if( i_MEM_Valid )
					begin
						case( Gen_Count )
							0:	Data_Array[r_i_Index][(DATA_WIDTH*1)-1:0] <= Populate_Data;
							1:	Data_Array[r_i_Index][(DATA_WIDTH*2)-1:(DATA_WIDTH*1)] <= Populate_Data;
							2:	Data_Array[r_i_Index][(DATA_WIDTH*3)-1:(DATA_WIDTH*2)] <= Populate_Data;
							3:	Data_Array[r_i_Index][(DATA_WIDTH*4)-1:(DATA_WIDTH*3)] <= Populate_Data;
							default:	$display("Warning: Invalid Gen Count value @ d_cache");
						endcase
						
						// Account for the input
						Gen_Count <= Gen_Count + 9'd1;
					
						// If we're about to finish...
						if( i_MEM_Last )
						begin
							// Record info about transaction in tags & valid bits
							Tag_Array[r_i_Index] <= r_i_Tag;
							Valid_Array[r_i_Index] <= TRUE;
							o_MEM_Valid <= FALSE;
							if( r_i_Read_Write_n == WRITE )
								Dirty_Array[r_i_Index] <= TRUE;
							else
								Dirty_Array[r_i_Index] <= FALSE;
							State <= STATE_READY;
						end
					end
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
