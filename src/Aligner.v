module aligner	#(
					parameter ADDRESS_WIDTH = 32,
					parameter DATA_WIDTH = 32,
					parameter INSN_WIDTH = 99
				)
				(	// Inputs
					input i_Clk,
					input i_Reset_n,
					input i_Stall,

					//from I_CACHE
					input [ADDRESS_WIDTH-1:0] i_pc,			//of first instruction (i_isn1)

					//from decoder
					input [INSN_WIDTH-1:0] i_isn1,
					input [INSN_WIDTH-1:0] i_isn2,
					input [INSN_WIDTH-1:0] i_isn3,
					input [INSN_WIDTH-1:0] i_isn4,

					// Outputs - to Queues
					output reg [3:0] o_valid,				//which instructions are  valid (4321)
					output reg [INSN_WIDTH-1:0] o_isn1,
					output reg [INSN_WIDTH-1:0] o_isn2,
					output reg [INSN_WIDTH-1:0] o_isn3,
					output reg [INSN_WIDTH-1:0] o_isn4
					//output reg [ISN_WIDTH*4-1:0] o_isn4to1
				);

//assign o_isn4to1 = {i_isn4, i_isn3, i_isn2, i_isn1};
//assign o_isn1 = i_isn1;
//assign o_isn2 = i_isn2;
//assign o_isn3 = i_isn3;
//assign o_isn4 = i_isn4;

always@(*)
begin
	case(i_PC[1:0])
		00:
		begin
			o_isn1 <= i_isn1;
			o_isn2 <= i_isn2;
			o_isn3 <= i_isn3;
			o_isn4 <= i_isn4;
			
			if(i_isn1[9])			//first instruction is branch
			begin
				o_valid <= 4'b0011;
			end

			else if(i_isn2[9])	//second instruction is branch
			begin
				o_valid <= 4'b0111;
			end

			else if(i_isn3[9])	//third instruction is branch
			begin
				o_valid <= 4'b1111;
			end

			else if(i_isn4[9])	//fourth instruction is branch
			begin
				o_valid <= 4'b1111;
			end

			else						//no branches
			begin
				o_valid <= 4'b1111;
			end
		end
		
		01:
		begin
			o_isn1 <= i_isn2;
			o_isn2 <= i_isn3;
			o_isn3 <= i_isn4;
			o_isn4 <= 0;
			
			if(i_isn2[9])			//second instruction is branch
			begin
				o_valid <= 4'b1100;
			end

			else if(i_isn3[9])	//third instruction is branch
			begin
				o_valid <= 4'b1110;	
			end

			else if(i_isn4[9])	//fourth instruction is branch
			begin
				o_valid <= 4'b1110;	//notify about 1st inst delay slot
			end

			else						//no branches
			begin
				o_valid <= 4'b1110;
			end
		end
		
		10:
		begin
			o_isn1 <= i_isn3;
			o_isn2 <= i_isn4;
			o_isn3 <= 0;
			o_isn4 <= 0;
			
			if(i_isn3[9])			//third instruction is branch
			begin
				o_valid <= 4'b1100;
			end

			else if(i_isn4[9])	//fourth instruction is branch
			begin
				o_valid <= 4'b1100;	//notify
			end

			else						//no branches
			begin
				o_valid <= 4'b1100;
			end
		end
		
		11:
		begin
			o_isn1 <= i_isn4;
			o_isn2 <= 0;
			o_isn3 <= 0;
			o_isn4 <= 0;
		end
		
			if(i_isn4[9])			//fourth instruction is branch
			begin
				o_valid <= 4'b1000;
			end

			else						//no branches
			begin
				o_valid <= 4'b1000;
			end
	endcase
end

endmodule
