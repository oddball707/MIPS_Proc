module insn_mixer #(parameter INSN_WIDTH = 99)
   (input [INSN_WIDTH*16-1:0] i_Insns,
    input [15:0] i_Valid,
    input [4:0] i_Ordering,
    output [INSN_WIDTH*4-1:0] o_Insns,
    output [4:0] o_Valid);

   localparam W = INSN_WIDTH; // short-hand
   
   // We generate insnructions and valid bits individually, then combine before returning.
   reg [W-1:0]   insn_1, insn_2, insn_3, insn_4;
   reg           valid_1, valid_2, valid_3, valid_4;
   assign o_Insns = {insn_4, insn_3, insn_2, insn_1};
   assign o_Valid = {valid_4, valid_3, valid_2, valid_1};
   
   
   // Similarly, split insnruction and validity vectors by thread before examining
   reg [3:0]     thd1_valid, thd2_valid, thd3_valid, thd4_valid;
   reg [W*4-1:0] thd1_insns, thd2_insns, thd3_insns, thd4_insns;
   
   // Common subexpressions.
   reg           thd1_two_valid, thd1_three_valid, thd1_four_valid, thd2_two_valid, thd2_three_valid, thd2_four_valid;
   reg           thd3_two_valid, thd3_three_valid, thd3_four_valid, thd4_two_valid, thd4_three_valid, thd4_four_valid;
   reg           thd1_one_valid_only, thd1_two_valid_only, thd1_three_valid_only, thd2_one_valid_only, thd2_two_valid_only, thd2_three_valid_only;
   reg           thd3_one_valid_only, thd3_two_valid_only, thd3_three_valid_only, thd4_one_valid_only, thd4_two_valid_only, thd4_three_valid_only;
   
   reg [W*12-1:0] insns_second_pass; // three threads remaining
   reg [W*8-1:0]  insns_third_pass; // two threads remaining
   reg [11:0]     valid_second_pass; 
   reg [7:0]      valid_third_pass;
   
   always @(*) begin
      // Choose first thread
      case (i_Ordering[4:3])
        2'b00: begin
           thd1_insns = i_Insns[W*4-1:0];
           thd1_valid = i_Valid[3:0];
           insns_second_pass = i_Insns[W*16-1:W*4]; // {4, 3, 2}
           valid_second_pass = i_Valid[15:4];
        end
        2'b01: begin
           thd1_insns = i_Insns[W*8-1:W*4];
           thd1_valid = i_Valid[7:4];
           insns_second_pass = {i_Insns[W*16-1:W*8], i_Insns[W*4-1:0]}; // {4, 3, 1}
           valid_second_pass = {i_Valid[15:8], i_Valid[3:0]};
        end
        2'b10: begin
           thd1_insns = i_Insns[W*12-1:W*8];
           thd1_valid = i_Valid[11:8];
           insns_second_pass = {i_Insns[W*16-1:W*12], i_Insns[W*8-1:0]}; // {4, 2, 1}
           valid_second_pass = {i_Valid[15:12], i_Valid[7:0]};
        end
        2'b11: begin
           thd1_insns = i_Insns[W*16-1:W*12];
           thd1_valid = i_Valid[15:12];
           insns_second_pass = i_Insns[W*12-1:0]; // {3, 2, 1}
           valid_second_pass = i_Valid[11:0];
        end
      endcase
      
      // Choose second thread
      casex (i_Ordering[2:1])
        2'b00: begin
           thd2_insns = insns_second_pass[W*4-1:0];
           thd2_valid = valid_second_pass[3:0];
           insns_third_pass = insns_second_pass[W*12-1:W*4]; // {3, 2}
           valid_third_pass = valid_second_pass[11:4];
        end
        2'b01: begin
           thd2_insns = insns_second_pass[W*8-1:W*4];
           thd2_valid = insns_second_pass[7:4];
           insns_third_pass = {insns_second_pass[W*12-1:W*8], insns_second_pass[W*4-1:0]}; // {3, 1}
           valid_third_pass = {valid_second_pass[11:8], insns_second_pass[3:0]};
        end
        2'b1x: begin
           thd2_insns = insns_second_pass[W*12-1:W*8];
           thd2_valid = valid_second_pass[11:8];
           insns_third_pass = insns_second_pass[W*8-1:0]; // {2, 1}
           valid_third_pass = valid_second_pass[7:0];
        end
      endcase

      // Choose last two threads
      if (i_Ordering[0]) begin
         thd3_insns = insns_third_pass[W*4-1:0];
         thd4_insns = insns_third_pass[W*8-1:W*4];
         thd3_valid = valid_third_pass[3:0];
         thd4_valid = valid_third_pass[7:4];
      end else begin
         thd3_insns = insns_third_pass[W*8-1:W*4];
         thd4_insns = insns_third_pass[W*4-1:0];
         thd3_valid = valid_third_pass[7:4];
         thd4_valid = valid_third_pass[3:0];
      end
      
      // Count the number of valid insnructions from each thread
      thd1_one_valid_only = thd1_valid[0] & ~thd1_valid[1];
      thd1_two_valid = thd1_valid[0] & thd1_valid[1];
      thd1_two_valid_only = thd1_two_valid & ~thd1_valid[2];
      thd1_three_valid = thd1_two_valid & thd1_valid[2];
      thd1_three_valid_only = thd1_three_valid & ~thd1_valid[3];
      thd1_four_valid = thd1_three_valid & thd1_valid[3];
      
      thd2_one_valid_only = thd2_valid[0] & ~thd2_valid[1];
      thd2_two_valid = thd2_valid[0] & thd2_valid[1];
      thd2_two_valid_only = thd2_two_valid & ~thd2_valid[2];
      thd2_three_valid = thd2_two_valid & thd2_valid[2];
      thd2_three_valid_only = thd2_three_valid & ~thd2_valid[3];
      thd2_four_valid = thd2_three_valid & thd2_valid[3];

      thd3_one_valid_only = thd3_valid[0] & ~thd3_valid[1];
      thd3_two_valid = thd3_valid[0] & thd3_valid[1];
      thd3_two_valid_only = thd3_two_valid & ~thd3_valid[2];
      thd3_three_valid = thd3_two_valid & thd3_valid[2];
      thd3_three_valid_only = thd3_three_valid & ~thd3_valid[3];
      thd3_four_valid = thd3_three_valid & thd3_valid[3];
      
      thd4_one_valid_only = thd4_valid[0] & ~thd4_valid[1];
      thd4_two_valid = thd4_valid[0] & thd4_valid[1];
      thd4_two_valid_only = thd4_two_valid & ~thd4_valid[2];
      thd4_three_valid = thd4_two_valid & thd4_valid[2];
      thd4_three_valid_only = thd4_three_valid & ~thd4_valid[3];
      thd4_four_valid = thd4_three_valid & thd4_valid[3];

      insn_1 = 0;
      insn_2 = 0;
      insn_3 = 0;
      insn_4 = 0;
      
      // Assign slot 1
      valid_1 = 1;
      if (thd1_valid[0])      insn_1 = thd1_insns[W-1:0];
      else if (thd2_valid[0]) insn_1 = thd2_insns[W-1:0];
      else if (thd3_valid[0]) insn_1 = thd3_insns[W-1:0];
      else if (thd4_valid[0]) insn_1 = thd4_insns[W-1:0];
      else valid_1 = 0;

      // Assign slot 2
      valid_2 = 1;
      if (thd1_two_valid) insn_2 = thd1_insns[W*2-1:W]; // #1 gets 1 and 2
      else if (thd2_valid[0] & thd1_one_valid_only) insn_2 = thd2_insns[W-1:0]; // #1 gets 1, #2 gets 2
      else if (thd2_two_valid & ~thd1_valid[0]) insn_2 = thd2_insns[W*2-1:W]; // #2 gets 1 and 2
      else if (thd3_valid[0] & ((thd1_one_valid_only & ~thd2_valid[0]) | // one of #1~2 gets 1, #3 gets 2
                                (thd2_one_valid_only & ~thd1_valid[0]))) insn_2 = thd3_insns[W-1:0];
      else if (thd3_two_valid & ~thd1_valid[0] & ~thd2_valid[0]) insn_2 = thd3_insns[W*2-1:W]; // #3 gets 1 and 2
      else if (thd4_valid[0] & ((thd1_one_valid_only & ~thd2_valid[0] & ~thd3_valid[0]) | // one of #1~3 gets 1, #4 gets 2
                                (thd2_one_valid_only & ~thd1_valid[0] & ~thd3_valid[0]) |
                                (thd3_one_valid_only & ~thd1_valid[0] & ~thd2_valid[0]))) insn_2 = thd4_insns[W-1:0];
      else if (thd4_two_valid & ~thd1_valid[0] & ~thd2_valid[0] & ~thd3_valid[0]) insn_2 = thd4_insns[W*2-1:W]; // #4 gets 1 and 2
      else valid_2 = 0;

      // Assign slot 3
      valid_3 = 1;
      if (thd1_three_valid) insn_3 = thd1_insns[W*3-1:W*2]; // #1 gets 1, 2, and 3
      else if (thd2_valid[0] & thd1_two_valid_only) insn_3 = thd2_insns[W-1:0]; // #1 gets 1 and 2, #2 gets 3
      else if (thd2_two_valid & thd1_one_valid_only) insn_3 = thd2_insns[W*2:W]; // #1 gets 1, #2 gets 2 and 3
      else if (thd2_three_valid & ~thd1_valid[0]) insn_3 = thd2_insns[W*3-1:W*2]; // #2 gets 1, 2, and 3
      else if (thd3_valid[0] & ((thd1_two_valid_only & ~thd2_valid[0]) | // #1~2 get first 2 (three cases), #3 gets 3
                                (thd2_two_valid_only & ~thd1_valid[0]) |
                                (thd1_one_valid_only & thd2_one_valid_only))) insn_3 = thd3_insns[W-1:0];
      else if (thd3_two_valid & ((thd1_one_valid_only & ~thd2_valid[0]) | // one of #1~2 gets 1, #3 gets 2 and 3
                                 (thd2_one_valid_only & ~thd1_valid[1]))) insn_3 = thd3_insns[W*2-1:W];
      else if (thd3_three_valid & ~thd1_valid[0] & ~thd2_valid[0]) insn_3 = thd3_insns[W*3-1:W*2];
      else if (thd4_valid[0] & ((thd1_two_valid_only & ~thd2_valid[0] & ~thd3_valid[0]) | // #1~3 get 1 and 2 (six cases), #4 gets 3
                                (thd2_two_valid_only & ~thd1_valid[0] & ~thd3_valid[0]) |
                                (thd3_two_valid_only & ~thd1_valid[0] & ~thd2_valid[0]) |
                                (thd1_one_valid_only & thd2_one_valid_only & ~thd3_valid[0]) |
                                (thd2_one_valid_only & thd3_one_valid_only & ~thd1_valid[0]) |
                                (thd1_one_valid_only & thd3_one_valid_only & ~thd2_valid[0]))) insn_3 = thd4_insns[W-1:0];
      else if (thd4_two_valid & ((thd1_one_valid_only & ~thd2_valid[0] & ~thd3_valid[0]) | // one of #1~3 gets 1, #4 gets 2 and 3
                                 (thd2_one_valid_only & ~thd1_valid[0] & ~thd3_valid[0]) |
                                 (thd3_one_valid_only & ~thd1_valid[0] & ~thd2_valid[0]))) insn_3 = thd4_insns[W*2-1:W];
      else if (thd4_three_valid & ~thd1_valid[0] & ~thd2_valid[0] & ~thd3_valid[0]) insn_4 = thd4_insns[W*3-1:W*2]; // #4 gets 1, 2, and 3
      else valid_3 = 0;

      // Assign slot 4
      valid_4 = 1;
      if (thd1_four_valid) insn_4 = thd1_insns[W*4-1:W*3]; // #1 gets everything
      else if (thd2_valid[0] & thd1_three_valid_only) insn_4 = thd2_insns[W-1:0]; // #1 gets 1~3, #2 gets 4
      else if (thd2_two_valid & thd1_two_valid_only) insn_4 = thd2_insns[W*2-1:W]; // #1 gets 1 and 2, #2 gets 3 and 4
      else if (thd2_three_valid & thd1_one_valid_only) insn_4 = thd2_insns[W*3-1:W*2]; // #1 gets 1~3, #2 gets 4
      else if (thd2_four_valid & ~thd1_valid[0]) insn_4 = thd2_insns[W*4-1:W*3]; // #2 gets everything
      else if (thd3_valid[0] & ((thd1_two_valid_only & thd2_one_valid_only) | // #1~2 get first 3 (two cases), #3 gets 4
                                (thd2_two_valid_only & thd1_one_valid_only))) insn_4 = thd3_insns[W-1:0];
      else if (thd3_two_valid & ((thd1_one_valid_only & thd2_one_valid_only) | // #1~2 get first 2 (three cases), #3 gets 3 and 4
                                 (thd1_two_valid_only & ~thd2_valid[0]) |
                                 (thd2_two_valid_only & ~thd1_valid[0]))) insn_4 = thd3_insns[W*2-1:W];
      else if (thd3_three_valid & ((thd1_one_valid_only & ~thd2_valid[0]) | // one of #1~2 gets 1, #3 gets 2, 3, and 4
                                   (thd2_one_valid_only & ~thd1_valid[0]))) insn_4 = thd3_insns[W*3-1:W*2];
      else if (thd3_four_valid & ~thd1_valid[0] & ~thd2_valid[0]) insn_4 = thd3_insns[W*4-1:W*3]; // #3 gets everything
      else if (thd4_valid[0] & ((thd1_one_valid_only & thd2_one_valid_only & thd3_one_valid_only) | // #1~3 get first three (ten cases), #4 gets 4
                                (thd1_three_valid_only & ~thd2_valid[0] & ~thd3_valid[0]) |
                                (thd2_three_valid_only & ~thd1_valid[0] & ~thd3_valid[0]) |
                                (thd3_three_valid_only & ~thd1_valid[0] & ~thd2_valid[0]) |
                                (thd1_two_valid_only & ((thd2_one_valid_only & ~thd3_valid[0]) |
                                                        (thd3_one_valid_only & ~thd2_valid[0]))) |
                                (thd2_two_valid_only & ((thd1_one_valid_only & ~thd3_valid[0]) |
                                                        (thd3_one_valid_only & ~thd1_valid[0]))) |
                                (thd3_two_valid_only & ((thd1_one_valid_only & ~thd2_valid[0]) |
                                                        (thd2_one_valid_only & ~thd1_valid[0]))))) insn_4 = thd4_insns[W-1:0];
      else if (thd4_two_valid & ((thd1_two_valid_only & ~thd2_valid[0] & ~thd3_valid[0]) | // #1~3 get 1 and 2 (six cases), #4 gets 3 and 4
                                 (thd2_two_valid_only & ~thd1_valid[0] & ~thd3_valid[0]) |
                                 (thd3_two_valid_only & ~thd1_valid[0] & ~thd2_valid[0]) |
                                 (thd1_one_valid_only & thd2_one_valid_only & ~thd3_valid[0]) |
                                 (thd2_one_valid_only & thd3_one_valid_only & ~thd1_valid[0]) |
                                 (thd1_one_valid_only & thd3_one_valid_only & ~thd2_valid[0]))) insn_4 = thd4_insns[W*2-1:W];
      else if (thd4_three_valid & ((thd1_one_valid_only & ~thd2_valid[0] & ~thd3_valid[0]) | // one of #1~3 gets 1, #4 gets 2, 3, and 4
                                   (thd2_one_valid_only & ~thd1_valid[0] & ~thd3_valid[0]) |
                                   (thd3_one_valid_only & ~thd1_valid[0] & ~thd2_valid[0]))) insn_4 = thd4_insns[W*3-1:W*2];
      else if (thd4_four_valid & ~thd1_valid[0] & ~thd2_valid[0] & ~thd3_valid[0]) insn_4 = thd4_insns[W*4-1:W*3]; // #4 gets everything
      else valid_4 = 0;
   end
endmodule