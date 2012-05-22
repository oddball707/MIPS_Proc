library verilog;
use verilog.vl_types.all;
entity icache_mux is
    generic(
        ADDRESS_WIDTH   : integer := 22
    );
    port(
        i_Clk           : in     vl_logic;
        i_pc            : in     vl_logic_vector;
        i_branch_pc     : in     vl_logic_vector;
        i_predictor_taken: in     vl_logic;
        o_target        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
end icache_mux;
