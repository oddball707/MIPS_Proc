library verilog;
use verilog.vl_types.all;
entity schedule is
    generic(
        IN_INSN_WIDTH   : integer := 100;
        OUT_INSN_WIDTH  : integer := 101;
        ADDR_WIDTH      : integer := 22
    );
    port(
        i_Insns         : in     vl_logic_vector;
        i_Valid         : in     vl_logic_vector(15 downto 0);
        o_Insns         : out    vl_logic_vector;
        o_Stall         : out    vl_logic_vector(3 downto 0);
        o_Advance       : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IN_INSN_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of OUT_INSN_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
end schedule;
