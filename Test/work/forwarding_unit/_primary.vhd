library verilog;
use verilog.vl_types.all;
entity forwarding_unit is
    generic(
        DATA_WIDTH      : integer := 32;
        REG_ADDR_WIDTH  : integer := 5
    );
    port(
        i_DEC_Uses_RS   : in     vl_logic;
        i_DEC_RS_Addr   : in     vl_logic_vector;
        i_DEC_Uses_RT   : in     vl_logic;
        i_DEC_RT_Addr   : in     vl_logic_vector;
        i_DEC_RS_Data   : in     vl_logic_vector;
        i_DEC_RT_Data   : in     vl_logic_vector;
        i_EX_Writes_Back: in     vl_logic;
        i_EX_Valid      : in     vl_logic;
        i_EX_Write_Addr : in     vl_logic_vector;
        i_EX_Write_Data : in     vl_logic_vector;
        i_MEM_Writes_Back: in     vl_logic;
        i_MEM_Write_Addr: in     vl_logic_vector;
        i_MEM_Write_Data: in     vl_logic_vector;
        i_WB_Writes_Back: in     vl_logic;
        i_WB_Write_Addr : in     vl_logic_vector;
        i_WB_Write_Data : in     vl_logic_vector;
        o_DEC_RS_Override_Data: out    vl_logic_vector;
        o_DEC_RT_Override_Data: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_ADDR_WIDTH : constant is 1;
end forwarding_unit;
