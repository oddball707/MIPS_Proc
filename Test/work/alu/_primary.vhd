library verilog;
use verilog.vl_types.all;
entity alu is
    generic(
        DATA_WIDTH      : integer := 32;
        CTLCODE_WIDTH   : integer := 8
    );
    port(
        i_Valid         : in     vl_logic;
        i_ALUCTL        : in     vl_logic_vector;
        i_Operand1      : in     vl_logic_vector;
        i_Operand2      : in     vl_logic_vector;
        o_Valid         : out    vl_logic;
        o_Result        : out    vl_logic_vector;
        o_Branch_Valid  : out    vl_logic;
        o_Branch_Outcome: out    vl_logic;
        o_Pass_Done_Value: out    vl_logic_vector(15 downto 0);
        o_Pass_Done_Change: out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CTLCODE_WIDTH : constant is 1;
end alu;
