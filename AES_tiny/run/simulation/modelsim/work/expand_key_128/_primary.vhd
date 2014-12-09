library verilog;
use verilog.vl_types.all;
entity expand_key_128 is
    port(
        clk             : in     vl_logic;
        \in\            : in     vl_logic_vector(127 downto 0);
        out_1           : out    vl_logic_vector(127 downto 0);
        out_2           : out    vl_logic_vector(127 downto 0);
        rcon            : in     vl_logic_vector(7 downto 0)
    );
end expand_key_128;
