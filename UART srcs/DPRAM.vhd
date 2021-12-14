
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity DPRAM is
 Generic(
        ADRESS_BITS         :   natural:=4;
        RAM_DEPTH           :   natural:=16;
        WORD_LENGHT         :   natural:=16
 );
 Port ( 
        iCLK        :   in      std_logic;
        iRST        :   in      std_logic;
        iAdr_w      :   in      std_logic_vector(ADRESS_BITS-1 downto 0);
        iAdr_r      :   in      std_logic_vector(ADRESS_BITS-1 downto 0);
        iData       :   in      std_logic_vector(WORD_LENGHT-1 downto 0);
        iWE         :   in      std_logic;
        oData       :   out     std_logic_vector(WORD_LENGHT-1 downto 0)
 );
end dPRAM;

architecture Behavioral of dPRAM is

type tRAM   is array (0 to RAM_DEPTH-1) of std_logic_vector(WORD_LENGHT-1 downto 0);

SIGNAL sRAM :   tRAM;
SIGNAL rRAM :   tRAM;

begin

process(iRSt, iCLK)
begin
    if(iRST='0') then
        rRAM<=(others=>(others=>'0'));
    elsif(iCLK'event and iCLK='1') then
        rRAM<=sRAM;
        
    end if;
end process;

process(rRAM, iWE, iData, iADR_w)
begin
    sRAM<=rRAM;
    if(iWE='1') then
        sRAM(to_integer(unsigned(iADR_w)))<=iData;
    end if;
end process;

process(rRam, iAdr_r)
begin
    oData<=rRAM(to_integer(unsigned(iADR_r)));
end process;

end Behavioral;









