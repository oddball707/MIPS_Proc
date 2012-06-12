library verilog;
use verilog.vl_types.all;
entity fetch_unit is
    generic(
        ADDRESS_WIDTH   : integer := 22;
        DATA_WIDTH      : integer := 32
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_branch_taken  : in     vl_logic;
        i_jump_inst     : in     vl_logic;
        i_jr_inst       : in     vl_logic;
        i_branch_inst   : in     vl_logic;
        i_branch_mispredict: in     vl_logic_vector(3 downto 0);
        i_thread_choice : in     vl_logic_vector(1 downto 0);
        i_current_target: in     vl_logic_vector;
        i_mispredict_nottaken: in     vl_logic_vector;
        i_mispredict_pc : in     vl_logic_vector;
        i_jstack_jrtarget: in     vl_logic_vector;
        o_PC            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end fetch_unit;
