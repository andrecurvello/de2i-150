library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity UARTReceiver is
	port
	(
		clk				: in std_logic;
		rxd				: in std_logic;
		rxd_data			: out std_logic_vector(7 downto 0);
		rxd_data_ready	: out std_logic
	);
end entity UARTReceiver;

architecture UARTReceiverArch of UARTReceiver is

constant BIT_SPACE : integer := 15; 
constant DIVISOR : integer := 1600;
constant FREQ_INC : integer := 16 * 9600 / DIVISOR;
constant FREQ_DIV : integer := 27000000 / DIVISOR;
constant FREQ_MAX : integer := FREQ_DIV + FREQ_INC - 1;

type state_type is (idle, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, stop);

signal state : state_type := idle;
signal rxd_sync_inv : std_logic_vector(1 downto 0);
signal rxd_cnt_inv : std_logic_vector(1 downto 0) := "00";
signal rxd_bit_inv : std_logic;
signal baud_divider : integer range 0 to FREQ_MAX := 0;
signal data : std_logic_vector(7 downto 0);
signal baudover_tick : std_logic := '0';
signal bit_spacing : integer range 0 to 15;
signal next_bit : std_logic := '0';
begin

	next_bit <= '1' when bit_spacing = BIT_SPACE else '0';

	baud_gen : process(clk)
	begin
		if clk'event and clk = '1' then
			baud_divider <= baud_divider + FREQ_INC;
			if baud_divider >= FREQ_DIV then
				baud_divider <= 0;
				baudover_tick <= '1';
			else
				baudover_tick <= '0';
			end if;
		end if;
	end process baud_gen;
	
	rxd_sync_inverted : process(clk) 
	begin
		if clk'event and clk = '1' then
			if baudover_tick = '1' then
				rxd_sync_inv <= rxd_sync_inv(0) & not rxd;
			end if;
		end if;
	end process rxd_sync_inverted;
	--
	rxd_counter_inverted : process(clk)
	begin
		if clk'event and clk = '1' then
			if baudover_tick = '1' then
				if rxd_sync_inv(1) = '1' and rxd_cnt_inv /= "11" then
					rxd_cnt_inv <= unsigned(rxd_cnt_inv) + 1;
				elsif rxd_sync_inv(1) = '0' and rxd_cnt_inv /= "00" then
					rxd_cnt_inv <= unsigned(rxd_cnt_inv) - 1;
				end if;
				
				if rxd_cnt_inv = "00" then
					rxd_bit_inv <= '0';
				elsif rxd_cnt_inv = "11" then
					rxd_bit_inv <= '1';
				end if;
			end if;
		end if;
	end process rxd_counter_inverted;
	--
	state_proc : process(clk)
	begin
		if clk'event and clk = '1' then
			if baudover_tick = '1' then
				case state is
					when idle =>
						if rxd_bit_inv = '1' then
							state <= bit0;
						end if;
					when bit0 =>
						if next_bit = '1' then
							state <= bit1;
						end if;
					when bit1 =>
						if next_bit = '1' then
							state <= bit2;
						end if;
					when bit2 =>
						if next_bit = '1' then
							state <= bit3;
						end if;
					when bit3 =>
						if next_bit = '1' then
							state <= bit4;
						end if;
					when bit4 =>
						if next_bit = '1' then
							state <= bit5;
						end if;
					when bit5 =>
						if next_bit = '1' then
							state <= bit6;
						end if;
					when bit6 =>
						if next_bit = '1' then
							state <= bit7;
						end if;
					when bit7 =>
						if next_bit = '1' then
							state <= stop;
						end if;
					when stop =>
						if next_bit = '1' then
							state <= idle;
						end if;
				end case;
			end if;
		end if;
	end process state_proc;
	--
	bit_spacing_proc : process(clk)
	begin
		if clk'event and clk = '1' then
			if state = idle then
				bit_spacing <= 0;
			elsif baudover_tick = '1' then
				if bit_spacing < 15 then
					bit_spacing <= bit_spacing + 1;
				else
					bit_spacing <= 0;
				end if;
			end if;
		end if;
	end process bit_spacing_proc;
	--
	shift_data_proc : process(clk)
	begin
		if clk'event and clk = '1' then
			if baudover_tick = '1' and next_bit = '1' and
			state /= idle and state /= stop then
				data <= not rxd_bit_inv & data(7 downto 1);
			end if;
		end if;
	end process shift_data_proc;
	--
	output_data_proc : process(clk)
	begin
		if clk'event and clk = '1' then
			if baudover_tick = '1' and next_bit = '1' and
			state = stop and rxd_bit_inv = '0' then
				rxd_data <= data;
				rxd_data_ready <= '1';
			else
				rxd_data_ready <= '0';
			end if;
		end if;
	end process output_data_proc;
end UARTReceiverArch;

