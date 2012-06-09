module regfile
  #(parameter DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 7)
   (input i_Clk,
    input i_Rst_n,
    input [8*REG_ADDR_WIDTH-1:0] i_Read_Addr,
    input [3:0] i_Write_Enable,
    input [4*REG_ADDR_WIDTH-1:0] i_Write_Addr,
    input [DATA_WIDTH-1:0] i_Write_Data,
    output [8*DATA_WIDTH-1:0] o_Read_Data);
   
   reg [DATA_WIDTH-1:0]          Data[0:(2**REG_ADDR_WIDTH)-1];

   integer                       i;
   
   always @(posedge i_Clk or negedge i_Rst_n) begin
      if (!i_Rst_n) begin
         for (i = 0; i < 2**REG_ADDR_WIDTH; i = i + 1)
           Data[i] <= 0;
      end else begin
         if (i_Write_Enable[0] && (i_Write_Addr[REG_ADDR_WIDTH-1:0] != 0))
           Data[i_Write_Addr[REG_ADDR_WIDTH-1:0]] <= i_Write_Data[DATA_WIDTH-1:0];
         if (i_Write_Enable[1] && (i_Write_Addr[2*REG_ADDR_WIDTH-1:REG_ADDR_WIDTH] != 0))
           Data[i_Write_Addr[2*REG_ADDR_WIDTH-1:REG_ADDR_WIDTH]] <= i_Write_Data[2*DATA_WIDTH-1:DATA_WIDTH];
         if (i_Write_Enable[2] && (i_Write_Addr[3*REG_ADDR_WIDTH-1:2*REG_ADDR_WIDTH] != 0))
           Data[i_Write_Addr[3*REG_ADDR_WIDTH-1:2*REG_ADDR_WIDTH]] <= i_Write_Data[3*DATA_WIDTH-1:2*DATA_WIDTH];
         if (i_Write_Enable[3] && (i_Write_Addr[4*REG_ADDR_WIDTH-1:3*REG_ADDR_WIDTH] != 0))
           Data[i_Write_Addr[4*REG_ADDR_WIDTH-1:3*REG_ADDR_WIDTH]] <= i_Write_Data[4*DATA_WIDTH-1:3*DATA_WIDTH];
      end
   end
   
  wire [REG_ADDR_WIDTH-1:0] Reg0 = i_Read_Addr[REG_ADDR_WIDTH-1:0];
  reg Result0;
  wire [REG_ADDR_WIDTH-1:0] Reg1 = i_Read_Addr[2*REG_ADDR_WIDTH-1:REG_ADDR_WIDTH];
  reg Result1;
  wire [REG_ADDR_WIDTH-1:0] Reg2 = i_Read_Addr[3*REG_ADDR_WIDTH-1:2*REG_ADDR_WIDTH];
  reg Result2;
  wire [REG_ADDR_WIDTH-1:0] Reg3 = i_Read_Addr[4*REG_ADDR_WIDTH-1:3*REG_ADDR_WIDTH];
  reg Result3;
  wire [REG_ADDR_WIDTH-1:0] Reg4 = i_Read_Addr[5*REG_ADDR_WIDTH-1:4*REG_ADDR_WIDTH];
  reg Result4;
  wire [REG_ADDR_WIDTH-1:0] Reg5 = i_Read_Addr[6*REG_ADDR_WIDTH-1:5*REG_ADDR_WIDTH];
  reg Result5;
  wire [REG_ADDR_WIDTH-1:0] Reg6 = i_Read_Addr[7*REG_ADDR_WIDTH-1:6*REG_ADDR_WIDTH];
  reg Result6;
  wire [REG_ADDR_WIDTH-1:0] Reg7 = i_Read_Addr[8*REG_ADDR_WIDTH-1:7*REG_ADDR_WIDTH];
  reg Result7;
  always @(*) begin
    Result0 = Data[Reg0];
    if (i_Write_Enable[0] && i_Read_Addr[Reg0])
      Result0 = i_Write_Data[DATA_WIDTH-1:0];
    if (i_Write_Enable[0] && i_Read_Addr[Reg0])
      Result0 = i_Write_Data[DATA_WIDTH-1:0];
    if (i_Write_Enable[0] && i_Read_Addr[Reg0])
      Result0 = i_Write_Data[DATA_WIDTH-1:0];
    if (i_Write_Enable[0] && i_Read_Addr[Reg0])
      Result0 = i_Write_Data[DATA_WIDTH-1:0];
    Result1 = Data[Reg1];
    if (i_Write_Enable[1] && i_Read_Addr[Reg1])
      Result1 = i_Write_Data[2*DATA_WIDTH-1:DATA_WIDTH];
    if (i_Write_Enable[1] && i_Read_Addr[Reg1])
      Result1 = i_Write_Data[2*DATA_WIDTH-1:DATA_WIDTH];
    if (i_Write_Enable[1] && i_Read_Addr[Reg1])
      Result1 = i_Write_Data[2*DATA_WIDTH-1:DATA_WIDTH];
    if (i_Write_Enable[1] && i_Read_Addr[Reg1])
      Result1 = i_Write_Data[2*DATA_WIDTH-1:DATA_WIDTH];
    Result2 = Data[Reg2];
    if (i_Write_Enable[2] && i_Read_Addr[Reg2])
      Result2 = i_Write_Data[3*DATA_WIDTH-1:2*DATA_WIDTH];
    if (i_Write_Enable[2] && i_Read_Addr[Reg2])
      Result2 = i_Write_Data[3*DATA_WIDTH-1:2*DATA_WIDTH];
    if (i_Write_Enable[2] && i_Read_Addr[Reg2])
      Result2 = i_Write_Data[3*DATA_WIDTH-1:2*DATA_WIDTH];
    if (i_Write_Enable[2] && i_Read_Addr[Reg2])
      Result2 = i_Write_Data[3*DATA_WIDTH-1:2*DATA_WIDTH];
    Result3 = Data[Reg3];
    if (i_Write_Enable[3] && i_Read_Addr[Reg3])
      Result3 = i_Write_Data[4*DATA_WIDTH-1:3*DATA_WIDTH];
    if (i_Write_Enable[3] && i_Read_Addr[Reg3])
      Result3 = i_Write_Data[4*DATA_WIDTH-1:3*DATA_WIDTH];
    if (i_Write_Enable[3] && i_Read_Addr[Reg3])
      Result3 = i_Write_Data[4*DATA_WIDTH-1:3*DATA_WIDTH];
    if (i_Write_Enable[3] && i_Read_Addr[Reg3])
      Result3 = i_Write_Data[4*DATA_WIDTH-1:3*DATA_WIDTH];
    Result4 = Data[Reg4];
    if (i_Write_Enable[4] && i_Read_Addr[Reg4])
      Result4 = i_Write_Data[5*DATA_WIDTH-1:4*DATA_WIDTH];
    if (i_Write_Enable[4] && i_Read_Addr[Reg4])
      Result4 = i_Write_Data[5*DATA_WIDTH-1:4*DATA_WIDTH];
    if (i_Write_Enable[4] && i_Read_Addr[Reg4])
      Result4 = i_Write_Data[5*DATA_WIDTH-1:4*DATA_WIDTH];
    if (i_Write_Enable[4] && i_Read_Addr[Reg4])
      Result4 = i_Write_Data[5*DATA_WIDTH-1:4*DATA_WIDTH];
    Result5 = Data[Reg5];
    if (i_Write_Enable[5] && i_Read_Addr[Reg5])
      Result5 = i_Write_Data[6*DATA_WIDTH-1:5*DATA_WIDTH];
    if (i_Write_Enable[5] && i_Read_Addr[Reg5])
      Result5 = i_Write_Data[6*DATA_WIDTH-1:5*DATA_WIDTH];
    if (i_Write_Enable[5] && i_Read_Addr[Reg5])
      Result5 = i_Write_Data[6*DATA_WIDTH-1:5*DATA_WIDTH];
    if (i_Write_Enable[5] && i_Read_Addr[Reg5])
      Result5 = i_Write_Data[6*DATA_WIDTH-1:5*DATA_WIDTH];
    Result6 = Data[Reg6];
    if (i_Write_Enable[6] && i_Read_Addr[Reg6])
      Result6 = i_Write_Data[7*DATA_WIDTH-1:6*DATA_WIDTH];
    if (i_Write_Enable[6] && i_Read_Addr[Reg6])
      Result6 = i_Write_Data[7*DATA_WIDTH-1:6*DATA_WIDTH];
    if (i_Write_Enable[6] && i_Read_Addr[Reg6])
      Result6 = i_Write_Data[7*DATA_WIDTH-1:6*DATA_WIDTH];
    if (i_Write_Enable[6] && i_Read_Addr[Reg6])
      Result6 = i_Write_Data[7*DATA_WIDTH-1:6*DATA_WIDTH];
    Result7 = Data[Reg7];
    if (i_Write_Enable[7] && i_Read_Addr[Reg7])
      Result7 = i_Write_Data[8*DATA_WIDTH-1:7*DATA_WIDTH];
    if (i_Write_Enable[7] && i_Read_Addr[Reg7])
      Result7 = i_Write_Data[8*DATA_WIDTH-1:7*DATA_WIDTH];
    if (i_Write_Enable[7] && i_Read_Addr[Reg7])
      Result7 = i_Write_Data[8*DATA_WIDTH-1:7*DATA_WIDTH];
    if (i_Write_Enable[7] && i_Read_Addr[Reg7])
      Result7 = i_Write_Data[8*DATA_WIDTH-1:7*DATA_WIDTH];
  end
  assign o_Read_Data = {Result7, Result6, Result5, Result4, Result3, Result2, Result1, Result0};
endmodule