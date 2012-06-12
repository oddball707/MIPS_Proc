library verilog;
use verilog.vl_types.all;
entity jump_stack is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : integer := 22;
        STACK_SIZE      : integer := 16
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_address       : in     vl_logic_vector;
        i_thread        : in     vl_logic_vector(1 downto 0);
        i_pop           : in     vl_logic;
        i_push          : in     vl_logic;
        o_address       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of STACK_SIZE : constant is 1;
end jump_stack;
