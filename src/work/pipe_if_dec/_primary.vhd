library verilog;
use verilog.vl_types.all;
entity pipe_if_dec is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Flush         : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_PC            : in     vl_logic_vector;
        o_PC            : out    vl_logic_vector;
        i_Instruction   : in     vl_logic_vector;
        o_Instruction   : out    vl_logic_vector;
        i_prediction    : in     vl_logic;
        o_prediction    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end pipe_if_dec;
