library verilog;
use verilog.vl_types.all;
entity flashreader is
    generic(
        WORDS_TO_LOAD   : integer := 1048576;
        CLOCK_PERIOD_PS : integer := 10000;
        DRAM_ADDR_WIDTH : integer := 22;
        DRAM_BASE_ADDR  : vl_notype;
        DRAM_DATA_WIDTH : integer := 32;
        DRAM_DATA_BURST_COUNT: integer := 4;
        FLASH_BASE_ADDR : vl_logic_vector(0 to 21) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        FLASH_ADDR_WIDTH: integer := 22;
        FLASH_DATA_WIDTH: integer := 8;
        FLASH_READ_WAIT_TIME_PS: integer := 90000
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        o_Done          : out    vl_logic;
        o_SDRAM_Addr    : out    vl_logic_vector;
        o_SDRAM_Req_Valid: out    vl_logic;
        o_SDRAM_Read_Write_n: out    vl_logic;
        o_SDRAM_Data    : out    vl_logic_vector;
        i_SDRAM_Data_Read: in     vl_logic;
        i_SDRAM_Last    : in     vl_logic;
        o_FL_Addr       : out    vl_logic_vector;
        i_FL_Data       : in     vl_logic_vector;
        o_FL_Chip_En_n  : out    vl_logic;
        o_FL_Output_En_n: out    vl_logic;
        o_FL_Write_En_n : out    vl_logic;
        o_FL_Reset_n    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WORDS_TO_LOAD : constant is 1;
    attribute mti_svvh_generic_type of CLOCK_PERIOD_PS : constant is 1;
    attribute mti_svvh_generic_type of DRAM_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DRAM_BASE_ADDR : constant is 3;
    attribute mti_svvh_generic_type of DRAM_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DRAM_DATA_BURST_COUNT : constant is 1;
    attribute mti_svvh_generic_type of FLASH_BASE_ADDR : constant is 1;
    attribute mti_svvh_generic_type of FLASH_ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FLASH_DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of FLASH_READ_WAIT_TIME_PS : constant is 1;
end flashreader;
