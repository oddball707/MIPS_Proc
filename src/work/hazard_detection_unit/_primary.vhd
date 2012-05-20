library verilog;
use verilog.vl_types.all;
entity hazard_detection_unit is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : integer := 32;
        REG_ADDR_WIDTH  : integer := 5
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_FlashLoader_Done: in     vl_logic;
        i_Done          : in     vl_logic;
        i_DEC_Uses_RS   : in     vl_logic;
        i_DEC_RS_Addr   : in     vl_logic_vector;
        i_DEC_Uses_RT   : in     vl_logic;
        i_DEC_RT_Addr   : in     vl_logic_vector;
        i_DEC_Branch_Instruction: in     vl_logic;
        i_IF_Done       : in     vl_logic;
        i_EX_Writes_Back: in     vl_logic;
        i_EX_Uses_Mem   : in     vl_logic;
        i_EX_Write_Addr : in     vl_logic_vector;
        i_EX_Branch     : in     vl_logic;
        i_EX_Branch_Target: in     vl_logic_vector;
        i_MEM_Uses_Mem  : in     vl_logic;
        i_MEM_Writes_Back: in     vl_logic;
        i_MEM_Write_Addr: in     vl_logic_vector;
        i_MEM_Done      : in     vl_logic;
        i_WB_Writes_Back: in     vl_logic;
        i_WB_Write_Addr : in     vl_logic_vector;
        o_IF_Branch     : out    vl_logic;
        o_IF_Branch_Target: out    vl_logic_vector;
        o_IF_Stall      : out    vl_logic;
        o_IF_Smash      : out    vl_logic;
        o_DEC_Stall     : out    vl_logic;
        o_DEC_Smash     : out    vl_logic;
        o_EX_Stall      : out    vl_logic;
        o_EX_Smash      : out    vl_logic;
        o_MEM_Stall     : out    vl_logic;
        o_MEM_Smash     : out    vl_logic;
        o_WB_Stall      : out    vl_logic;
        o_WB_Smash      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_ADDR_WIDTH : constant is 1;
end hazard_detection_unit;
