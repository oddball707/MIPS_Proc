library verilog;
use verilog.vl_types.all;
entity branch_predictor is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : integer := 22
    );
    port(
        i_Clk           : in     vl_logic;
        i_IMEM_address  : in     vl_logic_vector;
        i_IMEM_isbranch : in     vl_logic;
        i_ALU_outcome   : in     vl_logic;
        i_ALU_pc        : in     vl_logic;
        i_ALU_isbranch  : in     vl_logic;
        i_ALU_prediction: in     vl_logic;
        i_Reset_n       : in     vl_logic;
        o_taken         : out    vl_logic;
        o_valid         : out    vl_logic;
        o_flush         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
end branch_predictor;
