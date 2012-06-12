library verilog;
use verilog.vl_types.all;
entity memory_arbiter is
    generic(
        DATA_WIDTH      : integer := 32;
        ADDRESS_WIDTH   : integer := 22
    );
    port(
        i_Clk           : in     vl_logic;
        i_Reset_n       : in     vl_logic;
        i_IMEM_Valid    : in     vl_logic;
        i_IMEM_Address  : in     vl_logic_vector;
        o_IMEM_Valid    : out    vl_logic;
        o_IMEM_Last     : out    vl_logic;
        o_IMEM_Data     : out    vl_logic_vector;
        i_DMEM_Valid    : in     vl_logic;
        i_DMEM_Read_Write_n: in     vl_logic;
        i_DMEM_Address  : in     vl_logic_vector;
        i_DMEM_Data     : in     vl_logic_vector;
        o_DMEM_Valid    : out    vl_logic;
        o_DMEM_Data_Read: out    vl_logic;
        o_DMEM_Last     : out    vl_logic;
        o_DMEM_Data     : out    vl_logic_vector;
        i_Flash_Valid   : in     vl_logic;
        i_Flash_Data    : in     vl_logic_vector;
        i_Flash_Address : in     vl_logic_vector;
        o_Flash_Data_Read: out    vl_logic;
        o_Flash_Last    : out    vl_logic;
        o_MEM_Valid     : out    vl_logic;
        o_MEM_Address   : out    vl_logic_vector;
        o_MEM_Read_Write_n: out    vl_logic;
        o_MEM_Data      : out    vl_logic_vector;
        i_MEM_Data_Read : in     vl_logic;
        i_MEM_Data      : in     vl_logic_vector;
        i_MEM_Data_Valid: in     vl_logic;
        i_MEM_Last      : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ADDRESS_WIDTH : constant is 1;
end memory_arbiter;
