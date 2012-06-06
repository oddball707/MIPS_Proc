module jump_stack#(
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter STACK_SIZE = 16
				)
				(
					input i_Clk,
					input i_Stall,

					////Inputs from pre-align
					input [ADDRESS_WIDTH-1:0] i_address,	//address in memory (for hash)
					input [1:0] i_thread,					//to choose which thread to use
					input i_pop,							//push if jal - 0, pop if jr - 1
					input i_push,							//1 if jal or jr, 0 otherwise

					input i_Reset_n,

					output reg [ADDRESS_WIDTH-1:0] o_address,	//popped value - if jr
					output reg o_valid							// 1 if jr, 0 if jal or other
				);

reg [ADDRESS_WIDTH-1:0] stack0[STACK_SIZE-1:3];
reg [ADDRESS_WIDTH-1:0] stack1[STACK_SIZE-1:3];
reg [ADDRESS_WIDTH-1:0] stack2[STACK_SIZE-1:3];
reg [ADDRESS_WIDTH-1:0] stack3[STACK_SIZE-1:3];
reg stack_pointer[3:0];

always@(posedge i_Clk)
begin
	case(i_thread)

		0:
		begin
			if(i_pop)		//pop
			begin
				o_address <= stack0[stack_pointer[0]];
				stack_pointer[0] <= stack_pointer[0] - 1;
				o_valid <= 1;
			end
			else			//push
			begin
				stack0[stack_pointer[0]+1] <= i_address;
				if(stack_pointer[0] < STACK_SIZE-1)
				begin
					stack_pointer[0] <= stack_pointer[0] + 1;
				end
				o_valid <= 0;
				o_address <= stack0[stack_pointer[0]];
			end
		end

		1:
		begin
			if(i_pop)		//pop
			begin
				o_address <= stack1[stack_pointer[1]];
				stack_pointer[1] <= stack_pointer[1] - 1;
				o_valid <= 1;
			end
			else			//push
			begin
				stack0[stack_pointer[1]+1] <= i_address;
				if(stack_pointer[1] < STACK_SIZE-1)
				begin
					stack_pointer[1] <= stack_pointer[1] + 1;
				end
				o_valid <= 0;
				o_address <= stack1[stack_pointer[1]];
			end
		end

		2:
		begin
			if(i_pop)		//pop
			begin
				o_address <= stack2[stack_pointer[2]];
				stack_pointer[2] <= stack_pointer[2] - 1;
				o_valid <= 1;
			end
			else			//push
			begin
				stack0[stack_pointer[2]+1] <= i_address;
				if(stack_pointer[2] < STACK_SIZE-1)
				begin
					stack_pointer[2] <= stack_pointer[2] + 1;
				end
				o_valid <= 0;
				o_address <= stack2[stack_pointer[2]];
			end
		end

		3:
		begin
			if(i_pop)		//pop
			begin
				o_address <= stack3[stack_pointer[3]];
				stack_pointer[3] <= stack_pointer[3] - 1;
				o_valid <= 1;
			end
			else			//push
			begin
				stack0[stack_pointer[3]+1] <= i_address;
				if(stack_pointer[3] < STACK_SIZE-1)
				begin
					stack_pointer[3] <= stack_pointer[3] + 1;
				end
				o_valid <= 0;
				o_address <= stack3[stack_pointer[3]];
			end
		end
	endcase
end

endmodule