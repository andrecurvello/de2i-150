library verilog;
use verilog.vl_types.all;
entity aes_128 is
    port(
        clk             : in     vl_logic;
        state           : in     vl_logic_vector(127 downto 0);
        key             : in     vl_logic_vector(127 downto 0);
        \out\           : out    vl_logic_vector(127 downto 0)
    );
end aes_128;
