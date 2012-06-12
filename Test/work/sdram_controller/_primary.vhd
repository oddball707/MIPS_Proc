library verilog;
use verilog.vl_types.all;
entity sdram_controller is
    generic(
        ROW_ADDR_WIDTH  : integer := 12;
        BANK_ADDR_WIDTH : integer := 2;
        COL_ADDR_WIDTH  : integer := 8;
        DATA_WIDTH      : integer := 16
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset         : in     vl_logic;
        i_Addr          : in     vl_logic_vector;
        i_Req_Valid     : in     vl_logic;
        i_Read_Write_n  : in     vl_logic;
        i_Data          : in     vl_logic_vector(31 downto 0);
        o_Data_Read     : out    vl_logic;
        o_Data          : out    vl_logic_vector(31 downto 0);
        o_Data_Valid    : out    vl_logic;
        o_Last          : out    vl_logic;
        b_Dq            : inout  vl_logic_vector;
        o_Addr          : out    vl_logic_vector;
        o_Ba            : out    vl_logic_vector;
        o_Clk           : out    vl_logic;
        o_Cke           : out    vl_logic;
        o_Cs_n          : out    vl_logic;
        o_Ras_n         : out    vl_logic;
        o_Cas_n         : out    vl_logic;
        o_We_n          : out    vl_logic;
        o_Dqm           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ROW_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of BANK_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of COL_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end sdram_controller;
