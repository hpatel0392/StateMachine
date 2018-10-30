library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity tennis_machine is
	port(player,clk,rst,ivalid	: in std_logic;
	     score			: out std_logic_vector(3 downto 0));
end tennis_machine;


architecture state_machine of tennis_machine is

	--Put your code for your state machine here!
	--Make the changes described in the project description.
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
		elsif (rising_edge(clk) and ivalid='1') then
			y_present <= y_next;
		end if;
	end process;
	
	score <= std_logic_vector(to_unsigned(fsm_state'pos(y_present), score'length));

end state_machine;					
