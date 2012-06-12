library verilog;
use verilog.vl_types.all;
entity insn_mixer is
    generic(
        INSN_WIDTH      : integer := 99
    );
    port(
        i_Insns         : in     vl_logic_vector;
        i_Valid         : in     vl_logic_vector(15 downto 0);
        i_Ordering      : in     vl_logic_vector(4 downto 0);
        o_Insns         : out    vl_logic_vector;
        o_Valid         : out    vl_logic_vector(4 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INSN_WIDTH : constant is 1;
end insn_mixer;
