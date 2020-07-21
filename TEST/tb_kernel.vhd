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

entity tb_kernel is
end tb_kernel;

architecture stimulus of tb_kernel is

-- COMPONENTS --
	component kernel
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			SYNC		: in	std_logic;
			LAST		: in	std_logic;
			SYNCOUT		: out	std_logic;
			K			: in	std_logic_vector(15 downto 0);
			DIN			: in	std_logic_vector(15 downto 0);
			DOUT		: out	std_logic_vector(15 downto 0);
			DONE		: out	std_logic
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal SYNC		: std_logic;
	signal LAST		: std_logic;
	signal SYNCOUT		: std_logic;
	signal K		: std_logic_vector(15 downto 0);
	signal DIN		: std_logic_vector(15 downto 0);
	signal DOUT		: std_logic_vector(15 downto 0);
	signal DONE		: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_kernel_0 : kernel
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SYNC		=> SYNC,
			LAST		=> LAST,
			SYNCOUT		=> SYNCOUT,
			K		=> K,
			DIN		=> DIN,
			DOUT		=> DOUT,
			DONE		=> DONE
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

	GO: process
	begin
		nRST <= '0';
		SYNC <= '0';
		K <= (others=>'0');
		DIN <= (others=>'0');
		LAST <= '0';
		wait for 101 ns;
		nRST <= '1';
		wait for 20 ns;
		SYNC <= '1';
		wait for 20 ns;
		SYNC <= '0';
--
		K <= 	x"3C00"; --1
		DIN <= 	x"0000"; -- 0
		wait for 40 ns;
		K <= 	x"BC00"; -- -1
		DIN <= 	x"3C00"; -- 1
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4000"; -- 2
		wait for 80 ns;	
		K <= 	x"BC00";
		DIN <= 	x"4200"; -- 3
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4400"; -- 4
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4500"; -- 5
		wait for 80 ns;	
		K <= 	x"3C00";
		DIN <= 	x"4600"; -- 6
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4700"; -- 7
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4800"; -- 8
		wait for 80 ns;	
--
		K <= 	x"3C00"; --1
		DIN <= 	x"0000"; -- 0
		wait for 40 ns;
		K <= 	x"BC00"; -- -1
		DIN <= 	x"3C00"; -- 1
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4000"; -- 2
		wait for 80 ns;	
		K <= 	x"BC00";
		DIN <= 	x"4200"; -- 3
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4400"; -- 4
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4500"; -- 5
		wait for 80 ns;	
		K <= 	x"3C00";
		DIN <= 	x"4600"; -- 6
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4700"; -- 7
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4800"; -- 8
		wait for 60 ns;	
		LAST <= '1';
		wait for 20 ns;	
		LAST <= '0';
-- 
		K <= 	x"3C00"; --1
		DIN <= 	x"0000"; -- 0
		wait for 40 ns;
		K <= 	x"BC00"; -- -1
		DIN <= 	x"3C00"; -- 1
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4000"; -- 2
		wait for 80 ns;	
		K <= 	x"BC00";
		DIN <= 	x"4200"; -- 3
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4400"; -- 4
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4500"; -- 5
		wait for 80 ns;	
		K <= 	x"3C00";
		DIN <= 	x"4600"; -- 6
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4700"; -- 7
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4800"; -- 8
		wait for 80 ns;	
--
		K <= 	x"3C00"; --1
		DIN <= 	x"0000"; -- 0
		wait for 40 ns;
		K <= 	x"BC00"; -- -1
		DIN <= 	x"3C00"; -- 1
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4000"; -- 2
		wait for 80 ns;	
		K <= 	x"BC00";
		DIN <= 	x"4200"; -- 3
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4400"; -- 4
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4500"; -- 5
		wait for 80 ns;	
		K <= 	x"3C00";
		DIN <= 	x"4600"; -- 6
		wait for 40 ns;
		K <= 	x"BC00";
		DIN <= 	x"4700"; -- 7
		wait for 40 ns;
		K <= 	x"3C00";
		DIN <= 	x"4800"; -- 8
		wait for 80 ns;			
		wait for 480 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
