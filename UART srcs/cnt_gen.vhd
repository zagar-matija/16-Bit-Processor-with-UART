library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity cnt_gen is
 Generic(
        ADRESS_BITS :   natural:=4
        );
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic; --active low
        iSoftRST    :   in  std_logic; --active high
        iEn         :   in  std_logic:='1';  
        iUpDown     :   in  std_logic:='1';
        iTC         :   in  std_logic_vector(ADRESS_BITS-1 downto 0):=x"c";
        oADR        :   out std_logic_vector(ADRESS_BITS-1 downto 0)
 );
end cnt_gen;


architecture Behavioral of cnt_gen is
    
    SIGNAL  rData:     std_logic_vector(ADRESS_BITS-1 downto 0);
    SIGNAL  sSum:      std_logic_vector(ADRESS_BITS-1 downto 0);
begin

process(iCLK, iRST)
begin
    if (iRST='0') then 
        rData<= (OTHERS=>'0');
    elsif(iCLK'event and iCLK='1') then
        rData<=sSum;
    end if;
END process;

process(rData, iEn, iUpDown, iSoftRst, iTC)
begin
        if(iSoftRst='1') then
            sSum<=(others=>'0');
                    
        elsif(std_logic_vector(unsigned(rData))<iTC) then
            if(iEn='1' and iUpDown='1') then
                sSum<=std_logic_vector(unsigned(rData)+1);
            elsif(iEn='1' and iUpDown='0') then
                sSum<=std_logic_vector(unsigned(rData)-1);
            else
                sSum<=rData;
            end if;
            
        else
            sSum<=(others=>'0');
        end if;
        
end process;

oADR<=rData;

end Behavioral;
