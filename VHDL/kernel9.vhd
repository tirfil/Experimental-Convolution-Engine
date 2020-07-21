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

entity kernel9 is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		SYNC		: in	std_logic;
		LAST		: in	std_logic;
		K			: in	std_logic_vector(15 downto 0);
		DIN			: in	std_logic_vector(15 downto 0);
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
		DOUT			: out	std_logic_vector(15 downto 0);
		SYNCOUT			: out   std_logic
	);
end kernel9;

architecture rtl of kernel9 is
signal icnt : integer range 0 to 23;
signal nexticnt : integer range 0 to 23;
type t_state is (S_IDLE,S_CNT);
signal state : t_state;
signal nextvcnt : std_logic_vector(4 downto 0);
signal REG1, REG2, REG3 : std_logic_vector(15 downto 0);
signal last1, last2 : std_logic;
signal nodone : std_logic;
begin

	nexticnt <= 0 when icnt=23 else icnt+1;
	nextvcnt <= std_logic_vector(to_unsigned(nexticnt,5));
	-- fixed inputs
	ADDER1INA <= REG1;
	ADDER1INB <= MULT2OUT;
	ADDER2INA <= REG2;
	DOUT <= ADDER3OUT;
	MULT1INA <= DIN;
	MULT2INA <= DIN;
	MULT1INB <= K; 
	MULT2INB <= K; 
	-- mux
	ADDER2INB <= ADDER1OUT when icnt = 13 else MULT1OUT; --0
	ADDER3INA <= REG2 when icnt = 5 else REG3; -- 20 and 12
	ADDER3INB <= ADDER2OUT when icnt = 20 else
				 ADDER1OUT when icnt = 5 else ADDER3OUT; -- 12
				 
	IDLE <= '1' when state=S_IDLE else '0';
	
	POTO: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			state <= S_IDLE;
			icnt <= 23;
			--MULT1INA <= (others=>'0');
			--MULT1INB <= (others=>'0');
			MULT1START <= '0';
			--MULT2INA <= (others=>'0');
			--MULT2INB <= (others=>'0');
			MULT2START <= '0';
			--ADDER1INA <= (others=>'0');
			--ADDER1INB <= (others=>'0');
			ADDER1START <= '0';
			--ADDER2INA <= (others=>'0');
			--ADDER2INB <= (others=>'0');
			ADDER2START <= '0';			
			--ADDER3INA <= (others=>'0');
			--ADDER3INB <= (others=>'0');
			ADDER3START <= '0';
			REG1 <= (others=>'1');
			REG2 <= (others=>'1');
			REG3 <= (others=>'1');
			DONE <= '0';
			last1 <= '0';
			last2 <= '0';
			nodone <= '1';
			SYNCOUT <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if (state = S_CNT) then
				-- regular changes
				if (nextvcnt(1 downto 0) = "00") then
					MULT1START <= '1';
				else
					MULT1START <= '0';
				end if;
				if (nextvcnt(2 downto 0) = "010") then
					MULT2START <= '1';
				else
					MULT2START <= '0';
				end if;			
				if (nextvcnt(2 downto 0) = "110") then
					ADDER1START <= '1';
				else
					ADDER1START <= '0';
				end if;
				-- 
				--if (nextvcnt(2 downto 0) = "100") then
				if (nextvcnt(2 downto 0) = "101") then
					REG1 <= MULT1OUT;
				end if;					
				-- others changes
				ADDER2START <= '0';
				ADDER3START <= '0';
				DONE <= '0';
				SYNCOUT <= '0';
				case nexticnt is
					when 0 =>
						ADDER2START <= '1';
						--ADDER2INB <= MULT1OUT;
					--when 3 =>
					when 4 =>
						REG2 <= ADDER3OUT;
					when 5 => 
						ADDER3START <= '1';
						--ADDER3INA <= REG2;
						--ADDER3INB <= ADDER1OUT;						
					--when 7 =>
					when 8 =>
						REG3 <= ADDER2OUT;
						SYNCOUT <= '1';
					--when 8 =>
					when 9 =>  
						REG2 <= MULT1OUT;
					when 12 =>
						ADDER3START <= '1';
						--ADDER3INA <= REG2;
						--ADDER3INB <= ADDER3OUT;
					when 13 =>
						ADDER2START <= '1';
						--ADDER2INB <= ADDER1OUT;
					--when 16 =>
					when 17 =>
						REG3 <= MULT1OUT;
					when 19 =>
						if (nodone = '1') then -- mask first done
							nodone <= '0';
						else
							DONE <= '1';
						end if;
						last2 <= last1;
						if (last2 = '1') then
							state <= S_IDLE;
						end if;
					when 20 =>	
						ADDER3START <= '1';
						--ADDER3INA <= REG3;
						--ADDER3INB <= ADDER2OUT;
					--when 21 =>
					when 22 =>
						REG2 <= ADDER1OUT;
					when others =>
						
				end case;
				-- 
				icnt <= nexticnt;
				--
				if (LAST='1') then
					last1 <= '1';
				end if;
			elsif (state = S_IDLE) then -- S_IDLE
				icnt <= 23;	
				DONE <= '0';
				last1 <= '0';
				last2 <= '0';
				nodone <= '1';
				if (SYNC = '1') then
					state <= S_CNT;
					icnt <= nexticnt;
					-- happened when icnt = 0
					ADDER2START <= '1';
					MULT1START <= '1';
					--
				end if;			
			end if;
		end if;
	end process POTO;

end rtl;

