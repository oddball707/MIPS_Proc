library verilog;
use verilog.vl_types.all;
entity pipe_mem_wb is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32;
        REG_ADDR_WIDTH  : integer := 5
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Flush         : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_WriteBack_Data: in     vl_logic_vector;
        o_WriteBack_Data: out    vl_logic_vector;
        i_Writes_Back   : in     vl_logic;
        o_Writes_Back   : out    vl_logic;
        i_Write_Addr    : in     vl_logic_vector;
        o_Write_Addr    : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_ADDR_WIDTH : constant is 1;
end pipe_mem_wb;