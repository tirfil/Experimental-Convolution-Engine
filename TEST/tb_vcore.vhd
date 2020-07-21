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

entity tb_vcore is
end tb_vcore;

architecture stimulus of tb_vcore is

-- COMPONENTS --
	component vcore
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			START		: in	std_logic;
			IDLE		: out	std_logic;
			X		: in	std_logic_vector(7 downto 0);
			Y		: in	std_logic_vector(7 downto 0);
			DQ		: in	std_logic_vector(15 downto 0);
			DA		: out	std_logic_vector(13 downto 0);
			KQ		: in	std_logic_vector(15 downto 0);
			KA		: out	std_logic_vector(3 downto 0);
			DOUT		: out	std_logic_vector(15 downto 0);
			WA		: out	std_logic_vector(13 downto 0);
			WEN		: out	std_logic
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal START		: std_logic;
	signal X		: std_logic_vector(7 downto 0);
	signal Y		: std_logic_vector(7 downto 0);
	signal DQ		: std_logic_vector(15 downto 0);
	signal DA		: std_logic_vector(13 downto 0);
	signal KQ		: std_logic_vector(15 downto 0);
	signal KA		: std_logic_vector(3 downto 0);
	signal DOUT		: std_logic_vector(15 downto 0);
	signal WA		: std_logic_vector(13 downto 0);
	signal WEN		: std_logic;
	signal IDLE		: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin
-- PORT MAP --
	I_vcore_0 : vcore
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			START		=> START,
			IDLE		=> IDLE,
			X		=> X,
			Y		=> Y,
			DQ		=> DQ,
			DA		=> DA,
			KQ		=> KQ,
			KA		=> KA,
			DOUT		=> DOUT,
			WA		=> WA,
			WEN		=> WEN
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
		X <= x"10";
		Y <= x"08";
		DQ <= x"3C00";
		KQ <= x"3C00";
		START <='0';
		wait for 101 ns;
		nRST <= '1';
		wait for 20 ns;
		START <= '1';
		wait for 20 ns;
		START <= '0';
		wait for 100 ns;
		wait until idle='1';
		wait for 1000 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
