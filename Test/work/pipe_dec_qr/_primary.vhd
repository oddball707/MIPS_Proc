library verilog;
use verilog.vl_types.all;
entity pipe_dec_qr is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        ISN_WIDTH       : integer := 99
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Flush         : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_PC            : in     vl_logic_vector;
        o_PC            : out    vl_logic_vector;
        i_Instruction1  : in     vl_logic_vector;
        i_Instruction2  : in     vl_logic_vector;
        i_Instruction3  : in     vl_logic_vector;
        i_Instruction4  : in     vl_logic_vector;
        o_Instruction1  : out    vl_logic_vector;
        o_Instruction2  : out    vl_logic_vector;
        o_Instruction3  : out    vl_logic_vector;
        o_Instruction4  : out    vl_logic_vector;
        i_prediction    : in     vl_logic;
        o_prediction    : out    vl_logic;
        i_branch_target : in     vl_logic_vector;
        o_branch_target : out    vl_logic_vector;
        i_thread        : in     vl_logic_vector(1 downto 0);
        o_thread        : out    vl_logic_vector(1 downto 0);
        i_valid         : in     vl_logic_vector(3 downto 0);
        o_valid         : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ISN_WIDTH : constant is 1;
end pipe_dec_qr;
