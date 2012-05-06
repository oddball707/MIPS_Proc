`timescale 1ns/1ps
module test_bp();


	reg clock;
	reg [21:0] pc;
	reg [21:0] ALUpc;
	reg validbr;
	reg pred;
	reg inst;
	reg br_outcome;
	reg reset;

	wire taken;
	wire flush;
	wire valid;

	initial begin
		clock <= 0;
		forever #10 clock = ~clock;
	end

	initial begin
		reset = 1;
		#20 reset = 0;
	end
	
	initial begin
      $dumpfile("test_bp.vcd");
      $dumpvars;
      $display("time\tclock\trs_data\trt_data\n");
      $monitor("%d,\t%b,\t%d,\t%d", $time, clock, taken, flush);
   end

	initial begin
		#20;
		$display("Sending branch, should be taken");
		inst = 1;
		pred = 1;
		#20;
		inst = 0;
		pred = 0;
		#20;
		br_outcome = 1;  //agree
		pred = 1;
		inst = 1;
		#20;
		br_outcome = 0; //agree
		pred = 0;
		inst = 1;
		#20;
		$display("should flush here");
		br_outcome = 0;   //disagree
		pred = 1;
		inst = 0;
		#20;
		br_outcome = 1;  //agree
		pred = 1;
		inst = 0;
		#20;
		$finish;
	end
		
		
branch_predictor bp(
				.i_Clk(clock),
				.i_IMEM_address(pc),
				.i_IMEM_isbranch(inst),
				.i_ALU_outcome(br_outcome),
				.i_ALU_pc(ALUpc),									//pc from branch in ALU stage
				.i_ALU_isbranch(validbr),
				.i_ALU_prediction(pred),
				.i_Reset_n(reset),
				
				.o_taken(taken),
				.o_flush(flush),
				.o_valid(valid)
				);
				
endmodule