library verilog;
use verilog.vl_types.all;
entity schedule_thread is
    generic(
        THD_ID          : integer := 0;
        IN_INSN_WIDTH   : integer := 100;
        OUT_INSN_WIDTH  : integer := 101;
        ADDR_WIDTH      : integer := 22
    );
    port(
        i_Got_Branch    : in     vl_logic;
        i_Got_Mem       : in     vl_logic;
        i_Got_Two_Mem   : in     vl_logic;
        i_Thd_Insns     : in     vl_logic_vector;
        i_Thd_Valid     : in     vl_logic_vector(3 downto 0);
        i_Insns         : in     vl_logic_vector;
        i_Valid         : in     vl_logic_vector(3 downto 0);
        o_Got_Branch    : out    vl_logic;
        o_Got_Mem       : out    vl_logic;
        o_Got_Two_Mem   : out    vl_logic;
        o_Insns         : out    vl_logic_vector;
        o_Valid         : out    vl_logic_vector(3 downto 0);
        o_IQ_Stall      : out    vl_logic;
        o_IQ_Advance    : out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of THD_ID : constant is 1;
    attribute mti_svvh_generic_type of IN_INSN_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUT_INSN_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
end schedule_thread;
