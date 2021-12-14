

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fAdder_16 is
  Port (
  iData1    :   in  std_logic_vector(15 downto 0);
  iData2    :   in  std_logic_vector(15 downto 0);
  iCarry    :   in  std_logic;  
  oCarry    :   out  std_logic;    
  oData     :   out std_logic_vector(15 downto 0)
   );
end fAdder_16;

architecture Behavioral of fAdder_16 is

component fAdder is
  Port ( 
    A       :   in  std_logic;
    B       :   in  std_logic;
    Cin     :   in  std_logic;
    S       :   out std_logic;
    Cout    :   out std_logic
  );
end component;

SIGNAL  sSUM    :   std_logic_vector(15 downto 0);
SIGNAL  sCarry  :   std_logic_vector(14 downto 0);

--SIGNAL  sData1    :   std_logic_vector(31 downto 0);
--SIGNAL  sData2    :   std_logic_vector(31 downto 0);


begin

--process(iData1, iData2)
--begin
--    case(iAdder_op) is
--        when "00" => sData1<=iData1;
--                     sData2<=iData2;
                     
--        when "01" => sData1(0)<='1'; -- x'00000001'
--                     sData1(31 downto 1)<=(others=>'0');
--                     sData2<=iData2;
                     
--        when "10" => sData1<=iData1;
--                     sData2<=(others=>'0');
                     
--        when OTHERS => sData1<=(others=>'0');
--                       sData2<=iData2;
--   end case;
--end process;

gen_fa1:    for i in 0 to 15 generate
        nulti_bit:  if (i=0) generate
            fa_zero:    fAdder
                port map(
                    A=>iData1(0),
                    B=>iData2(0),
                    Cin=>iCarry,
                    S=>sSUM(0),
                    Cout=>sCarry(0)
                );
        end generate nulti_bit;
        
        msb:  if (i=15) generate
                fa_31:    fAdder
                        port map(
                            A=>iData1(i),
                            B=>iData2(i),
                            Cin=>sCarry(i-1),
                            S=>sSUM(i),
                            Cout=>oCarry
                        );
        end generate msb;
        
        rest_bits:  if(i/=15 and i/=0) generate
                        fa_rest:    fAdder
                                port map(
                                    A=>iData1(i),
                                    B=>iData2(i),
                                    Cin=>sCarry(i-1),
                                    S=>sSUM(i),
                                    Cout=>sCarry(i)
                                );
                end generate rest_bits;
end generate gen_fa1;

oData<=sSum;

end Behavioral;
