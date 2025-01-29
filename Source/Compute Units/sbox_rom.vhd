library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity s_box_rom is
    Port ( clk      : in  std_logic;
           ena      : in  std_logic;  -- enable signal that basically enables memory for read/write
            
           addr     : in  std_logic_vector(7 downto 0); -- Address for accessing BRAM
    
           dout     : out std_logic_vector(7 downto 0)  -- Data read from BRAM
         );
end s_box_rom;

architecture Behavioral of s_box_rom is

   
    component blk_mem_gen_2
        Port (
            clka  : in  std_logic;                 
            ena   : in  std_logic;                     
            wea : in std_logic;
            addra : in  std_logic_vector(7 downto 0);  
           dina :  in std_logic_vector(7 downto 0);
            douta : out std_logic_vector(7 downto 0)   
        );
    end component;

begin

    
    bram_inst : blk_mem_gen_2
        port map (
            clka  => clk,               
            ena   => ena,                
            wea => '0',
            addra => addr,              
             dina => "00000000",      
            douta => dout               
        );

end Behavioral;