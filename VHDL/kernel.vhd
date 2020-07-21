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

entity kernel is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		SYNC		: in	std_logic;
		LAST		: in	std_logic;
		SYNCOUT		: out	std_logic;
		IDLE		: out	std_logic;
		K			: in	std_logic_vector(15 downto 0);
		DIN			: in	std_logic_vector(15 downto 0);
		DOUT		: out	std_logic_vector(15 downto 0);
		DONE		: out	std_logic
	);
end kernel;

architecture rtl of kernel is

	component kernel9
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			SYNC		: in	std_logic;
			LAST		: in	std_logic;
			K		: in	std_logic_vector(15 downto 0);
			DIN		: in	std_logic_vector(15 downto 0);
			DONE		: out	std_logic;
			IDLE		: out	std_logic;
			MULT1INA		: out	std_logic_vector(15 downto 0);
			MULT1INB		: out	std_logic_vector(15 downto 0);
			MULT1OUT		: in	std_logic_vector(15 downto 0);
			MULT1START		: out	std_logic;
			MULT2INA		: out	std_logic_vector(15 downto 0);
			MULT2INB		: out	std_logic_vector(15 downto 0);
			MULT2OUT		: in	std_logic_vector(15 downto 0);
			MULT2START		: out	std_logic;
			ADDER1INA		: out	std_logic_vector(15 downto 0);
			ADDER1INB		: out	std_logic_vector(15 downto 0);
			ADDER1OUT		: in	std_logic_vector(15 downto 0);
			ADDER1START		: out	std_logic;
			ADDER2INA		: out	std_logic_vector(15 downto 0);
			ADDER2INB		: out	std_logic_vector(15 downto 0);
			ADDER2OUT		: in	std_logic_vector(15 downto 0);
			ADDER2START		: out	std_logic;
			ADDER3INA		: out	std_logic_vector(15 downto 0);
			ADDER3INB		: out	std_logic_vector(15 downto 0);
			ADDER3OUT		: in	std_logic_vector(15 downto 0);
			ADDER3START		: out	std_logic;
			DOUT		: out	std_logic_vector(15 downto 0);
			SYNCOUT		: out	std_logic
		);
	end component;
	
	component fp16adder
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			IN1			: in	std_logic_vector(15 downto 0);
			IN2			: in	std_logic_vector(15 downto 0);
			OUT0		: out	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			DONE		: out	std_logic
		);
	end component;
	component fp16mult
		port(
			MCLK		: in	std_logic;
			nRST		: in	std_logic;
			IN1			: in	std_logic_vector(15 downto 0);
			IN2			: in	std_logic_vector(15 downto 0);
			OUT0		: out	std_logic_vector(15 downto 0);
			START		: in	std_logic;
			DONE		: out	std_logic
		);
	end component;	


	signal MULT1INA		: std_logic_vector(15 downto 0);
	signal MULT1INB		: std_logic_vector(15 downto 0);
	signal MULT1OUT		: std_logic_vector(15 downto 0);
	signal MULT1START		: std_logic;
	signal MULT2INA		: std_logic_vector(15 downto 0);
	signal MULT2INB		: std_logic_vector(15 downto 0);
	signal MULT2OUT		: std_logic_vector(15 downto 0);
	signal MULT2START		: std_logic;
	signal ADDER1INA		: std_logic_vector(15 downto 0);
	signal ADDER1INB		: std_logic_vector(15 downto 0);
	signal ADDER1OUT		: std_logic_vector(15 downto 0);
	signal ADDER1START		: std_logic;
	signal ADDER2INA		: std_logic_vector(15 downto 0);
	signal ADDER2INB		: std_logic_vector(15 downto 0);
	signal ADDER2OUT		: std_logic_vector(15 downto 0);
	signal ADDER2START		: std_logic;
	signal ADDER3INA		: std_logic_vector(15 downto 0);
	signal ADDER3INB		: std_logic_vector(15 downto 0);
	signal ADDER3OUT		: std_logic_vector(15 downto 0);
	signal ADDER3START		: std_logic;
	--signal IDLE : std_logic;
		
begin

	I_fp16mult_1 : fp16mult
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> MULT1INA,
			IN2			=> MULT1INB,
			OUT0		=> MULT1OUT,
			START		=> MULT1START,
			DONE		=> open
		);
		
	I_fp16mult_2 : fp16mult
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> MULT2INA,
			IN2			=> MULT2INB,
			OUT0		=> MULT2OUT,
			START		=> MULT2START,
			DONE		=> open
		);
		
	I_fp16adder_1 : fp16adder
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> ADDER1INA,
			IN2			=> ADDER1INB,
			OUT0		=> ADDER1OUT,
			START		=> ADDER1START,
			DONE		=> open
		);
		
	I_fp16adder_2 : fp16adder
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> ADDER2INA,
			IN2			=> ADDER2INB,
			OUT0		=> ADDER2OUT,
			START		=> ADDER2START,
			DONE		=> open
		);

	I_fp16adder_3 : fp16adder
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			IN1			=> ADDER3INA,
			IN2			=> ADDER3INB,
			OUT0		=> ADDER3OUT,
			START		=> ADDER3START,
			DONE		=> open
		);


	I_kernel9_0 : kernel9
		port map (
			MCLK		=> MCLK,
			nRST		=> nRST,
			SYNC		=> SYNC,
			LAST		=> LAST,
			K			=> K,
			DIN			=> DIN,
			DONE		=> DONE,
			IDLE => IDLE,
			MULT1INA		=> MULT1INA,
			MULT1INB		=> MULT1INB,
			MULT1OUT		=> MULT1OUT,
			MULT1START		=> MULT1START,
			MULT2INA		=> MULT2INA,
			MULT2INB		=> MULT2INB,
			MULT2OUT		=> MULT2OUT,
			MULT2START		=> MULT2START,
			ADDER1INA		=> ADDER1INA,
			ADDER1INB		=> ADDER1INB,
			ADDER1OUT		=> ADDER1OUT,
			ADDER1START		=> ADDER1START,
			ADDER2INA		=> ADDER2INA,
			ADDER2INB		=> ADDER2INB,
			ADDER2OUT		=> ADDER2OUT,
			ADDER2START		=> ADDER2START,
			ADDER3INA		=> ADDER3INA,
			ADDER3INB		=> ADDER3INB,
			ADDER3OUT		=> ADDER3OUT,
			ADDER3START		=> ADDER3START,
			DOUT		=> DOUT,
			SYNCOUT		=> SYNCOUT
		);



end rtl;

