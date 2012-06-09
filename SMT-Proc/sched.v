module schedule
  #(parameter IN_INSN_WIDTH=100,
    parameter OUT_INSN_WIDTH=101,
    parameter ADDR_WIDTH=22)
  (input [16*IN_INSN_WIDTH-1:0] i_Insns,
   input [15:0] i_Valid,
   output reg [4*OUT_INSN_WIDTH-1:0] o_Insns,
   output [3:0] o_Stall,
   output [7:0] o_Advance);

   localparam IS_BRANCH_OFFSET = 9;
   localparam IS_MEM_OFFSET = 1 + 8 + 1 + ADDR_WIDTH + 1;

   /* Base cases */
   wire got_branch_0_1 = 0, got_mem_0_1 = 0, got_two_mem_0_1 = 0;
   wire [3:0] valid_0_1 = 4'b0000;
   wire [4*OUT_INSN_WIDTH-1:0] insns_0_1 = 0;
   
   wire got_branch_1_2, got_branch_2_3, got_branch_3_4, got_branch;
   wire got_mem_1_2, got_mem_2_3, got_mem_3_4, got_mem;
   wire got_two_mem_1_2, got_two_mem_2_3, got_two_mem_3_4, got_two_mem;
   wire [3:0] valid_1_2, valid_2_3, valid_3_4, valid;
   wire [4*OUT_INSN_WIDTH-1:0] insns_1_2, insns_2_3, insns_3_4, insns;

   wire                        stall_0, stall_1, stall_2, stall_3;
   wire [1:0]                  adv_0, adv_1, adv_2, adv_3;

   assign o_Stall = {stall_3, stall_2, stall_1, stall_0};
   assign o_Advance = {adv_3, adv_2, adv_1, adv_0};

   always @(*) begin
      // Move load-store instructions to mem slots (slots 2 and 3)

      // Check slot 0 for mem instruction
      if (o_Insns[IS_MEM_OFFSET]) begin
         if (o_Insns[2*OUT_INSN_WIDTH+IS_MEM_OFFSET]) begin
            // swap 0 and 3
            o_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH] <= o_Insns[OUT_INSN_WIDTH-1:0];
            o_Insns[OUT_INSN_WIDTH-1:0] <= o_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH];
         end else begin
            // swap 0 and 2
            o_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH] <= o_Insns[OUT_INSN_WIDTH-1:0];
            o_Insns[OUT_INSN_WIDTH-1:0] <= o_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH];
         end
      end

      // Check slot 1 for mem instruction
      if (o_Insns[OUT_INSN_WIDTH+IS_MEM_OFFSET]) begin
         if (o_Insns[2*OUT_INSN_WIDTH+IS_MEM_OFFSET]) begin
            // swap 1 and 3
            o_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH] <= o_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH];
            o_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH] <= o_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH];
         end else begin
            // swap 1 and 2
            o_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH] <= o_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH];
            o_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH] <= o_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH];
         end
      end

      // Check slot 1 for branch instruction
      if (o_Insns[OUT_INSN_WIDTH+IS_BRANCH_OFFSET]) begin
         o_Insns[OUT_INSN_WIDTH-1:0] <= o_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH];
         o_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH] <= o_Insns[OUT_INSN_WIDTH-1:0];
      end

      // Check slot 2 for branch instruction
      if (o_Insns[2*OUT_INSN_WIDTH+IS_BRANCH_OFFSET]) begin
         o_Insns[OUT_INSN_WIDTH-1:0] <= o_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH];
         o_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH] <= o_Insns[OUT_INSN_WIDTH-1:0];
      end
         
      // Check slot 3 for branch instruction
      if (o_Insns[3*OUT_INSN_WIDTH+IS_BRANCH_OFFSET]) begin
         o_Insns[OUT_INSN_WIDTH-1:0] <= o_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH];
         o_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH] <= o_Insns[OUT_INSN_WIDTH-1:0];
      end
   end
   
   schedule_thread #(.THD_ID(0)) thd0_sched(got_branch_0_1,
                                            got_mem_0_1,
                                            got_two_mem_0_1,
                                            i_Insns[4*IN_INSN_WIDTH-1:0],
                                            i_Valid[3:0],
                                            insns_0_1,
                                            valid_0_1,
                                            got_branch_1_2,
                                            got_mem_1_2,
                                            got_two_mem_1_2,
                                            insns_1_2,
                                            valid_1_2,
                                            stall_0,
                                            adv_0);
   
   schedule_thread #(.THD_ID(1)) thd1_sched(got_branch_1_2,
                                            got_mem_1_2,
                                            got_two_mem_1_2,
                                            i_Insns[8*IN_INSN_WIDTH-1:4*IN_INSN_WIDTH],
                                            i_Valid[7:4],
                                            insns_1_2,
                                            valid_1_2,
                                            got_branch_2_3,
                                            got_mem_2_3,
                                            got_two_mem_2_3,
                                            insns_2_3,
                                            valid_2_3,
                                            stall_1,
                                            adv_1);
   
   schedule_thread #(.THD_ID(2)) thd2_sched(got_branch_2_3,
                                            got_mem_2_3,
                                            got_two_mem_2_3,
                                            i_Insns[12*IN_INSN_WIDTH-1:8*IN_INSN_WIDTH],
                                            i_Valid[11:8],
                                            insns_2_3,
                                            valid_2_3,
                                            got_branch_3_4,
                                            got_mem_3_4,
                                            got_two_mem_3_4,
                                            insns_3_4,
                                            valid_3_4,
                                            stall_2,
                                            adv_2);
   
   schedule_thread #(.THD_ID(2)) thd3_sched(got_branch_3_4,
                                            got_mem_3_4,
                                            got_two_mem_3_4,
                                            i_Insns[16*IN_INSN_WIDTH-1:12*IN_INSN_WIDTH],
                                            i_Valid[15:12],
                                            insns_3_4,
                                            valid_3_4,
                                            got_branch,
                                            got_mem,
                                            got_two_mem,
                                            insns,
                                            valid,
                                            stall_3,
                                            adv_3);

endmodule

module schedule_thread
  #(parameter THD_ID=0,
    parameter IN_INSN_WIDTH=100,
    parameter OUT_INSN_WIDTH=101,
    parameter ADDR_WIDTH=22)
   (input i_Got_Branch,
    input i_Got_Mem,
    input i_Got_Two_Mem,
    input [4*IN_INSN_WIDTH-1:0] i_Thd_Insns,
    input [3:0] i_Thd_Valid,
    input [4*OUT_INSN_WIDTH-1:0] i_Insns,
    input [3:0] i_Valid,
    output reg o_Got_Branch,
    output reg o_Got_Mem,
    output reg o_Got_Two_Mem,
    output reg [4*OUT_INSN_WIDTH-1:0] o_Insns,
    output reg [3:0] o_Valid,
    output reg o_IQ_Stall,
    output reg [1:0] o_IQ_Advance);

   localparam IS_MEM_OFFSET = 1 + 8 + 1 + ADDR_WIDTH + 1;

   reg [4*OUT_INSN_WIDTH-1:0] thd_insns;
   wire                       is_branch_0 = i_Thd_Insns[9];
   wire                       is_branch_1 = i_Thd_Insns[IN_INSN_WIDTH+9];
   wire                       is_branch_2 = i_Thd_Insns[2*IN_INSN_WIDTH+9];
   wire                       is_branch_3 = i_Thd_Insns[3*IN_INSN_WIDTH+9];
   
   wire                       is_mem_0 = i_Thd_Insns[IS_MEM_OFFSET];
   wire                       is_mem_1 = i_Thd_Insns[IN_INSN_WIDTH+IS_MEM_OFFSET];
   wire                       is_mem_2 = i_Thd_Insns[2*IN_INSN_WIDTH+IS_MEM_OFFSET];
   wire                       is_mem_3 = i_Thd_Insns[3*IN_INSN_WIDTH+IS_MEM_OFFSET];

   wire [OUT_INSN_WIDTH-1:0]  in_insn_0 = i_Insns[OUT_INSN_WIDTH-1:0];
   wire [OUT_INSN_WIDTH-1:0]  in_insn_1 = i_Insns[2*OUT_INSN_WIDTH-1:OUT_INSN_WIDTH];
   wire [OUT_INSN_WIDTH-1:0]  in_insn_2 = i_Insns[3*OUT_INSN_WIDTH-1:2*OUT_INSN_WIDTH];
   wire [OUT_INSN_WIDTH-1:0]  in_insn_3 = i_Insns[4*OUT_INSN_WIDTH-1:3*OUT_INSN_WIDTH];

   // Strip continuation (bundle) bit, add thread ID
   wire [1:0]                 thd_id = THD_ID;
   wire [OUT_INSN_WIDTH-1:0]  thd_insn_0 = {thd_id, i_Thd_Insns[IN_INSN_WIDTH-2:0]};
   wire [OUT_INSN_WIDTH-1:0]  thd_insn_1 = {thd_id, i_Thd_Insns[2*IN_INSN_WIDTH-2:IN_INSN_WIDTH]};
   wire [OUT_INSN_WIDTH-1:0]  thd_insn_2 = {thd_id, i_Thd_Insns[3*IN_INSN_WIDTH-2:2*IN_INSN_WIDTH]};
   wire [OUT_INSN_WIDTH-1:0]  thd_insn_3 = {thd_id, i_Thd_Insns[4*IN_INSN_WIDTH-2:3*IN_INSN_WIDTH]};

   
   reg                        block_0, block_1, block_2, block_3;
   reg [3:0]                  valid;

   always @(*) begin
      block_0 = ~i_Thd_Insns[99];
      block_1 = ~i_Thd_Insns[IN_INSN_WIDTH+99];
      block_2 = ~i_Thd_Insns[2*IN_INSN_WIDTH+99];
      block_3 = ~i_Thd_Insns[3*IN_INSN_WIDTH+99];

      o_Got_Branch = i_Got_Branch;
      o_Got_Mem = i_Got_Mem;
      o_Got_Two_Mem = i_Got_Two_Mem;

      if (is_branch_0) begin
         if (o_Got_Branch) block_0 = 1;
         else o_Got_Branch = 1;
      end else if (is_mem_0) begin
         if (o_Got_Two_Mem) block_0 = 1;
         else if (o_Got_Mem) o_Got_Two_Mem = 1;
         else o_Got_Mem = 1;
      end
      
      if (is_branch_1) begin
         if (o_Got_Branch) block_1 = 1;
         else o_Got_Branch = 1;
      end else if (is_mem_1) begin
         if (o_Got_Two_Mem) block_1 = 1;
         else if (o_Got_Mem) o_Got_Two_Mem = 1;
         else o_Got_Mem = 1;
      end
      
      if (is_branch_2) begin
         if (o_Got_Branch) block_2 = 1;
         else o_Got_Branch = 1;
      end else if (is_mem_2) begin
         if (o_Got_Two_Mem) block_2 = 1;
         else if (o_Got_Mem) o_Got_Two_Mem = 1;
         else o_Got_Mem = 1;
      end
      
      if (is_branch_3) begin
         if (o_Got_Branch) block_3 = 1;
         else o_Got_Branch = 1;
      end else if (is_mem_3) begin
         if (o_Got_Two_Mem) block_3 = 1;
         else if (o_Got_Mem) o_Got_Two_Mem = 1;
         else o_Got_Mem = 1;
      end

      valid = i_Thd_Valid;

      if (block_0) begin
         valid[0] = 0;
         valid[1] = 0;
         valid[2] = 0;
         valid[3] = 0;
      end else if (block_1) begin
         valid[1] = 0;
         valid[2] = 0;
         valid[3] = 0;
      end else if (block_2) begin
         valid[2] = 0;
         valid[3] = 0;
      end else if (block_3) begin
         valid[3] = 0;
      end

      if (i_Valid[3]) begin
         o_IQ_Stall = 1;
         o_IQ_Advance = 0;
         o_Insns = i_Insns;
         o_Valid = i_Valid; // 1111
      end else if (i_Valid[2]) begin
         o_IQ_Stall = 0;
         o_IQ_Advance = 0;
         o_Insns = {thd_insn_0, in_insn_2, in_insn_1, in_insn_0};
         o_Valid = {valid[0], i_Valid[2:0]};
      end else if (i_Valid[1]) begin
         o_IQ_Stall = 0;
         o_IQ_Advance = 1;
         o_Insns = {thd_insn_1, thd_insn_0, in_insn_1, in_insn_0};
         o_Valid = {valid[1:0], i_Valid[1:0]};
      end else if (i_Valid[0]) begin
         o_IQ_Stall = 0;
         o_IQ_Advance = 2;
         o_Insns = {thd_insn_2, thd_insn_1, thd_insn_0, in_insn_0};
         o_Valid = {valid[2:0], i_Valid[0]};
      end else begin
         o_IQ_Stall = 0;
         o_IQ_Advance = 3;
         o_Insns = {thd_insn_3, thd_insn_2, thd_insn_1, thd_insn_0};
         o_Valid = valid;
      end
   end
endmodule
