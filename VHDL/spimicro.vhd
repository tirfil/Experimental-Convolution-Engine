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

entity spimicro is
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
end spimicro;

architecture struct of spimicro is
	component micro
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			SS		: in	std_logic;
			SI		: in	std_logic_vector(7 downto 0);
			NSI		: in	std_logic_vector(3 downto 0);
			SO		: out	std_logic_vector(7 downto 0);
			ESI		: in	std_logic;
			ENSI		: in	std_logic;
			LSO		: in	std_logic;
			XY		: out	std_logic_vector(15 downto 0);
			START		: out	std_logic;
			IDLE		: in	std_logic;
			MADDR		: out	std_logic_vector(13 downto 0);
			MD		: out	std_logic_vector(15 downto 0);
			MQ0		: in	std_logic_vector(15 downto 0);
			MQ1		: in	std_logic_vector(15 downto 0);
			MQ2		: in	std_logic_vector(15 downto 0);
			MWEN0		: out	std_logic;
			MWEN1		: out	std_logic;
			MWEN2		: out	std_logic
		);
	end component;
	component spislave
		port(
			SCK			: in	std_logic;
			SS			: in	std_logic;
			MOSI		: in	std_logic;
			MISO		: out	std_logic;
			PIN			: out	std_logic_vector(7 downto 0);
			VALID		: out	std_logic;
			POUT		: in	std_logic_vector(7 downto 0);
			LOAD		: out	std_logic;
			NIBBLE		: out	std_logic_vector(3 downto 0);
			VALNIB		: out	std_logic
		);
	end component;
	
	signal SI		: std_logic_vector(7 downto 0);
	signal NSI		: std_logic_vector(3 downto 0);
	signal SO		: std_logic_vector(7 downto 0);
	signal ESI		: std_logic;
	signal ENSI		: std_logic;
	signal LSO		: std_logic;
begin
	I_micro_0 : micro
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SS		=> SS,
			SI		=> SI,
			NSI		=> NSI,
			SO		=> SO,
			ESI		=> ESI,
			ENSI		=> ENSI,
			LSO		=> LSO,
			XY		=> XY,
			START		=> START,
			IDLE		=> IDLE,
			MADDR		=> MADDR,
			MD		=> MD,
			MQ0		=> MQ0,
			MQ1		=> MQ1,
			MQ2		=> MQ2,
			MWEN0		=> MWEN0,
			MWEN1		=> MWEN1,
			MWEN2		=> MWEN2
		);
	I_spislave_0 : spislave
		port map (
			SCK			=> SCK,
			SS			=> SS,
			MOSI		=> MOSI,
			MISO		=> MISO,
			PIN			=> SI,
			VALID		=> ESI,
			POUT		=> SO,
			LOAD		=> LSO,
			NIBBLE		=> NSI,
			VALNIB		=> ENSI
		);		
end struct;

