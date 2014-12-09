----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:21:32 09/27/2010 
-- Design Name: 
-- Module Name:    counter - Behavioral 
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity counter is
    Port (  clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           count : out  STD_LOGIC_VECTOR(3 downto 0));
end counter;

architecture Behavioral of counter is

SIGNAL internal_count	:	std_logic_vector(3 downto 0);

begin
	count <= internal_count;
	process (reset, clock)
	begin
		if reset = '1' then
			internal_count <= "0000";
		elsif (rising_edge(clock)) then
			internal_count <= internal_count + 1;
		end if;
	end process;
end Behavioral;

