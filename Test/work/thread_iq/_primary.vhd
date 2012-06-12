library verilog;
use verilog.vl_types.all;
entity thread_iq is
    generic(
        INSN_WIDTH      : integer := 99
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_Advance       : in     vl_logic_vector(1 downto 0);
        i_Write_Enable  : in     vl_logic;
        i_Insns         : in     vl_logic_vector;
        i_Valid         : in     vl_logic_vector(3 downto 0);
        o_Space         : out    vl_logic;
        o_Insns         : out    vl_logic_vector;
        o_Valid         : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INSN_WIDTH : constant is 1;
end thread_iq;
