
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity clk_div is
    Port ( clk_tx                 : in  STD_LOGIC;                       -- transmitter clock
           rst			             : in  STD_LOGIC;                       -- reset signal synchronized to the transmitter clock
           clk_div_1M, clk_div_8k 	 : out STD_LOGIC                        -- indication that the clk_samp is in the first clk_tx period after the rising edge. Asserted during clk_tx period after en_clk_samp
          );
end clk_div;

architecture Behavioral of clk_div is
	Signal clkout1M, clkout8k :  STD_LOGIC;

begin
	clk_div_1M <= clkout1M;
	clk_div_8k <= clkout8k;
    process (clk_tx, clkout1M, clkout8k, rst)
			variable internal_counter_1 : integer range 0 to 1048576*5;
			variable internal_counter_2 : integer range 0 to 1048576;
       begin
         if (rst = '1') then                                        -- reset asserted
            clkout1M <= '0';
				clkout8k <= '0';
				internal_counter_1 := 0;
				internal_counter_2 := 0;
         elsif (clk_tx'event and clk_tx='1') then       
				 if (internal_counter_1 = 1048576*5) then -- 1048576*5
                 clkout1M <= not clkout1M;
					  internal_counter_1 := 0;   
				  else
					  internal_counter_1 := internal_counter_1 + 1;
						end if;
				 if (internal_counter_2 = 8192) then  --8192
                 clkout8k <= not clkout8k;
					  internal_counter_2 := 0;   
				  else
					  internal_counter_2 := internal_counter_2 + 1;
						end if;
                end if;                                                        -- end of done with count
                                                                     -- end of reset/normal operation                                                               
       end process;

end Behavioral;


