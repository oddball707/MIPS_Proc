module jump_stack#(
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter STACK_SIZE = 16
				)
				(
					input i_Clk,
					input i_Reset_n,

					////Inputs from pre-align
					input [ADDRESS_WIDTH-1:0] i_address,	//address in memory (for hash)
					input [1:0] i_thread,					//to choose which thread to use
					input i_pop,							//push if jal - 0, pop if jr - 1
					input i_push,							//1 if jal or jr, 0 otherwise

					output reg [ADDRESS_WIDTH-1:0] o_address	//popped value - if jr
				);

reg [ADDRESS_WIDTH-1:0] stack0[STACK_SIZE-1:0];
reg [ADDRESS_WIDTH-1:0] stack1[STACK_SIZE-1:0];
reg [ADDRESS_WIDTH-1:0] stack2[STACK_SIZE-1:0];
reg [ADDRESS_WIDTH-1:0] stack3[STACK_SIZE-1:0];
reg [5:0] stack_pointer0;
reg [5:0] stack_pointer1;
reg [5:0] stack_pointer2;
reg [5:0] stack_pointer3;


always@(*)
begin
case(i_thread)

		0:
		begin
			o_address = stack0[stack_pointer0];
		end
		1:
		begin
			o_address = stack1[stack_pointer1];
		end
		2:
		begin
			o_address = stack2[stack_pointer2];
		end
		3:
		begin
			o_address = stack3[stack_pointer3];
		end
endcase
end

always@(posedge i_Clk or negedge i_Reset_n)
begin
if(!i_Reset_n)
begin
	stack_pointer0 <= 0;
	stack_pointer1 <= 0;
	stack_pointer2 <= 0;
	stack_pointer3 <= 0;
end 
else
begin
	case(i_thread)

		0:
		begin
			if(i_pop)		//pop
			begin
				stack_pointer0 <= stack_pointer0 - 1;
			end
			else			//push
			begin
				stack0[stack_pointer0+1] <= i_address;
				stack_pointer0 <= stack_pointer0 + 1;
			end
		end

		1:
		begin
			if(i_pop)		//pop
			begin
				stack_pointer1 <= stack_pointer1 - 1;
			end
			else			//push
			begin
				stack1[stack_pointer1+1] <= i_address;
				stack_pointer1 <= stack_pointer1 + 1;
			end
		end

		2:
		begin
			if(i_pop)		//pop
			begin
				stack_pointer2 <= stack_pointer2 - 1;
			end
			else			//push
			begin
				stack2[stack_pointer2+1] <= i_address;
				stack_pointer2 <= stack_pointer2 + 1;
			end
		end

		3:
		begin
			if(i_pop)		//pop
			begin
				stack_pointer3 <= stack_pointer3 - 1;
			end
			else			//push
			begin
				stack3[stack_pointer3+1] <= i_address;
				stack_pointer3 <= stack_pointer3 + 1;
			end
		end
	endcase
end

end
endmodule