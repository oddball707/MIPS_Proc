module branch_predictor#(
					parameter DATA_WIDTH = 32,
					parameter ADDRESS_WIDTH = 22,
					parameter GHR_SIZE = 8
				)
				(
					////Inputs from current stage - only predict one at a time
					input i_Clk,
					input [GHR_SIZE-1:0] i_IMEM_address,	//address in memory (for hash)
					input [1:0] i_thread,					//to choose which thread to use

					////Inputs from ALU stage - can accept feedback from up to 4 at a time
					input i_ALU_outcome[3:0],				//1 if taken 0 not taken (from ALU computation)
					input i_ALU_isbranch[3:0],				//if inst in ALU stage is a branch
					input i_ALU_prediction[3:0],			//prediction for branch in ALU

					input i_Reset_n,

					output reg o_taken						//prediction
				);

//-----Thread 1-----
reg [1:0] branch_history1[0:(2**GHR_SIZE)-1];				//hash table for branch histories - 7 indexing bits
reg [GHR_SIZE-1:0] GHR1;									//shift register
wire [GHR_SIZE-1:0] gshare_index1;
wire [1:0] gshare_counter1;									//base bimodal counter
wire [1:0] GHR_index1;
reg [GHR_SIZE-1:0] GHR_saved1;								//holds GHR from last prediction
assign gshare_index1 = GHR1[GHR_SIZE-1:0] ^ i_IMEM_address[GHR_SIZE-1:0];
assign gshare_counter1 = branch_history1[gshare_index1];	//holds bit that was shifted out, in case prediction was wrong

//-----Thread 2-----
reg [1:0] branch_history2[0:(2**GHR_SIZE)-1];				//hash table for branch histories - 7 indexing bits
reg [GHR_SIZE-1:0] GHR2;									//shift register
wire [GHR_SIZE-1:0] gshare_index2;
wire [1:0] gshare_counter2;									//base bimodal counter
wire [1:0] GHR_index2;
reg [GHR_SIZE-1:0] GHR_saved2;								//holds GHR from last prediction
assign gshare_index2 = GHR2[GHR_SIZE-1:0] ^ i_IMEM_address[GHR_SIZE-1:0];
assign gshare_counter2 = branch_history2[gshare_index2];	//holds bit that was shifted out, in case prediction was wrong

//-----Thread 3-----
reg [1:0] branch_history3[0:(2**GHR_SIZE)-1];				//hash table for branch histories - 7 indexing bits
reg [GHR_SIZE-1:0] GHR3;									//shift register
wire [GHR_SIZE-1:0] gshare_index3;
wire [1:0] gshare_counter3;									//base bimodal counter
wire [1:0] GHR_index3;
reg [GHR_SIZE-1:0] GHR_saved3;								//holds GHR from last prediction
assign gshare_index3 = GHR[GHR_SIZE-1:0] ^ i_IMEM_address[GHR_SIZE-1:0];
assign gshare_counter3 = branch_history3[gshare_index3];	//holds bit that was shifted out, in case prediction was wrong

//-----Thread 4-----
reg [1:0] branch_history4[0:(2**GHR_SIZE)-1];				//hash table for branch histories - 7 indexing bits
reg [GHR_SIZE-1:0] GHR4;									//shift register
wire [GHR_SIZE-1:0] gshare_index4;
wire [1:0] gshare_counter4;									//base bimodal counter
wire [1:0] GHR_index4;
reg [GHR_SIZE-1:0] GHR_saved4;								//holds GHR from last prediction
assign gshare_index4 = GHR4[GHR_SIZE-1:0] ^ i_IMEM_address[GHR_SIZE-1:0];
assign gshare_counter4 = branch_history4[gshare_index4];	//holds bit that was shifted out, in case prediction was wrong



integer i;	//for loops

initial begin
	for(i=0; i<GHR_SIZE; i = i+1) begin
		branch_history1[i] <= 2;
		branch_history2[i] <= 2;
		branch_history3[i] <= 2;
		branch_history4[i] <= 2;
	end
	GHR1 <= 8'b11111111;
	GHR2 <= 8'b11111111;
	GHR3 <= 8'b11111111;
	GHR4 <= 8'b11111111;
end

always @(posedge i_Clk)
begin
	//-------first reconcile branch(es) for all threads from 2(?) cycles ago---------
	//thread1
	if((i_ALU_outcome[0] != i_ALU_prediction[0]) && i_ALU_isbranch[0])
	begin
		case(i_ALU_prediction[0])
			0:
			begin
				branch_history1[GHR_saved1] <= branch_history1[GHR_saved1] + 2;	//+2 to compensate for incorrect -1
				GHR1[1:0] <= {1'b1, GHR_index1[1]};								//shift in corrected old guess and current prediction
				end
			1:
			begin
				branch_history1[GHR_saved1] <= branch_history1[GHR_saved1] - 2;	//-2 to compensate for incorrect +1
				GHR1[1:0] <= {1'b0, GHR_index1[1]};								//shift in corrected old guess and current prediction
			end
		endcase
	end

	//thread2
	if((i_ALU_outcome[1] != i_ALU_prediction[1]) && i_ALU_isbranch[1])
	begin
		case(i_ALU_prediction[1])
			0:
			begin
				branch_history2[GHR_saved2] <= branch_history2[GHR_saved2] + 2;		//+2 to compensate for incorrect -1
				GHR2[1:0] <= {1'b1, GHR_index2[1]};								//shift in corrected old guess and current prediction
				end
			1:
			begin
				branch_history2[GHR_saved2] <= branch_history2[GHR_saved2] - 2;		//-2 to compensate for incorrect +1
				GHR2[1:0] <= {1'b0, GHR_index2[1]};								//shift in corrected old guess and current prediction
			end
		endcase
	end

	//thread3
	if((i_ALU_outcome[2] != i_ALU_prediction[2]) && i_ALU_isbranch[2])
	begin
		case(i_ALU_prediction[2])
			0:
			begin
				branch_history3[GHR_saved3] <= branch_history3[GHR_saved3] + 2;		//+2 to compensate for incorrect -1
				GHR3[1:0] <= {1'b1, GHR_index3[1]};								//shift in corrected old guess and current prediction
				end
			1:
			begin
				branch_history3[GHR_saved3] <= branch_history3[GHR_saved3] - 2;		//-2 to compensate for incorrect +1
				GHR3[1:0] <= {1'b0, GHR_index3[1]};								//shift in corrected old guess and current prediction
			end
		endcase
	end

	//thread4
	if((i_ALU_outcome[3] != i_ALU_prediction[3]) && i_ALU_isbranch[3])
	begin
		case(i_ALU_prediction[3])
			0:
			begin
				branch_history4[GHR_saved4] <= branch_history4[GHR_saved4] + 2;		//+2 to compensate for incorrect -1
				GHR4[1:0] <= {1'b1, GHR_index4[1]};								//shift in corrected old guess and current prediction
				end
			1:
			begin
				branch_history4[GHR_saved4] <= branch_history4[GHR_saved4] - 2;		//-2 to compensate for incorrect +1
				GHR4[1:0] <= {1'b0, GHR_index4[1]};								//shift in corrected old guess and current prediction
			end
		endcase
	end



	//------then handle prediction for current branch--------
	case(i_thread)
		0:
		begin
			//first save GHR XOR addr for indexing - nonblocking!
			GHR_saved1 <= gshare_index1;

			//then shift in prediction
			GHR1 <= {GHR1[GHR_SIZE-2:0], gshare_counter1[1]};

			//and update bimodal counter to reflect current branch
			case(gshare_counter1[1])
				0:
				begin
						branch_history1[gshare_index1] <= branch_history1[gshare_index1] + 1;
				end
				1:
				begin
						branch_history1[gshare_index1] <= branch_history1[gshare_index1] - 1;
				end
			endcase
		end

		1:
		begin
			//first save GHR XOR addr for indexing - nonblocking!
			GHR_saved2 <= gshare_index2;

			//then shift in prediction
			GHR2 <= {GHR2[GHR_SIZE-2:0], gshare_counter2[1]};

			//and update bimodal counter to reflect current branch
			case(gshare_counter2[1])
				0:
				begin
						branch_history2[gshare_index2] <= branch_history2[gshare_index2] + 1;
				end
				1:
				begin
						branch_history2[gshare_index2] <= branch_history2[gshare_index2] - 1;
				end
			endcase
		end

		2:
		begin
			//first save GHR XOR addr for indexing - nonblocking!
			GHR_saved3 <= gshare_index3;

			//then shift in prediction
			GHR3 <= {GHR3[GHR_SIZE-2:0], gshare_counter3[1]};

			//and update bimodal counter to reflect current branch
			case(gshare_counter3[1])
				0:
				begin
						branch_history3[gshare_index3] <= branch_history3[gshare_index3] + 1;
				end
				1:
				begin
						branch_history3[gshare_index3] <= branch_history3[gshare_index3] - 1;
				end
			endcase
		end

		3:
		begin
			//first save GHR XOR addr for indexing - nonblocking!
			GHR_saved4 <= gshare_index4;

			//then shift in prediction
			GHR4 <= {GHR4[GHR_SIZE-2:0], gshare_counter4[1]};

			//and update bimodal counter to reflect current branch
			case(gshare_counter4[1])
				0:
				begin
						branch_history4[gshare_index4] <= branch_history4[gshare_index4] + 1;
				end
				1:
				begin
						branch_history4[gshare_index4] <= branch_history4[gshare_index4] - 1;
				end
			endcase
		end
	endcase
end

//Drive output prediction
always@(*)
begin
	case(i_thread)
		0:
		begin
			o_taken <= gshare_counter1[1];
		end

		1:
		begin
			o_taken <= gshare_counter2[1];
		end

		2:
		begin
			o_taken <= gshare_counter3[1];
		end

		3:
		begin
			o_taken <= gshare_counter4[1];
		end
		default:
		begin
			o_taken <= 0;
		end
	endcase
end
endmodule