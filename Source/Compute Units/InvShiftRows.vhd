library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InvShiftRows is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           row_in : in  STD_LOGIC_VECTOR (31 downto 0); -- single 8-bit row
           row_out : out  STD_LOGIC_VECTOR (31 downto 0);
           num_shift : in STD_LOGIC_VECTOR (1 downto 0)); -- 2-bit signal for shifts (0 to 3)
end InvShiftRows;

architecture Behavioral of InvShiftRows is

    signal temp_row : STD_LOGIC_VECTOR(31 downto 0);

begin

    process(clk, reset)
    begin
        if reset = '1' then
            temp_row <= (others => '0');
        elsif rising_edge(clk) then
            -- Shift the row cyclically to the right based on num_shift
            case num_shift is
                when "00" =>  -- No shift
                    temp_row <= row_in;
                when "01" =>  -- Shift by 1
                    temp_row <= row_in(7 downto 0) & row_in(31 downto 8);
                when "10" =>  -- Shift by 2
                    temp_row <= row_in(15 downto 0) & row_in(31 downto 16);
                when "11" =>  -- Shift by 3
                    temp_row <= row_in(23 downto 0) & row_in(31 downto 24);
                when others =>
                    temp_row <= (others => '0');  -- Default case (shouldn't happen)
            end case;
        end if;
    end process;

    -- Output the shifted row
    row_out <= temp_row;

end Behavioral;