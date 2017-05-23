library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity top is
port(
datain,clkin,fclk,rst_in: in std_logic;
seg0,seg1:out std_logic_vector(6 downto 0);
wkey:out std_logic
);
end top;

architecture behave of top is
component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
	foko : out std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output

	) ;
end component ;

component seg7 is
port(
code: in std_logic_vector(3 downto 0);
seg_out : out std_logic_vector(6 downto 0)
);
end component;

signal scancode : std_logic_vector(7 downto 0);
signal rst : std_logic;
signal clk_f: std_logic;
type state is (s0, s1);
signal q: state;
signal fok: std_logic;
begin
rst<=not rst_in;

u0: Keyboard port map(datain,clkin,fclk,rst,fok,scancode);
u1: seg7 port map(scancode(3 downto 0),seg0);
u2: seg7 port map(scancode(7 downto 4),seg1);

process(rst, fok)
begin
	if rst = '1' then
		q <= s0;
		wkey <= '0';
	elsif (fok'event and fok = '1') then
		if q = s0 then
			if scancode = "11110000" then
				q <= s1;
			elsif scancode = "00011101" then
				wkey <= '0';
			end if;
		else
			q <= s0;
			if scancode = "00011101" then
				wkey <= '1';
			end if;
		end if;
	end if;
end process;

--
-- 		if scancode = "11110000" then
-- 			q <= s1;
-- 		elsif scancode = "00011101" then
-- 			if q = s0 then
-- 				wkey <= '1';
-- 			else
-- 				wkey <= '0';
-- 			end if;
-- 			q <= s0;
-- 		else
-- 			q <= s0;
-- 		end if;
-- 	end if;
-- end process;

end behave;