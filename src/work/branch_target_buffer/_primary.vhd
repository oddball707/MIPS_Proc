library verilog;
use verilog.vl_types.all;
entity branch_target_buffer is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : integer := 22;
        BUFFER_SIZE     : integer := 8
    );
    port(
        i_Clk           : in     vl_logic;
        i_pc            : in     vl_logic_vector;
        i_ALU_pc        : in     vl_logic_vector;
        i_ALU_target    : in     vl_logic_vector;
        o_target        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of BUFFER_SIZE : constant is 1;
end branch_target_buffer;
