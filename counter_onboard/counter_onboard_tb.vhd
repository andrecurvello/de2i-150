--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:26:52 09/29/2010
-- Design Name:   
-- Module Name:   C:/Xilinx/12.2/ISE_DS/ISE/ISEexamples/counter_onboard/counter_onboard/counter_onboard_testbench.vhd
-- Project Name:  counter_onboard
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: counter_onboard
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY counter_onboard_testbench IS
END counter_onboard_testbench;
 
ARCHITECTURE behavior OF counter_onboard_testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT counter_onboard
    PORT(
         push_button : IN  std_logic;
         clk : IN  std_logic;
         LED1 : OUT  std_logic;
         LED2 : OUT  std_logic;
         LED3 : OUT  std_logic;
         LED4 : OUT  std_logic		
        );
    END COMPONENT;
    
	 Component debounce 
    Port ( pb : in  STD_LOGIC;
           clock_100Hz : in  STD_LOGIC;
           pb_debounced : out  STD_LOGIC);
	 end component;

	 Component counter
    Port (  clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           count : out  STD_LOGIC_VECTOR(3 downto 0));
	 end component;

	 Component clk_div
	 Port ( clk_tx                 : in  STD_LOGIC;   
           rst_clk_tx             : in  STD_LOGIC;  
           clk_div_1M, clk_div_8k	 : out STD_LOGIC);
	 end component;
	 

   --Inputs
   signal push_button : std_logic := '0';
   signal clk : std_logic := '0';
   signal rst_clk : std_logic := '0';


 	--Outputs
   signal LED1 : std_logic;
   signal LED2 : std_logic;
   signal LED3 : std_logic;
   signal LED4 : std_logic;
	signal  clk_div_1M : std_logic;	
	signal	clk_div_8k : std_logic;	

   -- Clock period definitions
   constant clk_period : time :=  1 ns;

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: counter_onboard PORT MAP (
          push_button => push_button,
          clk => clk,
          LED1 => LED1,
          LED2 => LED2,
          LED3 => LED3,
          LED4 => LED4
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 


   -- Stimulus process
   stim_proc: process
   begin		

      -- insert stimulus here 
		push_button <= '1';
		 wait for 100 ns;
		push_button <= '1';
      wait for 10 ms;
		push_button <= '0';
		wait for 100 ms;
		push_button <= '1';
		wait;
   end process;

END;