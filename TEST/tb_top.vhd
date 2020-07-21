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

--constant ADDR_CMD : std_logic_vector(7 downto 0) := x"00";
--constant CTRL_CMD : std_logic_vector(7 downto 0) := x"01";
--constant XY_CMD   : std_logic_vector(7 downto 0) := x"02";
--constant MEM0_CMD : std_logic_vector(7 downto 0) := x"04";
--constant MEM1_CMD : std_logic_vector(7 downto 0) := x"05";
--constant MEM2_CMD : std_logic_vector(7 downto 0) := x"06";

entity tb_top is
end tb_top;

architecture stimulus of tb_top is

-- COMPONENTS --
	component top
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			SCK		: in	std_logic;
			MOSI		: in	std_logic;
			MISO		: out	std_logic;
			SS		: in	std_logic;
			IDLE		: out	std_logic
		);
	end component;

	constant TCK	: time := 20 ns;
--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal SCK		: std_logic;
	signal MOSI		: std_logic;
	signal MISO		: std_logic;
	signal SS		: std_logic;
	signal IDLE		: std_logic;

--
	signal RUNNING	: std_logic := '1';
	
	subtype byte_type is  std_logic_vector(7 downto 0);
	type byte_array is array (integer range <> ) of byte_type;

begin

-- PORT MAP --
	I_top_0 : top
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SCK		=> SCK,
			MOSI		=> MOSI,
			MISO		=> MISO,
			SS		=> SS,
			IDLE		=> IDLE
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
		wait for 101 ns;
		nRST <= '1';
		wait for 100 ns;
		-- address zero
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		report "write kernel";
		-- kernel (mem2) [ [-1, 0, -1], [0, 4, O], [-1, 0, -1]]
		-- 0 	=> 0x0000
		-- -1	=> 0xBC00
		-- 4	=> 0x4400
		bytes := (x"06",x"BC",x"00",x"00",x"00",x"BC",x"00",others=>(x"FF"));
		spisend(7,bytes);		
		bytes := (x"06",x"00",x"00",x"44",x"00",x"00",x"00",others=>(x"FF"));
		spisend(7,bytes);
		bytes := (x"06",x"BC",x"00",x"00",x"00",x"BC",x"00",others=>(x"FF"));
		spisend(7,bytes);
		-- xy 10 x 10
		bytes := (x"02",x"0A",x"0A",others=>(x"FF"));
		spisend(3,bytes);
		-- address zero
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		report "write matrix";
		-- input matrix (mem0) 10 x 10
		-- 64 	=> 0x5400
		-- 0 	=> 0x0000
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		bytes := (x"04",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",x"00",x"00",x"54",x"00",others=>(x"FF"));
		spisend(21,bytes);	
		-- read ctrl
		bytes := (x"10",x"00",others=>(x"FF"));	
		spisend(2,bytes);
		report "start";
		-- start
		bytes := (x"01",x"01",others=>(x"FF"));		
		spisend(2,bytes);
		bytes := (x"10",x"00",others=>(x"FF"));	
		spisend(2,bytes);
		wait for 100 * 8 * TCK;	
		-- read ctrl
		bytes := (x"10",x"00",others=>(x"FF"));	
		spisend(2,bytes);
		-- address zero
		bytes := (x"00",x"00",x"00",others=>(x"FF"));
		spisend(3,bytes);
		report "read matrix";
		-- output matrix read 8 x 8	(mem1)	
		-- 256 	=> 0x5C00 --> 92d 00d
		-- -256	=> 0xDC00 --> 220d 00d
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		bytes := (x"50",others=>(x"00"));
		spisend(17,bytes);   -- 8x2 + 1
		wait for 200 ns;				
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
