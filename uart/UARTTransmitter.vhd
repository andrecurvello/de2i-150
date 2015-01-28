library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity UARTTransmitter is

	port
	(
		clk				: in std_logic;
		rst				: in std_logic;
		txd				: out std_logic;
		txd_data		: in std_logic_vector(7 downto 0);
		txd_start		: in std_logic;
		txd_busy		: out std_logic
	);
end entity UARTTransmitter;

architecture UARTTransmitterArch of UARTTransmitter is

type state_type is (idle, start, bit0, bit1, bit2, bit3, bit4, bit5, bit6, bit7, stop1, stop2);

signal state : state_type := idle; 
signal data : std_logic_vector(7 downto 0);
signal baud_tick : std_logic;
signal busy : std_logic := '0';
-- sys_clock/100 + baudrate/100 
signal baud_divider : integer range 0 to (50000000/100 + 115200/100 - 1) := 0;
begin

  	txd_busy <= busy; 
	busy <= '0' when state = idle else '1';

	baud_gen : process(clk)
	begin
		if clk'event and clk = '1' then
			if busy = '1' then
				baud_divider <= baud_divider + (115200/100);
				if baud_divider > (27000000/100) then
					baud_tick <= '1';
					baud_divider <= 0;
				else
					baud_tick <= '0';
				end if;
			end if;
		end if;
	end process baud_gen;
	
	state_proc : process(clk)
	begin
		if rst = '1' then
			state <= idle;
			txd <= '1';
		elsif clk'event and clk = '1' then
			case state is
				when idle =>
					if txd_start = '1' then
						state <= start;
					end if;	
					txd <= '1';
				when start =>
					if baud_tick = '1' then
						state <= bit0;
					end if;
					txd <= '0';
				when bit0 =>
					if baud_tick = '1' then
						state <= bit1;
					end if;
					txd <= data(0);
				when bit1 =>
					if baud_tick = '1' then
						state <= bit2;
					end if;
					txd <= data(1);
				when bit2 =>
					if baud_tick = '1' then
						state <= bit3;
					end if;
					txd <= data(2);
				when bit3 =>
					if baud_tick = '1' then
						state <= bit4;
					end if;
					txd <= data(3);
				when bit4 =>
					if baud_tick = '1' then
						state <= bit5;
					end if;
					txd <= data(4);
				when bit5 =>
					if baud_tick = '1' then
						state <= bit6;
					end if;
					txd <= data(5);
				when bit6 =>
					if baud_tick = '1' then
						state <= bit7;
					end if;
					txd <= data(6);
				when bit7 =>
					if baud_tick = '1' then
						state <= stop1;
					end if;
					txd <= data(7);
				when stop1 =>
					if baud_tick = '1' then
						state <= stop2;
					end if;
					txd <= '1';
				when stop2 =>
					if baud_tick = '1' then
						state <= idle;
					end if;
					txd <= '1';
			end case;
		end if;
	end process state_proc;
	
	data_load_proc : process(clk)
	begin
		if clk'event and clk = '1' then
			if txd_start = '1' then
				data <= txd_data;
			end if;
		end if;
	end process data_load_proc;

end UARTTransmitterArch;


