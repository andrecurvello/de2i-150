library verilog;
use verilog.vl_types.all;
entity table_lookup is
    port(
        clk             : in     vl_logic;
        state           : in     vl_logic_vector(31 downto 0);
        p0              : out    vl_logic_vector(31 downto 0);
        p1              : out    vl_logic_vector(31 downto 0);
        p2              : out    vl_logic_vector(31 downto 0);
        p3              : out    vl_logic_vector(31 downto 0)
    );
end table_lookup;
