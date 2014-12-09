library verilog;
use verilog.vl_types.all;
entity aes_wb is
    port(
        wb_clk_i        : in     vl_logic;
        wb_rst_i        : in     vl_logic;
        wb_dat_i        : in     vl_logic_vector(31 downto 0);
        wb_dat_o        : out    vl_logic_vector(31 downto 0);
        wb_adr_i        : in     vl_logic_vector(7 downto 0);
        wb_sel_i        : in     vl_logic_vector(3 downto 0);
        wb_we_i         : in     vl_logic;
        wb_cyc_i        : in     vl_logic;
        wb_stb_i        : in     vl_logic;
        wb_ack_o        : out    vl_logic;
        plaintext_o     : out    vl_logic_vector(127 downto 0);
        ciphertext_i    : in     vl_logic_vector(127 downto 0)
    );
end aes_wb;
