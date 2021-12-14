

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity mux_9n1 is
  Port ( 
        iData0   :   in  std_logic_vector(15 downto 0);
        iData1   :   in  std_logic_vector(15 downto 0);
        iData2   :   in  std_logic_vector(15 downto 0);
        iData3   :   in  std_logic_vector(15 downto 0);
        iData4   :   in  std_logic_vector(15 downto 0);
        iData5   :   in  std_logic_vector(15 downto 0);
        iData6   :   in  std_logic_vector(15 downto 0);
        iData7   :   in  std_logic_vector(15 downto 0);
        iData8   :   in  std_logic_vector(15 downto 0);
        iData9   :   in  std_logic_vector(15 downto 0);
        iSel     :   in  std_logic_vector(3 downto 0);
        oData    :   out std_logic_vector(15 downto 0)
  );
end mux_9n1;

architecture Behavioral of mux_9n1 is

SIGNAL  sData   :   std_logic_vector(15 downto 0);

begin

process(iSel, iData0, iData1, iData2, iData3, iData4, iData5, iData6, iData7, iData8, iData9)
begin
    case iSel is
        when x"0"   => sData<=iData0;
        when x"1"   => sData<=iData1;
        when x"2"   => sData<=iData2;
        when x"3"   => sData<=iData3;
        when x"4"   => sData<=iData4;
        when x"5"   => sData<=iData5;
        when x"6"   => sData<=iData6;
        when x"7"   => sData<=iData7;
        when x"8"   => sData<=iData8;
        when x"9"   => sData<=iData9;
        when OTHERS => sData<=(others=>'0');
    end case;
end process;

oData<=sData;

end Behavioral;
