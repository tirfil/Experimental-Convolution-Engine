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

entity vcore is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		START		: in	std_logic;
		IDLE		: out	std_logic;
		X			: in	std_logic_vector(7 downto 0);
		Y			: in	std_logic_vector(7 downto 0);
		DQ			: in	std_logic_vector(15 downto 0);
		DA			: out	std_logic_vector(13 downto 0);
		KQ			: in	std_logic_vector(15 downto 0);
		KA			: out	std_logic_vector(3 downto 0);
		DOUT		: out	std_logic_vector(15 downto 0);
		WA			: out	std_logic_vector(13 downto 0);
		WEN			: out	std_logic
	);
end vcore;

architecture struct of vcore is
	component kernel
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			SYNC		: in	std_logic;
			LAST		: in	std_logic;
			SYNCOUT		: out	std_logic;
			IDLE		: out   std_logic;
			K		: in	std_logic_vector(15 downto 0);
			DIN		: in	std_logic_vector(15 downto 0);
			DOUT		: out	std_logic_vector(15 downto 0);
			DONE		: out	std_logic
		);
	end component;
	component delay3
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			KEN		: in	std_logic;
			DIN		: in	std_logic_vector(15 downto 0);
			DOUT	: out	std_logic_vector(15 downto 0)
		);
	end component;
	component controller
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			X		: in	std_logic_vector(7 downto 0);
			Y		: in	std_logic_vector(7 downto 0);
			START		: in	std_logic;
			IDLE		: out	std_logic;
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
	component output
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
	end component;
	
	signal SYNC0		: std_logic;
	signal LAST0		: std_logic;
	signal SYNC1		: std_logic;
	signal LAST1		: std_logic;
	signal SYNC2		: std_logic;
	signal LAST2		: std_logic;
	signal KEN			: std_logic;
	signal DONE0		: std_logic;
	signal DONE1		: std_logic;
	signal DONE2		: std_logic;
	signal D0			: std_logic_vector(15 downto 0);
	signal D1			: std_logic_vector(15 downto 0);
	signal D2			: std_logic_vector(15 downto 0);
	signal KQQ, KQQQ	: std_logic_vector(15 downto 0);
	signal IDLE0, IDLE1, IDLE2, IDLEC : std_logic;
	
begin

	IDLE <= IDLE0 and IDLE1 and IDLE2 and IDLEC;

	I_kernel_0 : kernel
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SYNC		=> SYNC0,
			LAST		=> LAST0,
			SYNCOUT		=> open,
			IDLE		=> IDLE0,
			K			=> KQ,
			DIN			=> DQ,
			DOUT		=> D0,
			DONE		=> DONE0
		);

	I_kernel_1 : kernel
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SYNC		=> SYNC1,
			LAST		=> LAST1,
			SYNCOUT		=> open,
			IDLE		=> IDLE1,
			K			=> KQQ,
			DIN			=> DQ,
			DOUT		=> D1,
			DONE		=> DONE1
		);

	I_kernel_2 : kernel
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SYNC		=> SYNC2,
			LAST		=> LAST2,
			SYNCOUT		=> open,
			IDLE		=> IDLE2,
			K			=> KQQQ,
			DIN			=> DQ,
			DOUT		=> D2,
			DONE		=> DONE2
		);

	I_delay3_1 : delay3
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			KEN			=> KEN,
			DIN			=> KQ,
			DOUT		=> KQQ
		);
		
	I_delay3_2 : delay3
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			KEN			=> KEN,
			DIN			=> KQQ,
			DOUT		=> KQQQ
		);
		
	I_controller_0 : controller
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			X			=> X,
			Y			=> Y,
			START		=> START,
			IDLE	=> IDLEC,
			KADDR		=> KA,
			DADDR		=> DA,
			SYNC0		=> SYNC0,
			LAST0		=> LAST0,
			SYNC1		=> SYNC1,
			LAST1		=> LAST1,
			SYNC2		=> SYNC2,
			LAST2		=> LAST2,
			KEN			=> KEN
		);
	I_output_0 : output
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			START		=> START,
			DONE0		=> DONE0,
			DONE1		=> DONE1,
			DONE2		=> DONE2,
			D0			=> D0,
			D1			=> D1,
			D2			=> D2,
			DOUT		=> DOUT,
			ADDR		=> WA,
			WEN		=> WEN
		);

end struct;

