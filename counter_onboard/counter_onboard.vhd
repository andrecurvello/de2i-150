----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:22:37 09/28/2010 
-- Design Name: 
-- Module Name:    counter_onboard - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY counter_onboard IS
    Port ( 		
			   push_button : in  STD_LOGIC;
           clk			 : in  STD_LOGIC;
           LED1, LED2, LED3, LED4 : out  STD_LOGIC
				);
END counter_onboard;

architecture Behavioral of counter_onboard is

Component counter
    Port (  clock : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				count : out  STD_LOGIC_VECTOR(3 downto 0));
end component;

Component clk_div
	Port ( 	clk_tx                 : in  STD_LOGIC;
				rst							: in	STD_LOGIC;
				clk_div_1M 	: out STD_LOGIC;
				clk_div_8k	 : out STD_LOGIC);
end component;


SIGNAL reset : STD_LOGIC;
SIGNAL counter_out : STD_LOGIC_VECTOR(3 downto 0);
SIGNAL clk100Hz, clk1Hz : STD_LOGIC;


begin

reset <= NOT(push_button);
c0:   clk_div port map (clk, reset, clk1Hz, clk100Hz);
c2:	counter port map (clk1Hz, reset, counter_out);


LED1 <= counter_out(0);
LED2 <= counter_out(1);
LED3 <= counter_out(2);
LED4 <= counter_out(3);

end Behavioral;

