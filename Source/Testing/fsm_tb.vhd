library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main_fsm_tb is
end main_fsm_tb;

architecture Behavioral of main_fsm_tb is
    component main_fsm
        Port ( clk : in  STD_LOGIC;
               reset : in  STD_LOGIC;
               process_counter : out INTEGER;
               intermediate_counter : out INTEGER;
               step_counter : out INTEGER;
               round_counter : out INTEGER;
               done : out STD_LOGIC);
    end component;

    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal process_counter : INTEGER;
    signal intermediate_counter : INTEGER;
    signal step_counter : INTEGER;
    signal round_counter : INTEGER;
    signal done : STD_LOGIC;

    constant clk_period : time := 10 ns;

begin
    uut: main_fsm
        port map (
            clk => clk,
            reset => reset,
            process_counter => process_counter,
            intermediate_counter => intermediate_counter,
            step_counter => step_counter,
            round_counter => round_counter,
            done => done
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    test_process: process
    begin
        wait for 10 ns;
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        wait;
    end process;

end Behavioral;