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

entity micro is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		SS			: in	std_logic;
		SI			: in	std_logic_vector(7 downto 0);
		NSI			: in	std_logic_vector(3 downto 0);
		SO			: out	std_logic_vector(7 downto 0);
		ESI			: in	std_logic;
		ENSI		: in	std_logic;
		LSO			: in	std_logic;
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
end micro;

architecture rtl of micro is
constant STATUS_NIBBLE 		: std_logic_vector(3 downto 0) := x"1";
constant XY_NIBBLE 			: std_logic_vector(3 downto 0) := x"2";
constant MEM0_NIBBLE 		: std_logic_vector(3 downto 0) := x"4";
constant MEM1_NIBBLE 		: std_logic_vector(3 downto 0) := x"5";
constant MEM2_NIBBLE 		: std_logic_vector(3 downto 0) := x"6";

constant ADDR_CMD : std_logic_vector(7 downto 0) := x"00";
constant CTRL_CMD : std_logic_vector(7 downto 0) := x"01";
constant XY_CMD   : std_logic_vector(7 downto 0) := x"02";
constant MEM0_CMD : std_logic_vector(7 downto 0) := x"04";
constant MEM1_CMD : std_logic_vector(7 downto 0) := x"05";
constant MEM2_CMD : std_logic_vector(7 downto 0) := x"06";

signal SS1, SS2, SS3 : std_logic;
signal ESI1,ESI2,ESI3 : std_logic;
signal ENSI1,ENSI2, ENSI3 : std_logic;
signal LSO1, LSO2, LSO3 : std_logic;
signal SSP, ESIP, ENSIP, LSOP : std_logic;
type state_t is (S_IDLE, S_NIBBLE, S_CMD, S_WRITE, S_WRITE_NEXT, S_WRITE_LSB, S_WRITE_MSB, S_WAIT, S_READ_BYTE, S_READ_WORD, S_READ_LSB, S_READ_MSB );
signal state : state_t;
signal mem : integer range 0 to 2;
signal operation : std_logic_vector(7 downto 0);
signal address_reg : std_logic_vector(15 downto 0);
signal next_address : std_logic_vector(15 downto 0);
signal data_reg : std_logic_vector(15 downto 0);
signal status_reg : std_logic_vector(7 downto 0);
signal xy_reg : std_logic_vector(15 downto 0);

begin

	status_reg <= (0=>IDLE, others=>'0');
	MADDR <= address_reg(13 downto 0);
	MD <= data_reg;
	XY <= xy_reg;

	PRESYN: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			SS1<= '1'; SS2 <= '1'; SS3 <= '1';
			ESI1 <= '0'; ESI2 <='0'; ESI3 <= '0';
			ENSI1 <= '0'; ENSI2 <= '0'; ENSI3 <='0';
			LSO1<='0'; LSO2<='0'; LSO3 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			SS1 <= SS; SS2 <= SS1; SS3 <= SS2;
			ESI1 <= ESI; ESI2 <= ESI1; ESI3 <= ESI2;
			ENSI1 <= ENSI; ENSI2 <= ENSI1; ENSI3 <= ENSI2;
			LSO1 <= LSO; LSO2<= LSO1; LSO3 <= LSO2;
		end if;
	end process PRESYN;
	
	SSP <= not(SS3) and SS2;
	ESIP <= not(ESI3) and ESI2;
	ENSIP <= not(ENSI3) and ENSI2;
	LSOP <= not(LSO3) and LSO2;
	
	next_address <= (others=>'0') when address_reg = x"FFFF" else std_logic_vector(unsigned(address_reg) + 1);
	
	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			state <= S_IDLE;
			mem <= 0;
			SO <= (others=>'1');
			address_reg <= (others=>'0');
			xy_reg <= (others=>'0');
			data_reg <= (others=>'0');
			operation <= (others=>'1');
			START <= '0';
			MWEN0 <= '0';
			MWEN1 <= '0';
			MWEN2 <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_IDLE) then
				mem <= 0;
				SO <= (others=>'1');
				START <= '0';
				MWEN0 <= '0';
				MWEN1 <= '0';
				MWEN2 <= '0';
				operation <= (others=>'1');				
				if (ENSIP = '1') then
					state <= S_NIBBLE;
				end if;
			elsif ( state = S_NIBBLE) then
				case (NSI) is
					when STATUS_NIBBLE =>
						SO <= status_reg;
						state <= S_READ_BYTE;
					when XY_NIBBLE =>
						SO <= xy_reg(15 downto 8);
						state <= S_READ_WORD;
					when MEM0_NIBBLE => 
						SO <= MQ0(15 downto 8);
						mem <= 0;
						state <= S_READ_LSB;
					when MEM1_NIBBLE =>
						SO <= MQ1(15 downto 8);
						mem <= 1;
						state <= S_READ_LSB;						
					when MEM2_NIBBLE =>
						SO <= MQ2(15 downto 8);
						mem <= 2;
						state <= S_READ_LSB;
					when others =>
						SO <= (others=>'1');
						state <= S_CMD;
				end case;
			-- write
			elsif ( state = S_CMD) then
				if (ESIP = '1') then
					operation <= SI;
					state <= S_WRITE;
				end if;
			elsif (state = S_WRITE) then
				if (ESIP = '1') then
					case (operation) is
						when CTRL_CMD =>
							START <= SI(0);
							state <= S_IDLE;
						when ADDR_CMD =>
							address_reg(15 downto 8) <= SI;
							state <= S_WRITE_NEXT;
						when XY_CMD =>
							xy_reg(15 downto 8) <= SI;
							state <= S_WRITE_NEXT;
						when others => -- mem write
							data_reg(15 downto 8) <= SI;
							state <= S_WRITE_LSB;
					end case;
				end if;
			elsif (state = S_WRITE_NEXT) then
				if (ESIP = '1') then
					case (operation) is
						when ADDR_CMD =>
							address_reg(7 downto 0) <= SI;
							state <= S_IDLE;
						when XY_CMD =>
							xy_reg(7 downto 0) <= SI;
							state <= S_IDLE;
						when others =>
							state <= S_IDLE;
					end case;
				end if;
			elsif (state = S_WRITE_LSB) then
				if (SSP = '1') then
					state <= S_IDLE;
				elsif (ESIP = '1') then
					data_reg(7 downto 0) <= SI;
					case operation is
						when MEM0_CMD =>
							MWEN0 <= '1';
							state <= S_WRITE_MSB;
						when MEM1_CMD =>
							MWEN1 <= '1';
							state <= S_WRITE_MSB;
						when MEM2_CMD =>
							MWEN2 <= '1';
							state <= S_WRITE_MSB;
						when others =>
							state <= S_IDLE;
					end case;
				end if;
			elsif (state = S_WRITE_MSB) then
				MWEN0 <= '0';
				MWEN1 <= '0';
				MWEN2 <= '0';
				if (SSP = '1') then
					state <= S_IDLE;
					address_reg <= next_address; -- enable another burst
				elsif (ESIP = '1') then
					address_reg <= next_address;
					data_reg(15 downto 8) <= SI;
					state <= S_WRITE_LSB;
				end if;
			-- read
			elsif (state = S_WAIT) then
				if (SSP = '1') then
					SO <= (others=>'1');
					state <= S_IDLE;
				end if;
			elsif (state = S_READ_BYTE) then
				if (LSOP = '1') then
					state <= S_WAIT;
				end if;
			elsif (state = S_READ_WORD) then
				if (LSOP = '1') then
					SO <= xy_reg(7 downto 0);
					state <= S_READ_BYTE;
				end if;
			elsif (state = S_READ_LSB) then
				if (SSP = '1') then
					state <= S_IDLE;
					SO <= (others=>'1');			
				elsif (LSOP = '1') then
					case mem is
						when 0 =>
							SO <= MQ0(7 downto 0);
							state <= S_READ_MSB;
							address_reg <= next_address;
						when 1 => 
							SO <= MQ1(7 downto 0);
							state <= S_READ_MSB;
							address_reg <= next_address;
						when 2 =>
							SO <= MQ2(7 downto 0);
							state <= S_READ_MSB;
							address_reg <= next_address;
						when others =>
							state <= S_IDLE;
					end case;
				end if;
			elsif (state = S_READ_MSB) then
				if (SSP = '1') then
					state <= S_IDLE;
					SO <= (others=>'1');			
				elsif (LSOP = '1') then
					case mem is
						when 0 =>
							SO <= MQ0(15 downto 8);
							state <= S_READ_LSB;
						when 1 => 
							SO <= MQ1(15 downto 8);
							state <= S_READ_LSB;
						when 2 =>
							SO <= MQ2(15 downto 8);
							state <= S_READ_LSB;
						when others =>
							state <= S_IDLE;
					end case;
				end if;
			else
				state <= S_IDLE;
			end if;			
		end if;
	end process POTO;

end rtl;

