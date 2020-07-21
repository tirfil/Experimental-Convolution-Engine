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

entity tb_controller is
end tb_controller;

architecture stimulus of tb_controller is

-- COMPONENTS --
	component controller
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			X		: in	std_logic_vector(7 downto 0);
			Y		: in	std_logic_vector(7 downto 0);
			START		: in	std_logic;
			KADDR		: out	std_logic_vector(3 downto 0);
			DADDR		: out	std_logic_vector(13 downto 0);
			SYNC0		: out	std_logic;
			LAST0		: out	std_logic;
			SYNC1		: out	std_logic;
			LAST1		: out	std_logic;
			SYNC2		: out	std_logic;
			LAST2		: out	std_logic;
			KEN		: out	std_logic
		);
	end component;

--
-- SIGNALS --
	signal MCLK		: std_logic;
	signal nRST		: std_logic;
	signal X		: std_logic_vector(7 downto 0);
	signal Y		: std_logic_vector(7 downto 0);
	signal START		: std_logic;
	signal KADDR		: std_logic_vector(3 downto 0);
	signal DADDR		: std_logic_vector(13 downto 0);
	signal SYNC0		: std_logic;
	signal LAST0		: std_logic;
	signal SYNC1		: std_logic;
	signal LAST1		: std_logic;
	signal SYNC2		: std_logic;
	signal LAST2		: std_logic;
	signal KEN		: std_logic;

--
	signal RUNNING	: std_logic := '1';

begin

-- PORT MAP --
	I_controller_0 : controller
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			X		=> X,
			Y		=> Y,
			START		=> START,
			KADDR		=> KADDR,
			DADDR		=> DADDR,
			SYNC0		=> SYNC0,
			LAST0		=> LAST0,
			SYNC1		=> SYNC1,
			LAST1		=> LAST1,
			SYNC2		=> SYNC2,
			LAST2		=> LAST2,
			KEN		=> KEN
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
		X <= x"07";
		Y <= x"05";
		START <= '0';
		wait for 101 ns;
		nRST <= '1';
		wait for 20 ns;
		START <= '1';
		wait for 20 ns;
		START <= '0';
		wait for 20000 ns;
		RUNNING <= '0';
		wait;
	end process GO;

end stimulus;
