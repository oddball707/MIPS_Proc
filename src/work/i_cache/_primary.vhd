library verilog;
use verilog.vl_types.all;
entity i_cache is
    generic(
        DATA_WIDTH      : integer := 32;
        TAG_WIDTH       : integer := 14;
        INDEX_WIDTH     : integer := 5;
        BLOCK_OFFSET_WIDTH: integer := 2
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Valid         : in     vl_logic;
        i_Address       : in     vl_logic_vector;
        o_MEM_Valid     : out    vl_logic;
        o_MEM_Address   : out    vl_logic_vector;
        i_MEM_Valid     : in     vl_logic;
        i_MEM_Last      : in     vl_logic;
        i_MEM_Data      : in     vl_logic_vector;
        o_Ready         : out    vl_logic;
        o_Valid         : out    vl_logic;
        o_Data          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of TAG_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INDEX_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of BLOCK_OFFSET_WIDTH : constant is 1;
end i_cache;