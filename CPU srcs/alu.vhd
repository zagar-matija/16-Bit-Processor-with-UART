
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity alu is
 Port (
        iA      :   in  std_logic_vector(15 downto 0); 
        iB      :   in  std_logic_vector(15 downto 0); 
        iSel    :   in  std_logic_vector(3 downto 0);
        oC      :   out std_logic_vector(15 downto 0); 
        oZERO   :   out std_logic;
        oSIGN   :   out std_logic;
        oCarry  :   out std_logic
  );
end alu;

architecture Behavioral of alu is

SIGNAL  sData       :   std_logic_vector(15 downto 0);
SIGNAL  sCin        :   std_logic;
SIGNAL  sData_fa    :   std_logic_vector(15 downto 0);
SIGNAL  sData1      :   std_logic_vector(15 downto 0);
SIGNAL  sData2      :   std_logic_vector(15 downto 0);

SIGNAL  sCARRY      :   std_logic;
SIGNAL  sCARRY_o    :   std_logic;
SIGNAL  sZERO       :   std_logic;

component fAdder_16 is
  Port (
  iData1    :   in  std_logic_vector(15 downto 0);
  iData2    :   in  std_logic_vector(15 downto 0);
  iCarry    :   in  std_logic;  
  oCarry    :   out  std_logic;    
  oData     :   out std_logic_vector(15 downto 0)
   );
end component;

begin

process(sData)
begin
    if(sData=x"0000") then
        sZERO<='1';
     else 
        sZERO<='0';
    end if;
end process;

oZERO<=sZERO;
oC<=sData;
oSIGN<=sData(15);
oCarry<=sCarry_o;

process(iSel, iA, iB, sData_fa, sCarry)
begin
    sCarry_o<='0';
    sData1<=(others=>'0');
    sData2<=(others=>'0');
    sCin<='0';
    case iSel is
        when x"0" => sData<=iA;                                                         --A
        when x"1" =>    sData<=sData_fa;                                                --A+B
                        sData1<=iA;
                        sData2<=iB;
                        sCin<='0';
                        sCarry_o<=sCarry;       
                        
        when x"2" => sData<=sData_fa;                                                   --A-B
                            sData1<=iA;
                            sData2<=not iB;
                            sCin<='1'; 
                            sCarry_o<=sCarry;       
                                                                                     
        when x"3" => sData<=iA and iB;                                                  --A AND B
        when x"4" => sData<=iA or iB;                                                   --A OR B
        when x"5" => sData<=not iA;                                                     --NOT A
        when x"6" => sData<=sData_fa;                                                    --A+1
                            sData1<=iA;
                            sData2<=(others=>'0');
                            sCin<='1'; 
                            sCarry_o<=sCarry;       
                                                       
        when x"7" => sData<=sData_fa;                                                    --A-1
                            sData1<=iA;
                            sData2<=(others=>'1');
                            sCin<='0';
                            sCarry_o<=sCarry;  
                                         
        when x"8" => sData<=iA(14 downto 0) & '0';                                      --SHL(A)
        when x"9" => sData<='0' & iA(15 DOWNTO 1);                                      --SHR(A)
        when x"A" => sData<= std_logic_vector(unsigned(not iA)+1);                      --(-A)
        when x"B" => sData<=iA(15) & iA(15 downto 1);                                   --ASHR(A)
        when others => sData<=(others=>'0');                                            --idle
    end case;
end process;
fa: fAdder_16
    port map(
          iData1=>sData1,
          iData2=>sData2,
          iCarry=>sCin,
          oCarry=>sCarry, 
          oData=>sData_fa
    );
end Behavioral;
--std_logic_vector(unsigned(iA)+ unsigned(not iB) +1
--std_logic_vector(unsigned(iA)+unsigned(iB));               