module demux 	#(
						parameter ADDRESS_WIDTH = 32,
						parameter ISN_WIDTH = 99
					)
					(
						// Inputs
						input i_Clk,
						input i_Reset_n,	// Async reset (highest priority)
						input i_Flush,			// Flush (lowest priority)
						input i_Stall,		// Stall (2nd highest priority)
						
						input [ADDRESS_WIDTH-1:0] i_thread,
						input [3:0] i_valid,	//for instructions
						
						input [ISN_WIDTH-1:0] i_Instruction1,
						input [ISN_WIDTH-1:0] i_Instruction2,
						input [ISN_WIDTH-1:0] i_Instruction3,
						input [ISN_WIDTH-1:0] i_Instruction4,
						
						output reg [4*ISN_WIDTH-1:0] o_thread1,
						output reg [4*ISN_WIDTH-1:0] o_thread2,
						output reg [4*ISN_WIDTH-1:0] o_thread3,
						output reg [4*ISN_WIDTH-1:0] o_thread4,
						
						output reg [3:0] o_valid1,
						output reg [3:0] o_valid2,
						output reg [3:0] o_valid3,
						output reg [3:0] o_valid4
						
					);

		// Asynchronous output driver
	always @(posedge i_Clk or negedge i_Reset_n)
	begin
	if( !i_Reset_n )
		begin
			// Initialize outputs to 0s
			o_thread1 <= 0;
			o_thread2 <= 0;
			o_thread3 <= 0;
			o_thread4 <= 0;
			
			o_valid1 <= 0;
			o_valid2 <= 0;
			o_valid3 <= 0;
			o_valid4 <= 0;
		end
		else
		begin
			if( !i_Stall )
			begin
				if( i_Flush )
				begin
					o_thread1 <= 0;
					o_thread2 <= 0;
					o_thread3 <= 0;
					o_thread4 <= 0;
					
					o_valid1 <= 0;
					o_valid2 <= 0;
					o_valid3 <= 0;
					o_valid4 <= 0;
				end
				else
				begin
					case(i_thread)
						00:
						begin
							o_thread1 <= {i_Instruction1, i_Instruction2, i_Instruction3, i_Instruction4};
							o_thread2 <= 0;
							o_thread3 <= 0;
							o_thread4 <= 0;
							
							o_valid1 <= i_valid;
							o_valid2 <= 0;
							o_valid3 <= 0;
							o_valid4 <= 0;
						end
						
						01:
						begin
							o_thread1 <= 0;
							o_thread2 <= {i_Instruction1, i_Instruction2, i_Instruction3, i_Instruction4};
							o_thread3 <= 0;
							o_thread4 <= 0;
							
							o_valid1 <= 0;
							o_valid2 <= i_valid;
							o_valid3 <= 0;
							o_valid4 <= 0;
						end
						
						10:
						begin
							o_thread1 <= 0;
							o_thread2 <= 0;
							o_thread3 <= {i_Instruction1, i_Instruction2, i_Instruction3, i_Instruction4};
							o_thread4 <= 0;
							
							o_valid1 <= 0;
							o_valid2 <= 0;
							o_valid3 <= i_valid;
							o_valid4 <= 0;
						end
						
						11:
						begin
							o_thread1 <= 0;
							o_thread2 <= 0;
							o_thread3 <= 0;
							o_thread4 <= {i_Instruction1, i_Instruction2, i_Instruction3, i_Instruction4};
							
							o_valid1 <= 0;
							o_valid2 <= 0;
							o_valid3 <= 0;
							o_valid4 <= i_valid;
						end
					endcase
				end
			end	
		end
	end
	
	endmodule