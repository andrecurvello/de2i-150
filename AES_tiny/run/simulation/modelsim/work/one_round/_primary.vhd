library verilog;
use verilog.vl_types.all;
entity one_round is
    port(
        clk             : in     vl_logic;
        state_in        : in     vl_logic_vector(127 downto 0);
        key             : in     vl_logic_vector(127 downto 0);
        state_out       : out    vl_logic_vector(127 downto 0)
    );
end one_round;
