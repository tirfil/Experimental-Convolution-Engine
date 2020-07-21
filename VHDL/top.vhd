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

entity top is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		SCK			: in	std_logic;
		MOSI		: in	std_logic;
		MISO		: out	std_logic;
		SS			: in	std_logic;
		IDLE		: out	std_logic
	);
end top;

architecture mixed of top is
	component dp16384x16
		PORT
		(
			address_a	: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			address_b	: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			clock_a		: IN STD_LOGIC  := '1';
			clock_b		: IN STD_LOGIC 	:= '1';
			data_a		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '0';
			wren_b		: IN STD_LOGIC  := '0';
			q_a			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			q_b			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;
	component dp16x16
		PORT
		(
			address_a	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			address_b	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			clock_a		: IN STD_LOGIC  := '1';
			clock_b		: IN STD_LOGIC 	:= '1';
			data_a		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren_a		: IN STD_LOGIC  := '0';
			wren_b		: IN STD_LOGIC  := '0';
			q_a			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			q_b			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END component;
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
	
	--component pll
	--PORT
	--(
		--inclk0		: IN STD_LOGIC  := '0';
		--c0			: OUT STD_LOGIC 
	--);
	--end component;


signal nrstsync : std_logic;
signal nrst0, nrst1 : std_logic;
signal C0 : std_logic;
signal x,y : std_logic_vector(7 downto 0);
signal miso_i : std_logic;
signal xy, dq, kq, md, dout, mq0, mq1, mq2, word0 : std_logic_vector(15 downto 0);
signal start, idle_i, mwen0, mwen1, mwen2, logic0, wen : std_logic;
signal address_reg, wa, da : std_logic_vector(13 downto 0);
signal ka : std_logic_vector(3 downto 0);
begin

	PRESET: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			nrst0 <= '0';
			nrst1 <= '0';
			nrstsync <= '0';
		elsif (MCLK'event and MCLK = '1') then
			nrst0 <= '1';
			nrst1 <= nrst0;
			nrstsync <= nrst1;
		end if;
	end process PRESET;
	
	C0 <= MCLK; -- waiting PLL
	
	--I_pll : pll
		--port map (
			--inclk0 => MCLK,
			--c0 => C0
		--);
	
	MISO <= miso_i when SS='0' else 'Z';
	word0 <= (others=>'0');
	logic0 <= '0';
	
	I_spimicro_0 : spimicro
		port map (
			MCLK		=> MCLK,
			nRST		=> nrstsync,
			SS			=> SS,
			MOSI		=> MOSI,
			MISO		=> miso_i,
			SCK			=> SCK,
			XY			=> xy,
			START		=> start,
			IDLE		=> idle_i,
			MADDR		=> address_reg,
			MD			=> md,
			MQ0			=> mq0,
			MQ1			=> mq1,
			MQ2			=> mq2,
			MWEN0		=> mwen0,
			MWEN1		=> mwen1,
			MWEN2		=> mwen2
		);
		
	x <= xy(15 downto 8);
	y <= xy(7 downto 0);
	IDLE <= idle_i;
	
	I_vcore_0 : vcore
		port map (
			MCLK		=> MCLK,
			nRST		=> nrstsync,
			START		=> start,
			IDLE		=> idle_i,
			X		=> x,
			Y		=> y,
			DQ		=> dq,
			DA		=> da,
			KQ		=> kq,
			KA		=> ka,
			DOUT	=> dout,
			WA		=> wa,
			WEN		=> wen
		);
		
	I_input_mem : dp16384x16
		port map
		(
			address_a	=> address_reg,
			address_b	=> da,
			clock_a		=> c0,
			clock_b		=> c0,
			data_a		=> md,
			data_b		=> word0,
			wren_a		=> mwen0,
			wren_b		=> logic0,
			q_a			=> mq0,
			q_b			=> dq
		);
		
	I_output_mem : dp16384x16
		port map
		(
			address_a	=> address_reg,
			address_b	=> wa,
			clock_a		=> c0,
			clock_b		=> c0,
			data_a		=> md,
			data_b		=> dout,
			wren_a		=> mwen1,
			wren_b		=> wen,
			q_a			=> mq1,
			q_b			=> open
		);

	I_kernel_mem : dp16x16
		port map
		(
			address_a	=> address_reg(3 downto 0),
			address_b	=> ka,
			clock_a		=> c0,
			clock_b		=> c0,
			data_a		=> md,
			data_b		=> word0,
			wren_a		=> mwen2,
			wren_b		=> logic0,
			q_a			=> mq2,
			q_b			=> kq
		);		
	
end mixed;

