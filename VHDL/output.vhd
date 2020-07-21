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

entity output is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		START		: in	std_logic;
		DONE0		: in	std_logic;
		DONE1		: in	std_logic;
		DONE2		: in	std_logic;
		D0			: in	std_logic_vector(15 downto 0);
		D1			: in	std_logic_vector(15 downto 0);
		D2			: in	std_logic_vector(15 downto 0);
		DOUT		: out	std_logic_vector(15 downto 0);
		ADDR		: out	std_logic_vector(13 downto 0);
		WEN			: out	std_logic
	);
end output;

architecture rtl of output is
signal done : std_logic;
signal write : std_logic;
signal address : std_logic_vector(13 downto 0);
begin

	PMUX: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			DOUT <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (DONE0 = '1') then
				DOUT <= D0;
			elsif (DONE1 = '1') then
				DOUT <= D1;
			elsif (DONE2 = '1') then
				DOUT <= D2;
			end if;
		end if;
	end process PMUX;
	
	done <= DONE0 or DONE1 or DONE2;
	
	WEN <= write;
	ADDR <= address;
	
	PWR: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			address <= (others=>'0');
			write <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (START = '1') then
				address <= (others=>'0');
			end if;
			if (done = '1') then
				write <= '1';
			else
				write <= '0';
			end if;
			if (write = '1') then
				address <= std_logic_vector(unsigned(address)+1);
			end if;
		end if;
	end process PWR;

end rtl;

