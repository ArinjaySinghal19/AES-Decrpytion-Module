--  The state is combined with the round key using a bitwise XOR operation.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Add_round_key is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           state_in : in  STD_LOGIC_VECTOR (7 downto 0);
           round_key : in  STD_LOGIC_VECTOR (7 downto 0);
           state_out : out  STD_LOGIC_VECTOR (7 downto 0));
end Add_round_key;

architecture Behavioral of Add_round_key is

begin

    process(clk, rst)
    begin
        if rst = '1' then
            state_out <= (others => '0');
        elsif rising_edge(clk) then
            state_out <= state_in xor round_key;
        end if;
    end process;

end Behavioral;


