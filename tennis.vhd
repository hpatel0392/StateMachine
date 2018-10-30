LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY tennis is
	PORT(clock, resetn, ivalid, iready: IN std_logic;
		  datain: IN std_logic_vector(7 downto 0);
		  oready, ovalid: OUT std_logic;
		  dataout: OUT std_logic_vector(7 downto 0));
END tennis;

ARCHITECTURE structure of tennis is
	--Define Component	
	component tennis_machine
		port ( player, clk, rst, ivalid : IN std_logic;
	          	score : OUT std_logic_vector(3 DOWNTO 0));
	end component; 

	BEGIN
	--Create instantiation.
	play : tennis_machine
	   port map (datain(0), clock, resetn, ivalid, dataout(3 DOWNTO 0));
	dataout(7 DOWNTO 4) <= "0000"; -- zero the rest

END structure;
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	
	
	
