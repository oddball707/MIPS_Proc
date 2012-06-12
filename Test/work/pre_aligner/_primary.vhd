library verilog;
use verilog.vl_types.all;
entity pre_aligner is
    generic(
        ADDRESS_WIDTH   : integer := 22;
        DATA_WIDTH      : integer := 32
    );
    port(
        i_pc            : in     vl_logic_vector;
        i_inst1         : in     vl_logic_vector;
        i_inst2         : in     vl_logic_vector;
        i_inst3         : in     vl_logic_vector;
        i_inst4         : in     vl_logic_vector;
        o_isbranch      : out    vl_logic;
        o_branch_address: out    vl_logic_vector;
        o_Branch_Target : out    vl_logic_vector;
        o_delay_slot    : out    vl_logic;
        o_j_inst        : out    vl_logic;
        o_jal_inst      : out    vl_logic;
        o_jr_inst       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end pre_aligner;
