library verilog;
use verilog.vl_types.all;
entity aes_128_top is
    port(
        aes_clk_in      : in     vl_logic;
        aes_rst_in      : in     vl_logic;
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_adr_i        : in     vl_logic_vector(7 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic
    );
end aes_128_top;
