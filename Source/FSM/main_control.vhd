LIBRARY IEEE;
LIBRARY WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;

ENTITY main_control IS
    PORT(
        clk: IN STD_LOGIC;
        reset: IN STD_LOGIC;
--        start: IN STD_LOGIC;
--        round_counter: OUT INTEGER;
--        process_counter: OUT INTEGER;
--        intermediate_counter: OUT INTEGER;
--        step_counter: OUT INTEGER;
--        byte_in : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--        byte_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
--        state_in : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--        state_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
--        bit_state : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
--        fsm_done: OUT STD_LOGIC
        -- output_row_1a: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         seg_Aa: OUT STD_LOGIC;
         seg_Ba: OUT STD_LOGIC;
         seg_Ca: OUT STD_LOGIC;
         seg_Da: OUT STD_LOGIC;
         seg_Ea: OUT STD_LOGIC;
         seg_Fa: OUT STD_LOGIC;
         seg_Ga: OUT STD_LOGIC;
         seg_Anodea: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
         fsmd: OUT STD_LOGIC;
         upd: OUT STD_LOGIC;
         segd: OUT STD_LOGIC 
    );

END main_control;

ARCHITECTURE behavior OF main_control IS

    component blk_mem_gen_0
        Port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            wea   : in  std_logic_vector(0 downto 0);
            addra : in  std_logic_vector(4 downto 0);
            dina  : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    component blk_mem_gen_1
        Port (
            clka  : in  std_logic;
            ena   : in  std_logic;
            wea   : in  std_logic_vector(0 downto 0);
            addra : in  std_logic_vector(7 downto 0);
            dina  : in  std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)
        );
    end component;

    -- component blk_mem_gen_2
    --     Port (
    --         clka  : in  std_logic;
    --         ena   : in  std_logic;
    --         wea   : in  std_logic_vector(0 downto 0);
    --         addra : in  std_logic_vector(3 downto 0);
    --         dina  : in  std_logic_vector(7 downto 0);
    --         douta : out std_logic_vector(7 downto 0)
    --     );
    -- end component;



    component Add_round_key is
        Port ( clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            state_in : in  STD_LOGIC_VECTOR (7 downto 0);
            round_key : in  STD_LOGIC_VECTOR (7 downto 0);
            state_out : out  STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;


    component InvMixColumns is
        Port ( clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            state : in  STD_LOGIC_VECTOR (31 downto 0);
            output : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;


    component InvShiftRows is
        Port ( clk : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            row_in : in  STD_LOGIC_VECTOR (31 downto 0);
            row_out : out  STD_LOGIC_VECTOR (31 downto 0);
            num_shift : in STD_LOGIC_VECTOR (1 downto 0));
    end component;


    component InvSubBytes is
        Port (
            clk      : in  STD_LOGIC;
            reset    : in  STD_LOGIC;
            ena      : in  STD_LOGIC;
            state_in : in  STD_LOGIC_VECTOR (7 downto 0);
            state_out : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;


    component SegDisplay is
        Port ( clk : in  STD_LOGIC;
            rst : in  STD_LOGIC;
            state : in  STD_LOGIC_VECTOR (31 downto 0);
            A,B,C,D,E,F,G : out std_logic;
            Anode : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component main_fsm is
        Port ( clk : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            process_counter : out INTEGER;
            intermediate_counter : out INTEGER;
            step_counter : out INTEGER;
            round_counter : out INTEGER;
            done : out STD_LOGIC);
    end component;


    signal ram_input : std_logic_vector(7 downto 0) := "00000000";
    signal ram_output : std_logic_vector(7 downto 0) := "00000000";
    signal ram_addr : std_logic_vector(4 downto 0) := "00000";
    signal ram_en : std_logic := '0';
    signal ram_we : std_logic_vector(0 downto 0) := "0";

    signal ark_rom_addr : std_logic_vector(7 downto 0) := "00000000";
    signal ark_rom_data : std_logic_vector(7 downto 0) := "00000000";
    signal ark_rom_en : std_logic := '0';
    signal ark_rom_we : std_logic_vector( 0 downto 0) := "0";
    signal ark_rom_din : std_logic_vector(7 downto 0) := "00000000";

    signal ark_state_in : std_logic_vector(7 downto 0) := "00000000";
    signal ark_state_out : std_logic_vector(7 downto 0) := "00000000";
    signal ark_round_key : std_logic_vector(7 downto 0) := "00000000";
    signal ark_reset : std_logic := '1';

    signal isb_state_in : std_logic_vector(7 downto 0) := "00000000";
    signal isb_state_out : std_logic_vector(7 downto 0) := "00000000";
    signal isb_ena : std_logic := '0';
    signal isb_reset : std_logic := '1';

    signal isr_row_in : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal isr_row_out : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
    signal isr_num_shift : std_logic_vector(1 downto 0):= "00";
    signal isr_reset : std_logic := '1';

    signal imc_state : std_logic_vector(31 downto 0) :=  "00000000000000000000000000000000";
    signal imc_output : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal imc_reset : std_logic := '1';

    signal seg_state : std_logic_vector(31 downto 0):= "00000000000000000000000000000000";
    signal seg_A : std_logic := '1';
    signal seg_B : std_logic := '1';
    signal seg_C : std_logic := '1';
    signal seg_D : std_logic := '1';
    signal seg_E : std_logic := '1';
    signal seg_F : std_logic := '1';
    signal seg_G : std_logic := '1';
    signal seg_Anode : std_logic_vector(3 downto 0) := "0000";
    signal seg_reset : std_logic := '1';
    signal segment_display_done : std_logic := '0';
    signal segment_display_counter : integer := 0;
    signal display_wait : std_logic_vector(27 downto 0) := "1111111111111111111111111111";

    signal state_temp_in : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal state_temp_out : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal byte_temp_in : std_logic_vector(7 downto 0) := "00000000";
    signal byte_temp_out : std_logic_vector(7 downto 0) := "00000000";
    signal ark_rom_temp_byte : std_logic_vector(7 downto 0) := "00000000";

    signal round_temp : integer := 0;
    signal process_temp : integer := 0;
    signal intermediate_temp : integer := 0;
    signal step_temp : integer := 0;
    signal fsm_done_temp : std_logic := '0';
    signal fsm_reset : std_logic := '1';

    signal row_output_1 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal row_output_2 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal row_output_3 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal row_output_4 : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

    signal whole_state : std_logic_vector(127 downto 0) := (others => '0');
    signal updated_state : std_logic_vector(127 downto 0) := (others => '0');
    signal update_byte_counter : integer := 0;
    signal update_delay : integer := 0;
    signal update_done : std_logic := '0';
    signal update_step : integer := 0;
    signal fsm_start : std_logic := '0';

    signal max_input_set : integer :=1;
    signal current_input_set : integer := 0;

    signal current_process : integer := 0;






BEGIN

    state_ram : blk_mem_gen_0
        PORT MAP (
            clka => clk,
            ena => ram_en,
            wea => ram_we,
            addra => ram_addr,
            dina => ram_input,
            douta => ram_output
        );

    ark_rom : blk_mem_gen_1
        PORT MAP (
            clka => clk,
            ena => ark_rom_en,
            wea => ark_rom_we,
            addra => ark_rom_addr,
            dina => ark_rom_din,
            douta => ark_rom_data
        );

    ark : Add_round_key
        PORT MAP (
            clk => clk,
            rst => ark_reset,
            state_in => ark_state_in,
            round_key => ark_round_key,
            state_out => ark_state_out
        );

    isb : InvSubBytes
        PORT MAP (
            clk => clk,
            reset => isb_reset,
            ena => isb_ena,
            state_in => isb_state_in,
            state_out => isb_state_out
        );

    isr : InvShiftRows
        PORT MAP (
            clk => clk,
            reset => isr_reset,
            row_in => isr_row_in,
            row_out => isr_row_out,
            num_shift => isr_num_shift
        );

    imc : InvMixColumns
        PORT MAP (
            clk => clk,
            rst => imc_reset,
            state => imc_state,
            output => imc_output
        );

    seg : SegDisplay
        PORT MAP (
            clk => clk,
            rst => seg_reset,
            state => seg_state,
            A => seg_A,
            B => seg_B,
            C => seg_C,
            D => seg_D,
            E => seg_E,
            F => seg_F,
            G => seg_G,
            Anode => seg_Anode
        );

    fsm : main_fsm
        PORT MAP (
            clk => clk,
            reset => fsm_reset,
            process_counter => process_temp,
            intermediate_counter => intermediate_temp,
            step_counter => step_temp,
            round_counter => round_temp,
            done => fsm_done_temp
        );


--    fsm_done <= fsm_done_temp;
--    output_row_1a <= row_output_1;
--    output_row_2a <= row_output_2;
--    output_row_3a <= row_output_3;
--    output_row_4a <= row_output_4;
    --segment_display_donea <= segment_display_done;
     seg_Aa <= seg_A;
     seg_Ba <= seg_B;
     seg_Ca <= seg_C;
     seg_Da <= seg_D;
     seg_Ea <= seg_E;
     seg_Fa <= seg_F;
     seg_Ga <= seg_G;
     seg_Anodea <= seg_Anode;
     fsmd <= fsm_done_temp;
     upd <= update_done;
     segd <= segment_display_done;
--    round_counter <= round_temp;
--    process_counter <= process_temp;
--    intermediate_counter <= intermediate_temp;
--    step_counter <= step_temp;
--    byte_in <= byte_temp_in;
--    byte_out <= byte_temp_out;
--    state_in <= state_temp_in;
--    state_out <= state_temp_out;
--    fsm_done <= fsm_done_temp;
--    bit_state <= whole_state;



    cycle_process : PROCESS (clk)
    BEGIN
        if (rising_edge(clk)) then
            if (reset = '1') then
                current_process <= 0;

            else
                case current_process is
                    when 0 =>
                        if (update_done = '1') then
                            current_process <= 1;
                        end if;

                    when 1 =>
                        if (fsm_done_temp = '1') then
                            current_process <= 2;
                        end if;

                    when 2 =>
                        if (segment_display_done = '1') then
                            current_process <= 0;
                        end if;

                    when others =>
                        null;

                end case;

            end if;

        end if;

    END PROCESS cycle_process;










    whole_state_update : PROCESS (clk)
    BEGIN
        if (rising_edge(clk)) then
            if (reset = '1') then
                updated_state <= (others => '0');
                update_byte_counter <= 0;
                update_delay <= 0;
                update_step <= 0;
                ram_addr <= "00000";
                ram_en <= '0';
                current_input_set <= 0;


                elsif (current_process = 0) then

                        if (update_delay < 10) then
                            update_delay <= update_delay + 1;
                        else
                            update_delay <= 0;

                            case update_step is
                                when 0 =>
                                    if (update_byte_counter < 16) then
                                        ram_addr <= std_logic_vector(to_unsigned(16*current_input_set + update_byte_counter, 5));
                                        ram_en <= '1';
                                        ram_we <= "0";
                                        update_step <= 1;
                                    end if;

                                when 1 =>
                                    if (update_byte_counter = 15) then
                                        updated_state((15-update_byte_counter)*8+7 downto (15-update_byte_counter)*8) <= ram_output;
                                        update_byte_counter <= 0;
                                        update_step <= 0;
                                        fsm_start <= '1';
                                        ram_addr <= "00000";
                                        ram_en <= '0';
                                        update_done <= '1';
                                        if (current_input_set < max_input_set-1) then
                                            current_input_set <= current_input_set + 1;
                                            
                                        else
                                            current_input_set <= 0;
                                        end if;
                                    else
                                        updated_state((15-update_byte_counter)*8+7 downto (15-update_byte_counter)*8) <= ram_output;
                                        update_byte_counter <= update_byte_counter + 1;
                                        update_step <= 0;

                                    end if;

                                when others =>
                                    null;

                            end case;

                        end if;

                else
                    update_byte_counter <= 0;
                    update_delay <= 0;
                    update_done <= '0';
                    update_step <= 0;
                    ram_addr <= std_logic_vector(to_unsigned(16*current_input_set, 5));
                end if;

            end if;

    END PROCESS whole_state_update;








    main_control_process : PROCESS (clk)
    BEGIN
        if (rising_edge(clk)) then
            if reset = '1' then
--                fsm_done <= '0';
                ark_rom_en <= '0';
                ark_reset <= '1';
                isb_reset <= '1';
                isr_reset <= '1';
                imc_reset <= '1';
                fsm_reset <= '1';
            elsif (current_process = 1) then
                if (fsm_done_temp = '1') then
--                    fsm_done <= '1';
                    ark_rom_en <= '0';
                    ark_reset <= '1';
                    isb_reset <= '1';
                    isr_reset <= '1';
                    imc_reset <= '1';
                    fsm_reset <= '1';
               else
               fsm_reset <= '0';

                    case process_temp is
                        when 0 =>
                            case step_temp is
                                when 0 =>
                                    if (round_temp = 0 and intermediate_temp = 0 ) then
                                        byte_temp_in <= updated_state((15-intermediate_temp)*8+7 downto (15-intermediate_temp)*8);
                                        whole_state <= updated_state;
                                    else
                                        byte_temp_in <= whole_state((15-intermediate_temp)*8+7 downto (15-intermediate_temp)*8);
                                    end if;

                                when 1 =>
                                    ark_rom_addr <= std_logic_vector(to_unsigned((9-round_temp)*16+intermediate_temp, 8));
                                    ark_rom_en <= '1';
                                    ark_rom_temp_byte <= ark_rom_data;

                                when 2 =>
                                    ark_round_key <= ark_rom_temp_byte;
                                    ark_reset <= '0';
                                    ark_state_in <= byte_temp_in;
                                    ark_rom_en <= '0';
                                    byte_temp_out <= ark_state_out;

                                when 3 =>
                                    ark_reset <= '1';
                                    whole_state((15-intermediate_temp)*8+7 downto (15-intermediate_temp)*8) <= byte_temp_out;
                                    if (round_temp = 9) then
                                    
                                        if (intermediate_temp < 4) then
                                            row_output_1(8*(3 - (intermediate_temp))+7 downto 8*(3 - (intermediate_temp))) <= byte_temp_out;
                                        elsif (intermediate_temp < 8) then
                                            row_output_2(8*(3 - ((intermediate_temp-4)))+7 downto 8*(3 - ((intermediate_temp - 4)))) <= byte_temp_out;
                                        elsif (intermediate_temp < 12) then
                                            row_output_3(8*(3 - ((intermediate_temp - 8)))+7 downto 8*(3 - ((intermediate_temp - 8)))) <= byte_temp_out;
                                        elsif (intermediate_temp <16) then
                                            row_output_4(8*(3 - ((intermediate_temp - 12)))+7 downto 8*(3 - ((intermediate_temp - 12)))) <= byte_temp_out;
                                        end if;
                                    end if;

                                when others =>
                                    null;
                            end case;

                        when 1 =>
                            if (step_temp < 4) then
                                state_temp_in(8*step_temp+7 downto 8*step_temp) <= whole_state((15-(4*intermediate_temp + step_temp))*8+7 downto (15-(4*intermediate_temp + step_temp))*8);
                            elsif (step_temp = 4) then
                                imc_state <= state_temp_in;
                                imc_reset <= '0';
                                state_temp_out <= imc_output;
                            elsif (step_temp > 4) then
                                imc_reset <= '1';
                                whole_state((15-(4*intermediate_temp + step_temp-5))*8+7 downto (15-(4*intermediate_temp + step_temp-5))*8) <= state_temp_out(8*(step_temp-5)+7 downto 8*(step_temp-5));
                            end if;

                        when 2 =>
                            if (step_temp < 4) then
                                state_temp_in(8*(3-step_temp)+7 downto 8*(3-step_temp)) <= whole_state((15-(intermediate_temp + 4*step_temp))*8+7 downto (15-(intermediate_temp + 4*step_temp))*8);
                            elsif (step_temp = 4) then
                                isr_row_in <= state_temp_in;
                                isr_num_shift <= std_logic_vector(to_unsigned(intermediate_temp, 2));
                                isr_reset <= '0';
                                state_temp_out <= isr_row_out;
                            elsif (step_temp > 4) then
                                isr_reset <= '1';
                                whole_state((15-(intermediate_temp + 4*(step_temp-5)))*8+7 downto (15-(intermediate_temp + 4*(step_temp-5)))*8) <= state_temp_out(8*(3-(step_temp-5))+7 downto 8*(3-(step_temp-5)));
                            end if;

                        when 3 =>
                            case step_temp is
                                when 0 =>
                                    byte_temp_in <= whole_state((15-intermediate_temp)*8+7 downto (15-intermediate_temp)*8);
                                when 1 =>
                                    isb_state_in <= byte_temp_in;
                                    isb_ena <= '1';
                                    isb_reset <= '0';
                                    byte_temp_out <= isb_state_out;
                                when 2 =>
                                    isb_reset <= '1';
                                    whole_state((15-intermediate_temp)*8+7 downto (15-intermediate_temp)*8) <= byte_temp_out;
                                when others =>
                                    null;
                            end case;

                        when others =>
                            null;
                    end case;
                end if;
            else 
            fsm_reset <= '1';
            end if;
        end if;
    END PROCESS main_control_process;










segment_display_process : PROCESS (clk)
BEGIN
    if (rising_edge(clk)) then
        if reset = '1' then
            -- Initialize all segment-related signals
            segment_display_done <= '0';
            segment_display_counter <= 0;
--            display_wait <= "0000000000000000000111111111";
            display_wait <= "1111111111111111111111111111";
            seg_reset <= '1';
            seg_state <= (others => '0');

        elsif (current_process = 2) then

            if (segment_display_done = '0') then

                if (display_wait /= "1111111111111111111111111111") then
                    display_wait <= std_logic_vector(unsigned(display_wait) + 1);
                    seg_reset <= '0';
                else
                    display_wait <= "0000000000000000000000000000";

                    case segment_display_counter is
                        when 0 =>
                            seg_state <= row_output_1;
                            segment_display_counter <= 1;
                            seg_reset <= '0';
                        when 1 =>
                            seg_state <= row_output_2;
                            segment_display_counter <= 2;
                            seg_reset <= '0';
                        when 2 =>
                            seg_state <= row_output_3;
                            segment_display_counter <= 3;
                            seg_reset <= '0';
                        when 3 =>
                            seg_state <= row_output_4;
                            segment_display_counter <= 4;
                            seg_reset <= '0';
                        when 4 =>
                            segment_display_done <= '1';
                            segment_display_counter <= 0;

                        when others =>
                            null;

                    end case;

                end if;

            end if;
        else 
        segment_display_done <= '0';
        end if;

    end if;

END PROCESS segment_display_process;
END behavior;