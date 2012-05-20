library verilog;
use verilog.vl_types.all;
entity decoder is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32;
        REG_ADDRESS_WIDTH: integer := 5;
        ALUCTL_WIDTH    : integer := 8;
        MEM_MASK_WIDTH  : integer := 3;
        DEBUG           : integer := 0
    );
    port(
        i_PC            : in     vl_logic_vector;
        i_Instruction   : in     vl_logic_vector;
        i_Stall         : in     vl_logic;
        o_Uses_ALU      : out    vl_logic;
        o_ALUCTL        : out    vl_logic_vector;
        o_Is_Branch     : out    vl_logic;
        o_Branch_Target : out    vl_logic_vector;
        o_Jump_Reg      : out    vl_logic;
        o_Mem_Valid     : out    vl_logic;
        o_Mem_Mask      : out    vl_logic_vector;
        o_Mem_Read_Write_n: out    vl_logic;
        o_Uses_RS       : out    vl_logic;
        o_RS_Addr       : out    vl_logic_vector;
        o_Uses_RT       : out    vl_logic;
        o_RT_Addr       : out    vl_logic_vector;
        o_Uses_Immediate: out    vl_logic;
        o_Immediate     : out    vl_logic_vector;
        o_Writes_Back   : out    vl_logic;
        o_Write_Addr    : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ALUCTL_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_MASK_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DEBUG : constant is 1;
end decoder;
