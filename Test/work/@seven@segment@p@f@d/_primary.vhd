library verilog;
use verilog.vl_types.all;
entity SevenSegmentPFD is
    port(
        i_Clk           : in     vl_logic;
        ssOut           : out    vl_logic_vector(6 downto 0);
        nIn             : in     vl_logic_vector(1 downto 0)
    );
end SevenSegmentPFD;
