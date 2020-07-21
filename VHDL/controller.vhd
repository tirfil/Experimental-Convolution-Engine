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

entity controller is
	port(
		MCLK		: in	std_logic;
		nRST		: in	std_logic;
		X			: in	std_logic_vector(7 downto 0);
		Y			: in	std_logic_vector(7 downto 0);
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
		KEN			: out	std_logic
	);
end controller;

architecture rtl of controller is
signal cnt : integer range 0 to 7;
type state_t is (S_IDLE,S_0,S_1,S_2,S_3,S_LINE,S_WAIT);
signal state : state_t;
signal xidx : integer range 0 to 255;
signal yidx : integer range 0 to 255;
signal tlast_q, tlast_qq : std_logic;
signal kad, next_kad : unsigned(3 downto 0);
signal ad0 : unsigned(13 downto 0);
signal ad1 : unsigned(13 downto 0);
signal ad2 : unsigned(13 downto 0);
signal suppress : std_logic;
signal timer : std_logic_vector(2 downto 0);
begin

	PCNT: process(MCLK, nRST)
	begin
		if (nRST = '0') then
			cnt <= 0;
		elsif (MCLK'event and MCLK = '1') then
			if cnt=7 then
				cnt <= 0;
			else 
				cnt <= cnt+1;
			end if;
		end if;
	end process PCNT;
	
	next_kad <= (others=>'0') when kad=8 else kad+1;
	
	POTO: process(MCLK,nRST)
	begin
		if (nRST = '0') then
			state <= S_IDLE;
			kad <= (others=>'0');
			xidx <= 0;
			tlast_q <= '0';
			tlast_qq <= '0';
			SYNC0 <= '0';
			SYNC1 <= '0';
			SYNC2 <= '0';
			LAST0 <= '0';
			LAST1 <= '0';
			LAST2 <= '0';		
			KEN <= '0';	
			KADDR <= (others=>'1');
			DADDR <= (others=>'1');
			ad0 <= (others=>'0');
			ad1 <= (others=>'0');
			ad2 <= (others=>'0');
			suppress <= '0';
		elsif (MCLK'event and MCLK = '1') then
			if state = S_IDLE then
				if (START = '1') then
					kad <= (others=>'0');
					xidx <= 0;
					yidx <= 0;
					ad0 <= (others=>'0');
					ad1 <= unsigned("000000" & X); -- X
					ad2 <= unsigned("00000" & X & "0"); -- 2*X
					KEN <= '0';
					state <= S_0;
				end if;
			elsif state = S_0 then
				if (cnt=7) then
					if (suppress = '0') then
						SYNC0 <= not(kad(1)); -- 0
						SYNC1 <= kad(0); -- 3
						SYNC2 <= kad(2); -- 6
					end if;
					DADDR <= std_logic_vector(ad0);
					KADDR <= std_logic_vector(kad);
					ad0 <= ad0+1;
					kad <= next_kad;
					xidx <= xidx + 1;
					if (xidx = to_integer(unsigned(X)-5)) then
						tlast_q <= '1';
						LAST0 <= not(kad(1));
						LAST1 <= kad(0);
						LAST2 <= kad(2);
					elsif (tlast_q = '1') then
						tlast_qq <= '1';
						tlast_q <= '0';
						LAST0 <= not(kad(1));
						LAST1 <= kad(0);
						LAST2 <= kad(2);
					elsif( tlast_qq = '1') then
						tlast_qq <= '0';
						suppress <= '1';
						LAST0 <= not(kad(1));
						LAST1 <= kad(0);
						LAST2 <= kad(2);
					end if;
					state <= S_1;
				end if;
				elsif state = S_1 then
				SYNC0 <= '0';
				SYNC1 <= '0';
				SYNC2 <= '0';
				LAST0 <= '0';
				LAST1 <= '0';
				LAST2 <= '0';	
				KEN <= '1';
				if (cnt=1) then
					KEN <= '0';
					KADDR <= std_logic_vector(kad);
					DADDR <= std_logic_vector(ad1);
					ad1 <= ad1+1;
					kad <= next_kad;
					state <= S_2;
				end if;
			elsif state = S_2 then
				KEN <= '1';
				if (cnt=3) then
					KEN <= '0';
					KADDR <= std_logic_vector(kad);
					DADDR <= std_logic_vector(ad2);
					ad2 <= ad2+1;
					kad <= next_kad;
					state <= S_3;
				end if;
			elsif state = S_3 then
				KEN <= '1';
				if (cnt=5) then
					KEN <= '0';
					if (xidx = to_integer(unsigned(X))) then
						state <= S_LINE;
					else
						state <= S_0;
					end if;
				end if;	
			elsif state = S_LINE then
				suppress <= '0';
				xidx <= 0;
				if ( yidx = to_integer(unsigned(Y)-3)) then
					state <= S_IDLE;
				else
					yidx <= yidx + 1;
					kad <= (others=>'0');
					state <= S_WAIT;
					timer <= "001";
				end if;
			elsif state = S_WAIT then
				if cnt=7 then
					if (timer(2) = '1') then
						state <= S_0;
					else
						timer(2 downto 1) <= timer(1 downto 0);
						timer(0) <= '0';
					end if;
				end if;
		    end if;
		end if;
	end process POTO;
	
	IDLE <= '1' when state = S_IDLE else '0';
end rtl;

