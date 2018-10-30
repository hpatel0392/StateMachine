LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.ALL;

entity testbench is
end entity;

architecture tennisTest of testbench is
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	
	signal player : std_logic := '0';
	signal score : std_logic_vector(3 DOWNTO 0);
begin
	dut : entity tennis_machine
		port map(player => player, clk => clk, rst => rst, score => score);
		
	-- clock
	process
	begin
		clk <= not(clk);
		wait for 5 ns;
	end process;
	
	-- test cases
	process
	begin
	   wait until(falling_edge(clk)); -- sync signals
		player <= '0'; wait for 30 ns; -- player 1 sweeps
		player <= '1'; wait for 30 ns; -- player 2 sweeps
		rst <= '0'; wait for 10 ns; rst <= '1'; -- check reset mid game
		player <= '0'; wait for 10 ns;
		player <= '1'; wait for 10 ns;
		player <= '0'; wait for 10 ns;
		player <= '1'; wait for 10 ns; -- Deuce
		player <= '0'; wait for 10 ns; -- adv 1
		player <= '1'; wait for 30 ns; -- back to deuce, adv 2, then win 2
		rst <= '0'; wait for 10 ns; rst <= '1'; -- check reset mid game
		player <= '0'; wait for 10 ns;
		player <= '1'; wait for 10 ns;
		player <= '0'; wait for 10 ns;
		wait;
	end process;
end architecture;