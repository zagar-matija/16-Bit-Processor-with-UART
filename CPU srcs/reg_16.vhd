
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity reg_16 is
  Port (
        iCLK    :   in  std_logic;
        inRST   :   in  std_logic;
        iEn     :   in  std_logic;
        iData   :   in  std_logic_vector(15 downto 0);
        oData   :   out std_logic_vector(15 downto 0)
   );
end reg_16;

architecture Behavioral of reg_16 is

SIGNAL sData_buf    :   std_logic_vector(15 downto 0);
SIGNAL sData_out    :   std_logic_vector(15 downto 0);

begin

process(iCLK, inRST)
begin
    if (inRST='0') then
        sData_out<= (others=>'0');
    elsif(iCLK'event and iCLK='1') then
        sData_out<=sData_buf;
    end if;
end process;

process(iEn, sData_out, iData)
begin
    if (iEn='1') then
        sData_buf<=iData;
    else
        sData_buf<=sData_out;
    end if;
end process;

oData<=sData_out;

end Behavioral;
