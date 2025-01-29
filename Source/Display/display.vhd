
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SegDisplay is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           state : in  STD_LOGIC_VECTOR (31 downto 0);
--           Cathode : out  STD_LOGIC_VECTOR (6 downto 0);
            A,B,C,D,E,F,G : out std_logic;
           Anode : out STD_LOGIC_VECTOR (3 downto 0));
end SegDisplay;

architecture Behavioral of SegDisplay is
    signal counter : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal clk_counter : INTEGER := 0;
    signal cathode : STD_LOGIC_VECTOR (6 downto 0) := "0000000";

    -- Function to map hex to 7-segment codes
    function hex_to_7seg(hex : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable segments : STD_LOGIC_VECTOR(6 downto 0);
    begin
        case hex is
            when X"30" => segments := "0000001"; -- 0
            when X"31" => segments := "1001111"; -- 1
            when X"32" => segments := "0010010"; -- 2
            when X"33" => segments := "0000110"; -- 3
            when X"34" => segments := "1001100"; -- 4
            when X"35" => segments := "0100100"; -- 5
            when X"36" => segments := "0100000"; -- 6
            when X"37" => segments := "0001111"; -- 7
            when X"38" => segments := "0000000"; -- 8
            when X"39" => segments := "0000100"; -- 9
            when X"41" | X"61" => segments := "0001000"; -- A
            when X"42" | X"62" => segments := "1100000"; -- B
            when X"43" | X"63" => segments := "0110001"; -- C
            when X"44" | X"64" => segments := "1000010"; -- D
            when X"45" | X"65" => segments := "0110000"; -- E
            when X"46" | X"66" => segments := "0111000"; -- F
            when others => segments := "1111110"; -- Dash
        end case;
        return segments;
    end function;

begin

    -- Single process to handle counter, clk_counter, and display updates
    process(clk, rst)
    begin
        if rst = '1' then
            A <= '0';
            B <= '0';
            C <= '0';
            D <= '0';
            E <= '0';
            F <='0';
            G <= '0';
            
            Anode <= "1111"; -- all off
--            clk_counter <= 0;
--            counter <= "00";
        elsif rising_edge(clk) then
            -- Clock divider to update display every 100 clock cycles
            if clk_counter = 50000 then
                clk_counter <= 0;
                
                -- Update counter to select the next digit
                if counter = "11" then
                    counter <= "00";
                else
                    counter <= counter + 1;
                end if;
            else
                clk_counter <= clk_counter + 1;
            end if;
            
            -- Select which digit to display based on counter
            case counter is
                when "00" =>
                    Anode <= "0111";
                    Cathode <= hex_to_7seg(state(31 downto 24));
                when "01" =>
                    Anode <= "1011";
                    Cathode <= hex_to_7seg(state(23 downto 16));
                when "10" =>
                    Anode <= "1101";
                    Cathode <= hex_to_7seg(state(15 downto 8));
                when "11" =>
                    Anode <= "1110";
                    Cathode <= hex_to_7seg(state(7 downto 0));
                when others =>
                    Cathode <= "0000000";
                    Anode <= "1111"; -- all off
            end case;
            
            A <= cathode(6);
            B <= cathode(5);
            C <= cathode(4);
            D <= cathode(3);
            E <= cathode(2);
            F <= cathode(1);
            G <= cathode(0);
        end if;
    end process;

end Behavioral;