library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity main_fsm is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           process_counter : out INTEGER;
           intermediate_counter : out INTEGER;
           step_counter : out INTEGER;
           round_counter : out INTEGER;
           done : out STD_LOGIC);
end main_fsm;

architecture Behavioral of main_fsm is
    signal process_temp : integer := 0;
    signal intermediate_temp : integer := 0;
    signal step_temp : integer := 0;
    signal round_temp : integer := 0;
    signal delay : integer := 0;
    signal done_temp : STD_LOGIC := '0';

begin
    process_counter <= process_temp;
    intermediate_counter <= intermediate_temp;
    step_counter <= step_temp;
    round_counter <= round_temp;
    done <= done_temp;

    fsm_proc : process (clk)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                process_temp <= 0;
                intermediate_temp <= 0;
                step_temp <= 0;
                round_temp <= 0;
                done_temp <= '0';
            else
                if (done_temp = '1') then
                    process_temp <= 0;
                    intermediate_temp <= 0;
                    step_temp <= 0;
                    round_temp <= 0;
                else
                    if (delay < 10) then
                        delay <= delay + 1;
                    else
                        delay <= 0;

                        

                        case round_temp is

                            when 0 =>

                                case process_temp is

                                    when 0 =>

                                    if (step_temp = 3) then
                                        if (intermediate_temp = 15) then
                                                process_temp <= 2;
                                                intermediate_temp <= 0;
                                                step_temp <= 0;
                                        else
                                            intermediate_temp <= intermediate_temp + 1;
                                            step_temp <= 0;
                                        end if;
                                    else
                                        step_temp <= step_temp + 1;
                                    end if;

                                    when 2 =>
                                    if (step_temp = 8) then
                                        if (intermediate_temp = 3) then
                                                process_temp <= 3;
                                                intermediate_temp <= 0;
                                                step_temp <= 0;
                                        else
                                            intermediate_temp <= intermediate_temp + 1;
                                            step_temp <= 0;
                                        end if;
                                    else
                                        step_temp <= step_temp + 1;
                                    end if;



                                    when 3 =>
                                    if (step_temp = 2) then
                                        if (intermediate_temp = 15) then
                                                round_temp <= round_temp + 1;
                                                process_temp <= 0;
                                                intermediate_temp <= 0;
                                                step_temp <= 0;
                                        else
                                            intermediate_temp <= intermediate_temp + 1;
                                            step_temp <= 0;
                                        end if;
                                    else
                                        step_temp <= step_temp + 1;
                                    end if;

                                    when others =>
                                     null;

                                end case;

                            when 9 =>
                                if (step_temp = 3) then
                                    if (intermediate_temp = 15) then
                                            done_temp <= '1';
                                            process_temp <= 0;
                                            intermediate_temp <= 0;
                                            step_temp <= 0;
                                    else
                                        intermediate_temp <= intermediate_temp + 1;
                                        step_temp <= 0;
                                    end if;
                                else
                                    step_temp <= step_temp + 1;
                                end if;


                            when others =>

                                case process_temp is

                                        when 0 =>
                                        if (step_temp = 3) then
                                            if (intermediate_temp = 15) then
                                                    process_temp <= 1;
                                                    intermediate_temp <= 0;
                                                    step_temp <= 0;
                                            else
                                                intermediate_temp <= intermediate_temp + 1;
                                                step_temp <= 0;
                                            end if;
                                        else
                                            step_temp <= step_temp + 1;
                                        end if;

                                        when 1 =>
                                        if (step_temp = 8) then
                                            if (intermediate_temp = 3) then
                                                    process_temp <= 2;
                                                    intermediate_temp <= 0;
                                                    step_temp <= 0;
                                            else
                                                intermediate_temp <= intermediate_temp + 1;
                                                step_temp <= 0;
                                            end if;
                                        else
                                            step_temp <= step_temp + 1;
                                        end if;

                                        when 2 =>
                                        if (step_temp = 8) then
                                            if (intermediate_temp = 3) then
                                                    process_temp <= 3;
                                                    intermediate_temp <= 0;
                                                    step_temp <= 0;
                                            else
                                                intermediate_temp <= intermediate_temp + 1;
                                                step_temp <= 0;
                                            end if;
                                        else
                                            step_temp <= step_temp + 1;
                                        end if;

                                        when 3 =>
                                        if (step_temp = 2) then
                                            if (intermediate_temp = 15) then
                                                    round_temp <= round_temp + 1;
                                                    process_temp <= 0;
                                                    intermediate_temp <= 0;
                                                    step_temp <= 0;
                                            else
                                                intermediate_temp <= intermediate_temp + 1;
                                                step_temp <= 0;
                                            end if;
                                        else
                                            step_temp <= step_temp + 1;
                                        end if;

                                        when others =>
                                        null;


                                end case;

                        end case;

                    end if;

                end if;

            end if;

        end if;

    end process;

end Behavioral;
