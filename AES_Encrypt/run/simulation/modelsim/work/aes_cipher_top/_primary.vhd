library verilog;
use verilog.vl_types.all;
entity aes_cipher_top is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ld              : in     vl_logic;
        done            : out    vl_logic;
        key             : in     vl_logic_vector(127 downto 0);
        text_in         : in     vl_logic_vector(127 downto 0);
        text_out        : out    vl_logic_vector(127 downto 0)
    );
end aes_cipher_top;
