library verilog;
use verilog.vl_types.all;
entity aligner is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        DATA_WIDTH      : integer := 32;
        INSN_WIDTH      : integer := 99
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_pc            : in     vl_logic_vector;
        i_isn1          : in     vl_logic_vector;
        i_isn2          : in     vl_logic_vector;
        i_isn3          : in     vl_logic_vector;
        i_isn4          : in     vl_logic_vector;
        o_valid         : out    vl_logic_vector(3 downto 0);
        o_isn1          : out    vl_logic_vector;
        o_isn2          : out    vl_logic_vector;
        o_isn3          : out    vl_logic_vector;
        o_isn4          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of INSN_WIDTH : constant is 1;
end aligner;
