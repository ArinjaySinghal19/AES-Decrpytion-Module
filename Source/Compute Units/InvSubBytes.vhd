
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InvSubBytes is
    Port (
        clk      : in  STD_LOGIC;
        reset    : in  STD_LOGIC;
        ena      : in  STD_LOGIC;  -- Enable signal for reading from the ROM
        state_in : in  STD_LOGIC_VECTOR (7 downto 0);
        state_out : out STD_LOGIC_VECTOR (7 downto 0)
    );
end InvSubBytes;

architecture Behavioral of InvSubBytes is

    signal addr : STD_LOGIC_VECTOR(7 downto 0);
    signal state : STD_LOGIC_VECTOR(7 downto 0);  
    signal row : STD_LOGIC_VECTOR(3 downto 0);
    signal col : STD_LOGIC_VECTOR(3 downto 0);

    -- Use component of the s_box_rom instance
    component s_box_rom
        Port (
            clk      : in  std_logic;
            ena      : in  std_logic;
            addr     : in  std_logic_vector(7 downto 0);
            dout     : out std_logic_vector(7 downto 0)
        );
    end component;

begin
    
    -- Instance of s_box_rom
    ROM: s_box_rom
        port map (
            clk => clk,
            ena => ena,
            addr => addr,
            dout => state
        );

    process(clk, reset)
    begin
        if reset = '1' then
            state_out <= (others => '0');
        elsif rising_edge(clk) then
            row <= state_in(7 downto 4);  -- Upper 4 bits for row
            col <= state_in(3 downto 0);  -- Lower 4 bits for column
            addr <= row & col;
              -- Address calculation

            -- Output the corresponding state from the S-box ROM
            state_out <= state;
        end if;

    end process;

end Behavioral;