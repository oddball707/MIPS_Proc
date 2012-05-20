library verilog;
use verilog.vl_types.all;
entity pipe_dec_ex is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32;
        REG_ADDR_WIDTH  : integer := 5;
        ALU_CTLCODE_WIDTH: integer := 8;
        MEM_MASK_WIDTH  : integer := 3
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Flush         : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_PC            : in     vl_logic_vector;
        o_PC            : out    vl_logic_vector;
        i_Uses_ALU      : in     vl_logic;
        o_Uses_ALU      : out    vl_logic;
        i_ALUCTL        : in     vl_logic_vector;
        o_ALUCTL        : out    vl_logic_vector;
        i_Is_Branch     : in     vl_logic;
        o_Is_Branch     : out    vl_logic;
        i_Mem_Valid     : in     vl_logic;
        o_Mem_Valid     : out    vl_logic;
        i_Mem_Mask      : in     vl_logic_vector;
        o_Mem_Mask      : out    vl_logic_vector;
        i_Mem_Read_Write_n: in     vl_logic;
        o_Mem_Read_Write_n: out    vl_logic;
        i_Mem_Write_Data: in     vl_logic_vector;
        o_Mem_Write_Data: out    vl_logic_vector;
        i_Writes_Back   : in     vl_logic;
        o_Writes_Back   : out    vl_logic;
        i_Write_Addr    : in     vl_logic_vector;
        o_Write_Addr    : out    vl_logic_vector;
        i_Operand1      : in     vl_logic_vector;
        o_Operand1      : out    vl_logic_vector;
        i_Operand2      : in     vl_logic_vector;
        o_Operand2      : out    vl_logic_vector;
        i_Branch_Target : in     vl_logic_vector;
        o_Branch_Target : out    vl_logic_vector;
        i_prediction    : in     vl_logic;
        o_prediction    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ALU_CTLCODE_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_MASK_WIDTH : constant is 1;
end pipe_dec_ex;
