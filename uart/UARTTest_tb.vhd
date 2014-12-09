LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY UARTTest_tb IS
END UARTTest_tb;
 
ARCHITECTURE behavior OF UARTTest_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT UARTTest
    PORT(
         clk	: in std_logic;
			rst	: in std_logic;
			rxd	: in std_logic;
			enable : in std_logic;
			random_bit : in std_logic;
			bypass : in std_logic;
			txd : out std_logic;
			led : out std_logic;
			finish : out std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rxd : std_logic := '0';
	signal rst : std_logic := '0';
	signal enable : std_logic := '0';
	signal random_bit : std_logic := '0';
	signal bypass : std_logic := '0';
 	--Outputs
   signal txd : std_logic;
   signal led : std_logic;
	signal finish : std_logic;


   -- Clock period definitions
   constant clk_period : time := 37 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: UARTTest PORT MAP (
          clk => clk,
			 rst => rst,
			 enable => enable,
			 random_bit => random_bit,
			 bypass => bypass,
          rxd => rxd,
          txd => txd,
          led => led,
			 finish => finish
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

	sti_process: process
	begin
		rst <= '1';
		enable <= '0';
		bypass <= '0';
		wait for 500 us;
		rst <= '0';
		enable <= '1';
		wait for 60 ms;
		rst <= '1';
		wait for 100 us;
		rst <= '0';
		wait;
	end process;
END;
