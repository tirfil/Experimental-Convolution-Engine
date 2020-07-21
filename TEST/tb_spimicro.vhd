--###############################
--# Project Name : 
--# File         : 
--# Author       : 
--# Description  : 
--# Modification History
--#
--###############################

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_spimicro is
end tb_spimicro;

architecture stimulus of tb_spimicro is

-- COMPONENTS --
	component spimicro
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			SS			: in	std_logic;
			MOSI		: in	std_logic;
			MISO		: out	std_logic;
			SCK			: in	std_logic;
			XY			: out	std_logic_vector(15 downto 0);
			START		: out	std_logic;
			IDLE		: in	std_logic;
			MADDR		: out	std_logic_vector(13 downto 0);
			MD			: out	std_logic_vector(15 downto 0);
			MQ0			: in	std_logic_vector(15 downto 0);
			MQ1			: in	std_logic_vector(15 downto 0);
			MQ2			: in	std_logic_vector(15 downto 0);
			MWEN0		: out	std_logic;
			MWEN1		: out	std_logic;
			MWEN2		: out	std_logic
		);
	end component;
	
	constant TCK	: time := 20 ns;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal SS		: std_logic;
	signal MOSI		: std_logic;
	signal MISO		: std_logic;
	signal SCK		: std_logic;
	signal XY		: std_logic_vector(15 downto 0);
	signal START	: std_logic;
	signal IDLE		: std_logic;
	signal MADDR	: std_logic_vector(13 downto 0);
	signal MD		: std_logic_vector(15 downto 0);
	signal MQ0		: std_logic_vector(15 downto 0);
	signal MQ1		: std_logic_vector(15 downto 0);
	signal MQ2		: std_logic_vector(15 downto 0);
	signal MWEN0	: std_logic;
	signal MWEN1	: std_logic;
	signal MWEN2	: std_logic;

--
	signal RUNNING	: std_logic := '1';
	
	subtype byte_type is  std_logic_vector(7 downto 0);
	type byte_array is array (integer range <> ) of byte_type;
	
	--signal bytes : byte_array(0 to 31);

begin

	IDLE <= '1';
	MQ0 <= x"F00F";
	MQ1 <= x"F10E";
	MQ2 <= x"F20D";	

-- PORT MAP --
	I_spimicro_0 : spimicro
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SS			=> SS,
			MOSI		=> MOSI,
			MISO		=> MISO,
			SCK			=> SCK,
			XY			=> XY,
			START		=> START,
			IDLE		=> IDLE,
			MADDR		=> MADDR,
			MD			=> MD,
			MQ0			=> MQ0,
			MQ1			=> MQ1,
			MQ2			=> MQ2,
			MWEN0		=> MWEN0,
			MWEN1		=> MWEN1,
			MWEN2		=> MWEN2
		);

--
	CLOCK: process
	begin
		while (RUNNING = '1') loop
			MCLK <= '1';
			wait for 10 ns;
			MCLK <= '0';
			wait for 10 ns;
		end loop;
		wait;
	end process CLOCK;
	
	P_MISO: process(SCK,SS)
	variable temp : std_logic_vector(7 downto 0);
	variable i : integer;
	begin
		if (SS='1') then
			temp := (others=>'0');
			i := 0;
		elsif (SCK='1' and SCK'event) then
			temp(7 downto 1) := temp(6 downto 0);
			temp(0) := MISO;
			i := i mod 8 + 1;
			assert(i/=8) report "=> " & integer'image(to_integer(unsigned(temp))) severity note;
		end if;
	end process P_MISO;

	GO: process
	procedure send(value : std_logic_vector) is
		variable temp : std_logic_vector(7 downto 0);
	begin
		temp := value;
		for I in 0 to 7 loop
			MOSI <= temp(7); 
			wait for TCK;
			SCK <= '1';
			wait for TCK;
			SCK <= '0';
			temp(7 downto 1) := temp(6 downto 0);
		end loop;
	end send;
	
	procedure spisend(len : integer; values : byte_array) is
	begin
		SS <= '0';
		for I in 0 to len-1 loop
			send(values(I));
		end loop;
		SS <= '1';
		wait for 2*TCK;
	end spisend;
	
	variable bytes : byte_array(0 to 31);
	begin
		nRST <= '0';
		SCK <= '0';
		MOSI <= '0';
		SS <= '1';
		wait for 1001 ns;
		nRST <= '1';
		wait for 100 ns;
		-- address 2A55
		bytes := (x"00",x"AA",x"55",others=>(x"FF"));
		-- xy 55AA
		spisend(3,bytes);
		bytes := (x"02",x"55",x"AA",others=>(x"FF"));
		spisend(3,bytes);		
		bytes := (x"20",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		-- read status
		bytes := (x"10",x"00",others=>(x"FF"));
		spisend(2,bytes);		
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		-- write mem 2
		bytes := (x"06",x"FE",x"01",x"FD",x"02",x"FC",x"03",others=>(x"FF"));
		spisend(7,bytes);
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		-- write mem 1
		bytes := (x"05",x"FE",x"01",x"FD",x"02",x"FC",x"03",others=>(x"FF"));
		spisend(7,bytes);
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		-- write mem 0
		bytes := (x"04",x"FE",x"01",x"FD",x"02",x"FC",x"03",others=>(x"FF"));
		spisend(7,bytes);
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);		
		-- read mem 2
		bytes := (x"60",others=>(x"00"));
		spisend(7,bytes);
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);	
		-- read mem 1
		bytes := (x"50",others=>(x"00"));
		spisend(7,bytes);
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);	
		-- read mem 0
		bytes := (x"40",others=>(x"00"));
		spisend(7,bytes);
		wait for 100 ns;
		-- address 00
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		-- write mem 0
		bytes := (x"04",x"FE",x"01",x"FD",x"02",x"FC",x"03",others=>(x"FF"));
		spisend(7,bytes);
		-- write mem 0
		bytes := (x"04",x"FB",x"04",x"FA",x"05",x"F9",x"06",others=>(x"FF"));
		spisend(7,bytes);	
		-- start
		bytes := (x"01",x"01",others=>(x"FF"));		
		spisend(2,bytes);
		wait for 100 ns;
		wait for 100 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
