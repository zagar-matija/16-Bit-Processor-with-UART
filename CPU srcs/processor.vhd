
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity processor is
  Port (
        iCLK        :   in      std_logic;
        iRST        :   in      std_logic;
        iUART_RX    :   in      std_logic;
        oUART_TX    :   out     std_logic; 
        iData       :   in      std_logic_vector(15 downto 0)      
   );
end processor;

architecture Behavioral of processor is

SIGNAL  sInstr      :        std_logic_vector(14 downto 0);
SIGNAL  sPC         :        std_logic_vector(15 downto 0);
SIGNAL  sData_ST    :        std_logic_vector(15 downto 0);
SIGNAL  sData_LD    :        std_logic_vector(15 downto 0);
SIGNAL  sADDR       :        std_logic_vector(15 downto 0);
SIGNAL  sMEM_WE     :        std_logic;

SIGNAL  sUART_WE    :        std_logic;
SIGNAL  sRAM_WE     :        std_logic;

SIGNAL  sUART_data  :        std_logic_vector(15 downto 0);
SIGNAL  sRAM_Data   :        std_logic_vector(15 downto 0);


component CPU is
  Port (
          iCLK        :   in      std_logic;
          iRST        :   in      std_logic;
          iData_mem   :   in      std_logic_vector(15 downto 0);
          iData       :   in      std_logic_vector(15 downto 0);
          iInstr      :   in      std_logic_vector(14 downto 0);
          oPC         :   out     std_logic_vector(15 downto 0);
          oData       :   out     std_logic_vector(15 downto 0);
          oADDR       :   out     std_logic_vector(15 downto 0);
          oMEM_WE     :   out     std_logic
   );
end component;

component SPRAM is
 Generic(
        ADRESS_BITS         :   natural:=5;
        RAM_DEPTH           :   natural:=32;
        WORD_LENGHT         :   natural:=16
 );
 Port ( 
        iCLK        :   in      std_logic;
        iRST        :   in      std_logic;
        iAdr        :   in      std_logic_vector(ADRESS_BITS-1 downto 0);
        iData       :   in      std_logic_vector(WORD_LENGHT-1 downto 0);
        iWE         :   in      std_logic;
        oData       :   out     std_logic_vector(WORD_LENGHT-1 downto 0)
 );
end component;

component instr_rom is
 Port ( 
        iAdr    :       in  std_logic_vector(8 downto 0);
        oData   :       out std_logic_vector(14 downto 0)
 );
end component;

component uart_mms is
  Port (
        iCLK        :       in  std_logic;
        iRST        :       in  std_logic;
        
        iWE         :       in  std_logic;
        iADDR       :       in  std_logic_vector(15 downto 0);
        iData       :       in  std_logic_vector(15 downto 0);
        oData       :       OUT std_logic_vector(15 downto 0);
        
        iUART_RX    :       in  std_logic;
        oUART_TX    :       out std_logic    
   );
end component;

begin
uart:   uart_mms
        Port map (
            iCLK=>iCLK,
            iRST=>iRST,
            
            iWE=>sUART_WE,
            iADDR=>sADDR,
            iData=>sDATA_ST,
            oData=>sUART_data,
            
            iUART_RX=>iUART_RX,
            oUART_TX=>oUART_TX
   );
rom:    instr_rom
        port map(
            iAdr=>sPC(8 downto 0),              --??
            oData=>sInstr
        );
        
--ram:    spram
--        port map(
--            iCLK=>iCLK,
--            iRST=>iRST,
--            iAdr=>sAddr(4 downto 0),            --??
--            iWE=>sRAM_WE,
--            iData=>sData_ST,
--            oData=>sRAM_data
--        );

sRAM_data<=(others=>'0');
cpu_top:    cpu
        port map(
            iCLK=>iCLK,
            iRST=>iRST,
            iData_mem=>sData_LD,
            iData=>iData,
            iInstr=>sInstr,
            oPC=>sPC,
            oData=>sData_ST,
            oADDR=>sADDR,
            oMEM_WE=>sMEM_WE
        );

process(sRAM_data, sUART_data, sADDR)  --mux, bira ulaz u proc, uart/ram
begin   
    if(sADDR>x"0fff" and sADDr<x"1300") then
        sData_LD<=sUART_data;
    else
        sDATA_LD<=sRAM_data;
    end if;
end process;

process(sMEM_WE, sADDR)  --demux, bira we za uart ili ram
begin   
    sUART_WE<='0';
    sRAM_WE<='0';
    
    if(sADDR>x"0fff" and sADDr<x"1300") then
        sUART_WE<=sMEM_WE;
    elsif(sADDR<x"0020") then
        sRAM_WE<=sMEM_WE;
    end if;
end process;

end Behavioral;
