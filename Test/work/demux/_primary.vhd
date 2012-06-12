library verilog;
use verilog.vl_types.all;
entity demux is
    generic(
        ADDRESS_WIDTH   : integer := 32;
        ISN_WIDTH       : integer := 99
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_Flush         : in     vl_logic;
        i_Stall         : in     vl_logic;
        i_thread        : in     vl_logic_vector;
        i_valid         : in     vl_logic_vector(3 downto 0);
        i_Instruction1  : in     vl_logic_vector;
        i_Instruction2  : in     vl_logic_vector;
        i_Instruction3  : in     vl_logic_vector;
        i_Instruction4  : in     vl_logic_vector;
        o_thread1       : out    vl_logic_vector;
        o_thread2       : out    vl_logic_vector;
        o_thread3       : out    vl_logic_vector;
        o_thread4       : out    vl_logic_vector;
        o_valid1        : out    vl_logic_vector(3 downto 0);
        o_valid2        : out    vl_logic_vector(3 downto 0);
        o_valid3        : out    vl_logic_vector(3 downto 0);
        o_valid4        : out    vl_logic_vector(3 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ISN_WIDTH : constant is 1;
end demux;
