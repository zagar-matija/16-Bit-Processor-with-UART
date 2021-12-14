library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity cnt is
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic;
        iData       :   in std_logic_vector(15 downto 0);
        iEn         :   in  std_logic;  
        iLOAD       :   in  std_logic;
        oData       :   out std_logic_vector(15 downto 0)
 );
end cnt;


architecture Behavioral of cnt is
    
    SIGNAL  rData:     std_logic_vector(15 downto 0);
    SIGNAL  sSum:      std_logic_vector(15 downto 0);
begin

process(iCLK, iRST)
begin
    if (iRST='0') then 
        rData<= (OTHERS=>'0');
    elsif(iCLK'event and iCLK='1') then
        rData<=sSum;
    end if;
END process;

process(rData, iEn, iLoad, iData)
begin
        if(iLoad='1') then
            sSum<=iData;
        elsif(iEn='1') then
            sSum<=std_logic_vector(unsigned(rData)+1);
        else
            sSum<=rData;
        end if;
end process;

oData<=rData;

end Behavioral;
