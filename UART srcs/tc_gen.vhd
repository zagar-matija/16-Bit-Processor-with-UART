library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity TC_gen is
 Generic(
        tc :   natural:=10415
        );
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic;
        oTC         :   out std_logic
 );
end TC_gen;


architecture Behavioral of TC_gen is
    
    SIGNAL  rData:     std_logic_vector(31 downto 0);
    SIGNAL  sSum:      std_logic_vector(31 downto 0);
    SIGNAL  sTC :       std_logic;
begin

process(iCLK, iRST)
begin
    if (iRST='0') then 
        rData<= (OTHERS=>'0');
    elsif(iCLK'event and iCLK='1') then
        rData<=sSum;
    end if;
END process;

process(rData)
begin
        
        if(unsigned(rData)<TC) then
            sSum<=std_logic_vector(unsigned(rData)+1);
            sTC<='0';
        else
            sSum<=(others=>'0');
            sTC<='1';
        end if;
end process;

oTC<=sTC;

end Behavioral;
