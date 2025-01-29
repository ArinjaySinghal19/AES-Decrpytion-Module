-- In the InvMixColumns step, each column in the state matrix is transformed by multiplying each byte
-- by a set of fixed constants: 0x0e, 0x0b, 0x0d, and 0x09, all in the Galois Field

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InvMixColumns is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           state : in  STD_LOGIC_VECTOR (31 downto 0);
           output : out  STD_LOGIC_VECTOR (31 downto 0));
end InvMixColumns;


architecture Behavioral of InvMixColumns is

    signal value_1 : STD_LOGIC_VECTOR(7 downto 0);
    signal value_2 : STD_LOGIC_VECTOR(7 downto 0);
    signal value_3 : STD_LOGIC_VECTOR(7 downto 0);
    signal value_4 : STD_LOGIC_VECTOR(7 downto 0);

    signal output_value_1 : STD_LOGIC_VECTOR(7 downto 0);
    signal output_value_2 : STD_LOGIC_VECTOR(7 downto 0);
    signal output_value_3 : STD_LOGIC_VECTOR(7 downto 0);
    signal output_value_4 : STD_LOGIC_VECTOR(7 downto 0);
    signal output_temp : STD_LOGIC_VECTOR(31 downto 0);

--    function shift_left(a : STD_LOGIC_VECTOR(7 downto 0); n : integer) return STD_LOGIC_VECTOR is
--        variable temp : STD_LOGIC_VECTOR(7 downto 0);
--    begin
--        for i in 0 to 7 loop
--            temp(i) := a((i+n) mod 8);
--        end loop;
--        return temp;
--    end function;

    function xtimes_02(a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        if a(7) = '1' then
            temp := a(6 downto 0) & '0';
            temp := temp xor "00011011";
        else
            temp := a(6 downto 0) & '0';
        end if;
        return temp;
    end function;

    function xtimes_04 (a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        temp := xtimes_02(xtimes_02(a));
        return temp;
    end function;

    function xtimes_08 (a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        temp := xtimes_02(xtimes_04(a));
        return temp;
    end function;


    function xtimes_09 (a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        temp := xtimes_08(a);
        temp := temp xor a;
        return temp;
    end function;

    function xtimes_0b (a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        temp := xtimes_08(a) xor xtimes_02(a) xor a;
        return temp;
    end function;

    function xtimes_0d (a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        temp := xtimes_08(a) xor xtimes_04(a) xor a;
        return temp;
    end function;

    function xtimes_0e (a : STD_LOGIC_VECTOR(7 downto 0)) return STD_LOGIC_VECTOR is
        variable temp : STD_LOGIC_VECTOR(7 downto 0);
    begin
        temp := xtimes_08(a) xor xtimes_04(a) xor xtimes_02(a);
        return temp;
    end function;

begin
    process(clk, rst)
    begin
        if rst = '1' then
            output_temp <= (others => '0');

        elsif rising_edge(clk) then
            value_1 <= state(7 downto 0);
            value_2 <= state(15 downto 8);
            value_3 <= state(23 downto 16);
            value_4 <= state(31 downto 24);

            output_value_4 <= xtimes_0e(value_1) xor xtimes_0b(value_2) xor xtimes_0d(value_3) xor xtimes_09(value_4);
            output_value_3 <= xtimes_09(value_1) xor xtimes_0e(value_2) xor xtimes_0b(value_3) xor xtimes_0d(value_4);
            output_value_2 <= xtimes_0d(value_1) xor xtimes_09(value_2) xor xtimes_0e(value_3) xor xtimes_0b(value_4);
            output_value_1 <= xtimes_0b(value_1) xor xtimes_0d(value_2) xor xtimes_09(value_3) xor xtimes_0e(value_4);

            output_temp <= output_value_1 & output_value_2 & output_value_3 & output_value_4;

        end if;

    end process;

    output <= output_temp;

end Behavioral;