LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY main_control_tb IS
END main_control_tb;

ARCHITECTURE behavior OF main_control_tb IS

    -- Component Declaration
    COMPONENT main_control IS
        PORT(
            clk: IN STD_LOGIC;
            reset: IN STD_LOGIC;
--            start: IN STD_LOGIC;
--            fsm_done: OUT STD_LOGIC;
--            output_row_1a: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--            output_row_2a: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--            output_row_3a: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--            output_row_4a: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--            segment_display_donea: OUT STD_LOGIC;
            seg_Aa: OUT STD_LOGIC;
            seg_Ba: OUT STD_LOGIC;
            seg_Ca: OUT STD_LOGIC;
            seg_Da: OUT STD_LOGIC;
            seg_Ea: OUT STD_LOGIC;
            seg_Fa: OUT STD_LOGIC;
            seg_Ga: OUT STD_LOGIC;
            seg_Anodea: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    -- Input Signals
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
--    signal start : std_logic := '0';

    -- Output Signals
--    signal fsm_done : std_logic;
--    signal output_row_1a : std_logic_vector(31 downto 0);
--    signal output_row_2a : std_logic_vector(31 downto 0);
--    signal output_row_3a : std_logic_vector(31 downto 0);
--    signal output_row_4a : std_logic_vector(31 downto 0);
--    signal segment_display_donea : std_logic;
    signal seg_Aa : std_logic;
    signal seg_Ba : std_logic;
    signal seg_Ca : std_logic;
    signal seg_Da : std_logic;
    signal seg_Ea : std_logic;
    signal seg_Fa : std_logic;
    signal seg_Ga : std_logic;
    signal seg_Anodea : std_logic_vector(3 downto 0);

    -- Clock period definition
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: main_control PORT MAP (
        clk => clk,
        reset => reset,
--        start => start,
--        fsm_done => fsm_done,
--        output_row_1a => output_row_1a,
--        output_row_2a => output_row_2a,
--        output_row_3a => output_row_3a,
--        output_row_4a => output_row_4a,
--        segment_display_donea => segment_display_donea,
        seg_Aa => seg_Aa,
        seg_Ba => seg_Ba,
        seg_Ca => seg_Ca,
        seg_Da => seg_Da,
        seg_Ea => seg_Ea,
        seg_Fa => seg_Fa,
        seg_Ga => seg_Ga,
        seg_Anodea => seg_Anodea
    );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset state for 100 ns
--        wait for 100 ns;

        -- Release reset
        reset <= '0';
--        wait for clk_period*10;

        -- Start the processing
--        start <= '1';

        -- Wait for FSM to complete
--        wait until fsm_done = '1';
--        wait for clk_period*10;

--        -- Check segment display
--        wait until segment_display_donea = '1';

        -- Additional test scenarios can be added here

        -- End simulation
        wait;
    end process;

END behavior;