library ieee;
use ieee.std_logic_1164.all;

entity UART is
	port
	(
		clk				: in std_logic;
		rst				: in std_logic;
		rxd				: in std_logic;
		txd				: out std_logic;
		txd_data		: in std_logic_vector(7 downto 0);
		txd_start		: in std_logic;
		txd_busy		: out std_logic;
		rxd_data		: out std_logic_vector(7 downto 0);
		rxd_data_ready	: out std_logic
	);
end entity UART;

architecture UARTArch of UART is

component UARTReceiver
	port
	(
		clk				: in std_logic;
		rxd				: in std_logic;
		rxd_data		: out std_logic_vector(7 downto 0);
		rxd_data_ready	: out std_logic
	);
end component UARTReceiver;

component UARTTransmitter
	port
	(
		clk				: in std_logic;
		rst				: in std_logic;
		txd				: out std_logic;
		txd_data			: in std_logic_vector(7 downto 0);
		txd_start		: in std_logic;
		txd_busy			: out std_logic
	);
end component UARTTransmitter;

signal txData : std_logic_vector(7 downto 0);
signal txStart : std_logic;
begin

	RECEIVER : UARTReceiver
	port map
	(
		clk				=> clk,
		rxd				=> rxd,
		rxd_data		=> rxd_data,
		rxd_data_ready	=> rxd_data_ready
	);
	TRANSMITTER : UARTTransmitter
	port map
	(
		clk				=> clk,
		rst				=> rst,
		txd				=> txd,
		txd_data			=> txData,
		txd_start		=> txd_start,
		txd_busy			=> txd_busy
	);
	
	txData <= "01000001";
	txStart <= '1';
	
end UARTArch;
