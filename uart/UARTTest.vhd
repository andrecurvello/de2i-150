library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity UARTTest is
	port
	(
		clk			: in std_logic;
		rst			: in std_logic;
		rxd			: in std_logic;
		enable		: in std_logic;
		random_bit 	: in std_logic;
		bypass		: in std_logic;
		txd 			: out std_logic;
		led 			: out std_logic;
		finish 		: out std_logic
		);
end entity UARTTest;

architecture UARTTestArch of UARTTest is

component UART
port
(
	clk				: in std_logic;
	rst				: in std_logic;
	rxd				: in std_logic;
	rxd_data		: out std_logic_vector(7 downto 0);
	rxd_data_ready	: out std_logic;
	txd				: out std_logic;
	txd_data		: in std_logic_vector(7 downto 0);
	txd_start		: in std_logic;
	txd_busy		: out std_logic
);
end component UART;

component RSA
port
(
	clk			: in std_logic;
	rst			: in std_logic;
	enable		: in std_logic;
	random_bit	: in std_logic;
	dn_enable	: in std_logic;
	ciphertext_in : in std_logic_vector(143 downto 0);
	plaintext	: out std_logic_vector(127 downto 0);
	ciphertext	: out std_logic_vector(143 downto 0);
	n				: out std_logic_vector(35 downto 0);
	public_key : out std_logic_vector(63 downto 0);
	en_finish	: out std_logic;
	dn_finish	: out std_logic;
	AES_key		: out std_logic_vector(127 downto 0)
);
end component RSA;

component clk_div
port
(
	clk_in           : in  STD_LOGIC;                     
   clk_out			  : out STD_LOGIC;
	debounce_clk		: out std_logic
);
end component clk_div;

component debounce
port
(
	pb 				: in  STD_LOGIC;
   clock_100Hz 	: in  STD_LOGIC;
   pb_debounced 	: out  STD_LOGIC
);
end component debounce;

component MIPS
port
(
	CLK_H  : in STD_LOGIC;
	RST_H		 : in STD_LOGIC;
	bypass		: in std_logic;
	data_in1  : in std_logic_vector(127 downto 0);
	data_in2  : in std_logic_vector(127 downto 0);
	Data_Write : in std_logic;
	stop_bit	: out std_logic;
	OVERFLOW: out STD_LOGIC;
	MEMWR : out STD_LOGIC;
	EN_key_in	 : in  STD_LOGIC_VECTOR(127 downto 0);
	output		: out std_logic_vector(31 downto 0);
		
	roundkey1 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey2 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey3 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey4 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey5 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey6 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey7 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey8 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey9 : in  STD_LOGIC_VECTOR(127 downto 0);
	roundkey10 : in  STD_LOGIC_VECTOR(127 downto 0);
		
	output0	: out std_logic_vector(127 downto 0);
	output1	: out std_logic_vector(127 downto 0);
	output2	: out std_logic_vector(127 downto 0);
	output3	: out std_logic_vector(127 downto 0);
	output4	: out std_logic_vector(127 downto 0);
	output5	: out std_logic_vector(127 downto 0);
	output6	: out std_logic_vector(127 downto 0);
	output7	: out std_logic_vector(127 downto 0);
	output8	: out std_logic_vector(127 downto 0);
	output9	: out std_logic_vector(127 downto 0);
	output10	: out std_logic_vector(127 downto 0);
	output11	: out std_logic_vector(127 downto 0)
);
end component;

component KeySchedule_EN
port
(
	key_in : in  STD_LOGIC_VECTOR(127 downto 0);
   roundkey1 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey2 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey3 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey4 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey5 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey6 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey7 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey8 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey9 : out  STD_LOGIC_VECTOR(127 downto 0);
	roundkey10 : out  STD_LOGIC_VECTOR(127 downto 0)
);
end component;


type rxd_reg is array
		(integer range 0 to 49) of std_logic_vector(7 downto 0);
signal int_rxd_reg : rxd_reg;
signal rxd_data, txd_data : std_logic_vector(7 downto 0);
signal tb_ciphertext : std_logic_vector(143 downto 0);
signal tb_plaintext : std_logic_vector(127 downto 0);
signal tb_AES_key : std_logic_vector(127 downto 0);
signal tb_public_key : std_logic_vector(63 downto 0);
signal tb_n	: std_logic_vector(35 downto 0);
signal tb_ciphertext_in : std_logic_vector(143 downto 0);

signal rxd_data_ready, txd_start, txd_busy : std_logic;
signal tb_en_finish, tb_dn_finish : std_logic;
signal sig_232_enable : std_logic;
signal tb_rxd_ready : std_logic := '0';
signal tb_dn_enable : std_logic := '0';
signal tb_data1 : std_logic_vector(127 downto 0);
signal tb_data2 : std_logic_vector(127 downto 0);
signal tb_Data_Write : std_logic;

signal tb_MIPS_clk : std_logic;
signal tb_rst : std_logic;
signal tb_MIPS_rst : std_logic;
signal tb_debounce_clk : std_logic;
signal tb_stop_bit : std_logic;
signal reg_t_out : std_logic_vector(31 downto 0);
signal tb_overflow : std_logic;
signal tb_memwr : std_logic;
signal tb_key_in : std_logic_vector(127 downto 0);
signal tb_RSA2AESkey : std_logic_vector(127 downto 0);
signal tb_dn_key_in : std_logic_vector(127 downto 0);
signal tb_roundkey1 : std_logic_vector(127 downto 0);
signal tb_roundkey2 : std_logic_vector(127 downto 0);
signal tb_roundkey3 : std_logic_vector(127 downto 0);
signal tb_roundkey4 : std_logic_vector(127 downto 0);
signal tb_roundkey5 : std_logic_vector(127 downto 0);
signal tb_roundkey6 : std_logic_vector(127 downto 0);
signal tb_roundkey7 : std_logic_vector(127 downto 0);
signal tb_roundkey8 : std_logic_vector(127 downto 0);
signal tb_roundkey9 : std_logic_vector(127 downto 0);
signal tb_roundkey10 : std_logic_vector(127 downto 0);
type data_reg is array
	(integer range 0 to 11) of std_logic_vector(127 downto 0);
signal DataReg : data_reg;
type buffer_reg is array
	(integer range 0 to 11) of std_logic_vector(31 downto 0);
signal int_buffer_reg : buffer_reg;

--
type helloworld_type is 
(endstate, stop1, stop2, idle, DR0_0, DR0_1, DR0_2, DR0_3, DR0_4, DR1_0, DR1_1, DR1_2, DR1_3, DR1_4,  DR2_0, DR2_1, DR2_2, DR2_3, DR2_4, DR3_0, DR3_1, DR3_2,
DR4_1, DR4_2, DR4_3, DR4_4, DR5_1, DR5_2, DR5_3, DR5_4, DR6_1, DR6_2, DR6_3, DR6_4, DR7_1, DR7_2, DR7_3, DR7_4,
pubkey0_1, pubkey0_2, n0_1, n0_2, n0_3, n0_4, n0_5, temp1, t1,t2,t3,t4, key_set, MIPS_start);
signal state : helloworld_type := idle;
begin
	-- instantiating components
	SERIAL : UART
	port map
	(
		clk				=> clk,
		rst				=> rst,
		rxd				=> rxd,
		rxd_data			=> rxd_data,
		rxd_data_ready	=> rxd_data_ready,
		txd				=> txd,
		txd_data			=> txd_data,
		txd_start		=> txd_start,
		txd_busy			=> txd_busy
	);
	
	RSA_module : RSA
	port map
	(
		clk				=> clk,
		rst				=> rst,
		enable			=> enable,
		random_bit		=> random_bit,
		dn_enable		=> tb_dn_enable,
		ciphertext_in	=> tb_ciphertext_in,
		plaintext		=> tb_plaintext,
		ciphertext		=> tb_ciphertext,
		n					=> tb_n,
		public_key 		=> tb_public_key,
		en_finish		=> tb_en_finish,
		dn_finish		=> tb_dn_finish,
		AES_key			=> tb_AES_key
	);
	
	clk_divider : clk_div
	port map
	(
		clk_in         => clk,
		clk_out			=> tb_MIPS_clk,
		debounce_clk	=> tb_debounce_clk
	);
	
	debounce_rst : debounce
	port map
	(
		pb 				=> rst,
      clock_100Hz 	=> tb_debounce_clk,
      pb_debounced 	=> tb_rst
	);
	
	CPU_MIPS : MIPS
	port map
	(
		CLK_H  			=> tb_MIPS_clk,
		RST_H		 		=> tb_MIPS_rst,
		bypass			=> bypass,
		data_in1 		=> tb_data1,
		data_in2  		=> tb_data2,
		Data_Write 		=> tb_Data_Write,
		stop_bit			=> tb_stop_bit,
		OVERFLOW			=> tb_overflow,
		MEMWR 			=> tb_memwr,
		EN_key_in	 	=> tb_key_in,
		output			=> reg_t_out,
		
		roundkey1 		=> tb_roundkey1,
		roundkey2 		=> tb_roundkey2,
		roundkey3 		=> tb_roundkey3,
		roundkey4 		=> tb_roundkey4,
		roundkey5 		=> tb_roundkey5,
		roundkey6 		=> tb_roundkey6,
		roundkey7 		=> tb_roundkey7,
		roundkey8 		=> tb_roundkey8,
		roundkey9 		=> tb_roundkey9,
		roundkey10 		=> tb_roundkey10,
		
		output0		=> DataReg(0),
		output1		=> DataReg(1),
		output2		=> DataReg(2),
		output3		=> DataReg(3),
		output4		=> DataReg(4),
		output5		=> DataReg(5),
		output6		=> DataReg(6),
		output7		=> DataReg(7),
		output8		=> DataReg(8),
		output9		=> DataReg(9),
		output10		=> DataReg(10),
		output11		=> DataReg(11)
	);
	
	KeySch_EN : KeySchedule_EN
	port map
	(
		key_in		=> tb_key_in,
		roundkey1 	=> tb_roundkey1,
		roundkey2 	=> tb_roundkey2,
		roundkey3 	=> tb_roundkey3,
		roundkey4  	=> tb_roundkey4,
		roundkey5  	=> tb_roundkey5,
		roundkey6  	=> tb_roundkey6,
		roundkey7  	=> tb_roundkey7,
		roundkey8  	=> tb_roundkey8,
		roundkey9  	=> tb_roundkey9,
		roundkey10 	=> tb_roundkey10
	);
	
	finish <= tb_dn_finish;
	
	buffer_proc : process(tb_memwr , tb_stop_bit, tb_MIPS_clk, tb_rst)
	variable buff_counter : integer range 0 to 11 := 0;
	begin
		if tb_rst = '1' then
			buff_counter := 0;
			for i in 1 to 12 loop
				int_buffer_reg(i-1) <= (others => '0');
			end loop;
		elsif tb_memwr = '1' then
			if	rising_edge(tb_MIPS_clk) then
			int_buffer_reg(buff_counter) <= reg_t_out;
			buff_counter := buff_counter + 1;
			end if;
		end if;
	end process;
	
	rxd_proc : process(rxd_data_ready,  rst)
	variable rxd_counter : integer range 0 to 55 := 0;
	begin
		if rst = '1' then
			rxd_counter := 0;
			tb_rxd_ready <= '0';
			for i in 1 to 50 loop
				int_rxd_reg(i-1) <= (others => '0');
			end loop;
		elsif falling_edge(rxd_data_ready) then
			if bypass = '0' then
				if rxd_counter < 50 then
					tb_rxd_ready <= '0';
					int_rxd_reg(rxd_counter) <= rxd_data;
					rxd_counter := rxd_counter + 1;
				else 
					tb_rxd_ready <= '1';
				end if;
			end if;
		end if;
	end process;
	
	trigger_proc : process(tb_en_finish)
	begin
		if tb_en_finish = '1' then
			sig_232_enable <= '1';
		else sig_232_enable <= '0';
		end if;
	end process;

	
	state_proc : process(clk, rst)
	variable count : integer range 0 to 12 := 0;
	begin
		if rst = '1' then
			state <= idle;
			tb_dn_enable <= '0';
			tb_MIPS_rst <= '1';
			tb_Data_Write <= '0';
			count := 0;
			txd_start <= '0';
		elsif clk'event and clk = '1'
		then
			case state is
				when idle =>
					tb_MIPS_rst <= '1';
					tb_Data_Write <= '0';
					if bypass = '1' then
						state <= MIPS_start;
					elsif sig_232_enable = '1' then
						txd_start <= '1';
						state <= pubkey0_1;
					else state <= idle;
					end if;
				when DR0_0 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(143 downto 136);
						state <= DR0_1;
					end if;	
				when DR0_1 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(135 downto 128);
						state <= DR0_2;
					end if;	
				when DR0_2 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(127 downto 120);
						state <= DR0_3;
					end if;
				when DR0_3  =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(119 downto 112);
						state <= DR0_4;
					end if;
				when DR0_4 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(111 downto 104);
						state <= DR1_0;
					end if;
				when DR1_0 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(103 downto 96);
						state <= DR1_1;
					end if;
				when DR1_1 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(95 downto 88);
						state <= DR1_2;
					end if;
				when DR1_2 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(87 downto 80);
						state <= DR1_3;
					end if;
				when DR1_3 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(79 downto 72);
						state <= DR1_4;
					end if;
				when DR1_4 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(71 downto 64);
						state <= DR2_0;
					end if;
				when DR2_0 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(63 downto 56);
						state <= DR2_1;
					end if;	
				when DR2_1 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(55 downto 48);
						state <= DR2_2;
					end if;	
				when DR2_2 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(47 downto 40);
						state <= DR2_3;
					end if;
				when DR2_3  =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(39 downto 32);
						state <= DR2_4;
					end if;
				when DR2_4 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(31 downto 24);
						state <= DR3_0;
					end if;
				when DR3_0 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(23 downto 16);
						state <= DR3_1;
					end if;	
				when DR3_1 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(15 downto 8);
						state <= DR3_2;
					end if;	
				when DR3_2 =>
					if txd_busy = '0' then
						txd_data <= tb_ciphertext(7 downto 0);
						state <= pubkey0_1;
					end if;		
				when pubkey0_1 =>
					if txd_busy = '0' then
						txd_data <= tb_public_key(15 downto 8);
						state <= pubkey0_2;
					end if;
				when pubkey0_2 =>
					if txd_busy = '0' then
						txd_data <= tb_public_key(7 downto 0);
						state <= n0_1;
					end if;
				when n0_1 =>
					if txd_busy = '0' then
						txd_data <= "0000" & tb_n(35 downto 32);
						state <= n0_2;
					end if;
				when n0_2 =>
					if txd_busy = '0' then
						txd_data <= tb_n(31 downto 24);
						state <= n0_3;
					end if;
				when n0_3 =>
					if txd_busy = '0' then
						txd_data <= tb_n(23 downto 16);
						state <= n0_4;
					end if;
				when n0_4 =>
					if txd_busy = '0' then
						txd_data <= tb_n(15 downto 8);
						state <= n0_5;
					end if;
				when n0_5 =>
					if txd_busy = '0' then
						txd_data <= tb_n(7 downto 0);
						state <= stop1;
					end if;	
				when stop1 =>
					txd_start <= '0';
					if tb_rxd_ready = '1' then
						tb_ciphertext_in(143 downto 136) <= int_rxd_reg(0);
						tb_ciphertext_in(135 downto 128) <= int_rxd_reg(1);
						tb_ciphertext_in(127 downto 120) <= int_rxd_reg(2);
						tb_ciphertext_in(119 downto 112) <= int_rxd_reg(3);
						tb_ciphertext_in(111 downto 104) <= int_rxd_reg(4);
						tb_ciphertext_in(103 downto 96) 	<= int_rxd_reg(5);
						tb_ciphertext_in(95 downto 88)	<= int_rxd_reg(6);
						tb_ciphertext_in(87 downto 80) 	<= int_rxd_reg(7);
						tb_ciphertext_in(79 downto 72) 	<= int_rxd_reg(8);
						tb_ciphertext_in(71 downto 64) 	<= int_rxd_reg(9);
						tb_ciphertext_in(63 downto 56) 	<= int_rxd_reg(10);
						tb_ciphertext_in(55 downto 48) 	<= int_rxd_reg(11);
						tb_ciphertext_in(47 downto 40) 	<= int_rxd_reg(12);
						tb_ciphertext_in(39 downto 32) 	<= int_rxd_reg(13);
						tb_ciphertext_in(31 downto 24) 	<= int_rxd_reg(14);
						tb_ciphertext_in(23 downto 16) 	<= int_rxd_reg(15);
						tb_ciphertext_in(15 downto 8) 	<= int_rxd_reg(16);
						tb_ciphertext_in(7 downto 0) 		<= int_rxd_reg(17);
						tb_data1(127 downto 120) <= int_rxd_reg(18);
						tb_data1(119 downto 112) <= int_rxd_reg(19);
						tb_data1(111 downto 104) <= int_rxd_reg(20);
						tb_data1(103 downto 96) 	<= int_rxd_reg(21);
						tb_data1(95 downto 88)	<= int_rxd_reg(22);
						tb_data1(87 downto 80) 	<= int_rxd_reg(23);
						tb_data1(79 downto 72) 	<= int_rxd_reg(24);
						tb_data1(71 downto 64) 	<= int_rxd_reg(25);
						tb_data1(63 downto 56) 	<= int_rxd_reg(26);
						tb_data1(55 downto 48) 	<= int_rxd_reg(27);
						tb_data1(47 downto 40) 	<= int_rxd_reg(28);
						tb_data1(39 downto 32) 	<= int_rxd_reg(29);
						tb_data1(31 downto 24) 	<= int_rxd_reg(30);
						tb_data1(23 downto 16) 	<= int_rxd_reg(31);
						tb_data1(15 downto 8) 	<= int_rxd_reg(32);
						tb_data1(7 downto 0) 		<= int_rxd_reg(33);
						tb_data2(127 downto 120) <= int_rxd_reg(34);
						tb_data2(119 downto 112) <= int_rxd_reg(35);
						tb_data2(111 downto 104) <= int_rxd_reg(36);
						tb_data2(103 downto 96) 	<= int_rxd_reg(37);
						tb_data2(95 downto 88)	<= int_rxd_reg(38);
						tb_data2(87 downto 80) 	<= int_rxd_reg(39);
						tb_data2(79 downto 72) 	<= int_rxd_reg(40);
						tb_data2(71 downto 64) 	<= int_rxd_reg(41);
						tb_data2(63 downto 56) 	<= int_rxd_reg(42);
						tb_data2(55 downto 48) 	<= int_rxd_reg(43);
						tb_data2(47 downto 40) 	<= int_rxd_reg(44);
						tb_data2(39 downto 32) 	<= int_rxd_reg(45);
						tb_data2(31 downto 24) 	<= int_rxd_reg(46);
						tb_data2(23 downto 16) 	<= int_rxd_reg(47);
						tb_data2(15 downto 8) 	<= int_rxd_reg(48);
						tb_data2(7 downto 0) 		<= int_rxd_reg(49);				
						tb_Data_Write <= '1';
						state <= stop2;					
					else 
						state <= stop1;
					end if;
					
				when stop2 =>
					tb_dn_enable <= '1';
					tb_Data_Write <= '1';
					if tb_dn_finish = '1' then
						state <= key_set;
					else 
						txd_start <= '0';
						state <= stop2;
					end if;
				
				when key_set =>
					tb_key_in <= tb_plaintext;
					state <= MIPS_start;
				
				when MIPS_start =>
					tb_MIPS_rst <= '0';
					if tb_stop_bit = '0' then
						state <= MIPS_start;
					else state <= temp1;
					end if;
				
				when temp1 =>
					if txd_busy = '0' then
						txd_start <= '1';
						state <= DR4_1;
					end if;	
				when DR4_1 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(127 downto 120);
						state <= DR4_2;
					end if;	
				when DR4_2 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(119 downto 112);
						state <= DR4_3;
					end if;
				when DR4_3  =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(111 downto 104);
						state <= DR4_4;
					end if;
				when DR4_4 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(103 downto 96);
						state <= DR5_1;
					end if;
				when DR5_1 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(95 downto 88);
						state <= DR5_2;
					end if;	
				when DR5_2 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(87 downto 80);
						state <= DR5_3;
					end if;
				when DR5_3  =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(79 downto 72);
						state <= DR5_4;
					end if;
				when DR5_4 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(71 downto 64);
						state <= DR6_1;
					end if;	
				when DR6_1 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(63 downto 56);
						state <= DR6_2;
					end if;	
				when DR6_2 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(55 downto 48);
						state <= DR6_3;
					end if;
				when DR6_3  =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(47 downto 40);
						state <= DR6_4;
					end if;
				when DR6_4 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(39 downto 32);
						state <= DR7_1;
					end if;
				when DR7_1 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(31 downto 24);
						state <= DR7_2;
					end if;	
				when DR7_2 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(23 downto 16);
						state <= DR7_3;
					end if;
				when DR7_3  =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(15 downto 8);
						state <= DR7_4;
					end if;
				when DR7_4 =>
					if txd_busy = '0' then
						txd_data <= DataReg(count)(7 downto 0);
						count := count + 1;
						if count < 12 then
							state <= DR4_1;
						else
							count := 0;
							state <= t1;
						end if;			
					end if;
				when t1 =>
					if txd_busy = '0' then
						txd_data <= int_buffer_reg(count)(31 downto 24);
						state <= t2;
					end if;
				when t2 =>
					if txd_busy = '0' then
						txd_data <= int_buffer_reg(count)(23 downto 16);
						state <= t3;
					end if;
				when t3 =>
					if txd_busy = '0' then
						txd_data <= int_buffer_reg(count)(15 downto 8);
						state <= t4;
					end if;
				when t4 =>
					if txd_busy = '0' then
						txd_data <= int_buffer_reg(count)(7 downto 0);
						count := count + 1;
						if count < 12 then
							state <= t1;
						else
							count := 0;
							state <= endstate;
						end if;			
					end if;	
				when endstate =>
					state <= endstate;
					txd_start <= '0';
			end case;
		end if;
	end process state_proc;

	led_proc : process(clk)
	begin
		if clk'event and clk = '1' then
			if state /= idle then
				led <= '1';
			else
				led <= '0';
			end if;
		end if;
	end process led_proc;
end architecture UARTTestArch;