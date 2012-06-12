library verilog;
use verilog.vl_types.all;
entity regfile is
    generic(
        DATA_WIDTH      : integer := 32;
        REG_ADDR_WIDTH  : integer := 5
    );
    port(
        i_Clk           : in     vl_logic;
        i_RS_Addr       : in     vl_logic_vector;
        i_RT_Addr       : in     vl_logic_vector;
        i_Write_Enable  : in     vl_logic;
        i_Write_Addr    : in     vl_logic_vector;
        i_Write_Data    : in     vl_logic_vector;
        o_RS_Data       : out    vl_logic_vector;
        o_RT_Data       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_ADDR_WIDTH : constant is 1;
end regfile;
