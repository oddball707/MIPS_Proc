library verilog;
use verilog.vl_types.all;
entity fetch_unit is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_Load          : in     vl_logic;
        i_Load_Address  : in     vl_logic_vector;
        o_PC            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end fetch_unit;
