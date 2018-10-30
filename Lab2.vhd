LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity tennis_machine is port(
	player, clk, rst : IN std_logic;
	score : OUT std_logic_vector(3 DOWNTO 0));
end entity;

architecture state_machine of tennis_machine is
	type fsm_state is (L_L, F_L, L_F, T_L, L_T,
							 F_F, T_F, F_T, T_T, A_T, 
							 T_A, W1, W2);
	attribute syn_encoding : string;
	attribute syn_encoding of fsm_state : type is "sequential";  -- enumerate states in binary starting at 0000
	signal y_present, y_next : fsm_state := L_L;
begin
	
	process(player, y_present)
	begin
		case y_present is
			when L_L =>       -- love - love
				if player ='0' then
					y_next <= F_L;
				else
					y_next <= L_F;
				end if;
			when F_L =>       -- 15 - love
				if player ='0' then
					y_next <= T_L;
				else
					y_next <= F_F;
				end if;
			when L_F =>       -- love - 15
				if player ='0' then
					y_next <= F_F;
				else
					y_next <= L_T;
				end if;
			when T_L =>       -- 30 - love
				if player ='0' then
					y_next <= W1;
				else
					y_next <= T_F;
				end if;
			when L_T =>       -- love - 30
				if player ='0' then
					y_next <= F_T;
				else
					y_next <= W2;
				end if;
			when F_F =>       -- 15 - 15
				if player ='0' then
					y_next <= T_F;
				else
					y_next <= F_T;
				end if;
			when T_F =>       -- 30 - 15
				if player ='0' then
					y_next <= W1;
				else
					y_next <= T_T;
				end if;
			when F_T =>       -- 15 - 30
				if player ='0' then
					y_next <= T_T;
				else
					y_next <= W2;
				end if;
			when T_T =>       -- 30 - 30
				if player ='0' then
					y_next <= A_T;
				else
					y_next <= T_A;
				end if;
			when A_T =>       -- adv - 30
				if player ='0' then
					y_next <= W1;
				else
					y_next <= T_T;
				end if;
			when T_A =>       -- 30 - adv
				if player ='0' then
					y_next <= T_T;
				else
					y_next <= W2;
				end if;
			when W1 =>       -- Game player 1
				if player ='0' then
					y_next <= L_L;
				else
					y_next <= L_L;
				end if;
			when W2 =>       -- game player 2
				if player ='0' then
					y_next <= L_L;
				else
					y_next <= L_L;
				end if;
		end case;
	end process;
	
	process(clk, rst)
	begin
		if rst = '0' then
			y_present <= L_L;
		elsif rising_edge(clk) then
			y_present <= y_next;
		end if;
	end process;
	
	score <= std_logic_vector(to_unsigned(fsm_state'pos(y_present), score'length));
end state_machine;



LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity Lab2 is port(
	SW : IN std_logic_vector(0 DOWNTO 0);
	KEY : IN std_logic_vector(1 DOWNTO 0);
	LEDR : OUT std_logic_vector(3 DOWNTO 0);
	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT std_logic_vector(0 TO 6));
end entity;

architecture structure of Lab2 is 
	component tennis_machine
		port ( player, clk, rst : IN std_logic;
	          score : OUT std_logic_vector(3 DOWNTO 0));
	end component;
	signal state_out : std_logic_vector(3 DOWNTO 0);
	
begin
	tennis_state : tennis_machine
		port map(SW(0), KEY(0), KEY(1), state_out);
	
	player1 : process(state_out)
	begin
		
		case state_out is  -- digit 1 of player 1 score
			when	"0001" | "0101" | "0111"           => HEX5 <= "1001111"; -- F_L, F_F, F_T      (1)
			when	"0011" | "0110" | "1000" | "1010"  => HEX5 <= "0000110"; -- T_L, T_F, T_T, T_A (3)
			when	"1001"                             => HEX5 <= "0001000"; -- A_T                (A)
			when	"1011" | "1100"                    => HEX5 <= "0011000"; -- W1, W2             (P)
			when 	others                             => HEX5 <= "0000001"; -- L_L, L_F, L_T      (0)
		end case;	
		
		-- States are L_L, F_L, L_F, T_L, L_T,
		--            F_F, T_F, F_T, T_T, A_T, 
		--            T_A, W1, W2
	
		case state_out is  -- digit 0 of player 1 score
			when	"0001" | "0101" | "0111"           => HEX4 <= "0100100"; -- F_L, F_F, F_T       (5)
			when	"1001"                             => HEX4 <= "1000010"; -- A_T                 (d)
			when	"1011" | "1100"                    => HEX4 <= "1110001"; -- W1, W2              (L)
			when  others                             => HEX4 <= "0000001"; -- L_L, L_F, L_T, T_L  (0)
			                                                               -- T_F, T_T, T_A
		end case;	
		
		case state_out is  -- middle digit 1 
			when	"1011" | "1100"                    => HEX3 <= "0001000"; -- W1, W2      (A)
			when  others                             => HEX3 <= "1111110"; -- the rest    (-)
		end case;
		
		case state_out is  -- middle digit 0 
			when	"1011" | "1100"                    => HEX2 <= "1000100"; -- W1, W2      (y)
			when  others                             => HEX2 <= "1111110"; -- the rest    (-)
		end case;
		
		case state_out is  -- digit 1 of player 2 score
			when	"0010" | "0101" | "0110"           => HEX1 <= "1001111"; -- L_F, F_F, T_F,         (1)
			when	"0100" | "0111" | "1000" | "1001"  => HEX1 <= "0000110"; -- L_T, F_T, T_T, A_T     (3)
			when	"1010"                             => HEX1 <= "0001000"; -- T_A                    (A)
			when	"1011" | "1100"                    => HEX1 <= "1111111"; -- W1, W2                 ( )
			when 	others                             => HEX1 <= "0000001"; -- L_L, F_L, T_L          (0)
		end case;
		
		-- States are L_L, F_L, L_F, T_L, L_T,
		--            F_F, T_F, F_T, T_T, A_T, 
		--            T_A, W1, W2
		
		case state_out is  -- digit 0 of player 2 score
			when	"0010" | "0101" | "0110"           => HEX0 <= "0100100"; -- L_F, F_F, T_F       (5)
			when	"1010"                             => HEX0 <= "1000010"; -- T_A                 (d)
			when	"1011"                             => HEX0 <= "1001111"; -- W1                  (1)
			when  "1100"                             => HEX0 <= "0010010"; -- W2                  (2)
			when  others                             => HEX0 <= "0000001"; -- L_L, F_L, T_L, L_T  (0)
			                                                               -- F_T, T_T, A_T
		end case;
		
	end process;
	
	LEDR <= state_out;
end architecture;