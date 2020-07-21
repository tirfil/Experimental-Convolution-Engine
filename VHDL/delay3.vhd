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

entity delay3 is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		KEN			: in	std_logic;
		DIN			: in	std_logic_vector(15 downto 0);
		DOUT		: out	std_logic_vector(15 downto 0)
	);
end delay3;

architecture rtl of delay3 is
signal reg0, reg1, reg2 : std_logic_vector(15 downto 0);
begin

	DOUT <= reg2;

	PREG: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			reg0 <= (others=>'0');
			reg1 <= (others=>'0');
			reg2 <= (others=>'0');
		elsif (MCLK'event and MCLK = '1') then
			if (KEN = '1') then
				reg0 <= DIN;
				reg1 <= reg0;
				reg2 <= reg1;
			end if;
		end if;
	end process PREG;

end rtl;

