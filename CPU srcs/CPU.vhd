

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

entity CPU is
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
end CPU;

architecture Behavioral of CPU is

SIGNAL  sPC_En      :        std_logic;
SIGNAL  sPC_Load    :        std_logic;    
SIGNAL  sMEM_WE     :        std_logic;
SIGNAL  sPC_IN      :        std_logic_vector(15 downto 0);    
SIGNAL  sREG_WE     :        std_logic_vector(8 downto 0);    
SIGNAL  sMUXA_Sel   :        std_logic_vector(3 downto 0);    
SIGNAL  sMUXB_Sel   :        std_logic_vector(3 downto 0);    
SIGNAL  sALU_Sel    :        std_logic_vector(3 downto 0);    

SIGNAL  sMUXA       :        std_logic_vector(15 downto 0);    
SIGNAL  sMUXB       :        std_logic_vector(15 downto 0);    

SIGNAL  sZERO       :        std_logic;
SIGNAL  sSign       :        std_logic;
SIGNAL  sCarry      :        std_logic;
SIGNAL  sRESULT     :        std_logic_vector(15 downto 0); 

SIGNAL  sPC         :        std_logic_vector(15 downto 0); 

SIGNAL sADDR        :       std_logic_vector(15 downto 0);

SIGNAL sData_input  :       std_logic_vector(15 downto 0);

SIGNAL sRConst_data :       std_logic_vector(15 downto 0);  --izlaz iz registra za konstante


type tREG_7 is array (0 to 7) of std_logic_vector(15 downto 0);
SIGNAL sRX          :   tREG_7;

component CU is
 Port ( 
        iCLK        :   in      std_logic;
        iRST        :   in      std_logic;
        iZero       :   in      std_logic;
        iSign       :   in      std_logic;
        iCarry      :   in      std_logic;
        iINSTR      :   in      std_logic_vector(14 downto 0);
        iData       :   in      std_logic_vector(15 downto 0);
        iData_mem   :   in      std_logic_vector(15 downto 0);
        oPC_En      :   out     std_logic;
        oPC_Load    :   out     std_logic;    
        oPC_IN      :   out     std_logic_vector(15 downto 0);    
        oREG_WE     :   out     std_logic_vector(8 downto 0);    
        oMUXA_Sel   :   out     std_logic_vector(3 downto 0);    
        oMUXB_Sel   :   out     std_logic_vector(3 downto 0);    
        oALU_Sel    :   out     std_logic_vector(3 downto 0);    
        oInData     :   out     std_logic_vector(15 downto 0);    
        oMEM_WE     :   out     std_logic
 );
end component;
component reg_16 is
  Port (
        iCLK    :   in  std_logic;
        inRST   :   in  std_logic;
        iEn     :   in  std_logic;
        iData   :   in  std_logic_vector(15 downto 0);
        oData   :   out std_logic_vector(15 downto 0)
   );
end component;

component mux_9n1 is
  Port ( 
        iData0   :   in  std_logic_vector(15 downto 0);
        iData1   :   in  std_logic_vector(15 downto 0);
        iData2   :   in  std_logic_vector(15 downto 0);
        iData3   :   in  std_logic_vector(15 downto 0);
        iData4   :   in  std_logic_vector(15 downto 0);
        iData5   :   in  std_logic_vector(15 downto 0);
        iData6   :   in  std_logic_vector(15 downto 0);
        iData7   :   in  std_logic_vector(15 downto 0);
        iData8   :   in  std_logic_vector(15 downto 0); --from input
        iData9   :   in  std_logic_vector(15 downto 0); --from constant register
        iSel     :   in  std_logic_vector(3 downto 0);
        oData    :   out std_logic_vector(15 downto 0)
  );
end component;

component alu is
 Port (
        iA      :   in  std_logic_vector(15 downto 0); 
        iB      :   in  std_logic_vector(15 downto 0); 
        iSel    :   in  std_logic_vector(3 downto 0);
        oC      :   out std_logic_vector(15 downto 0); 
        oZERO   :   out std_logic;
        oSIGN   :   out std_logic;
        oCarry  :   out std_logic
  );
end component;         

component cnt is
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic;
        iData       :   in std_logic_vector(15 downto 0);
        iEn         :   in  std_logic;  
        iLOAD       :   in  std_logic;
        oData       :   out std_logic_vector(15 downto 0)
 );
end component; 

begin

oData<=sRESULT;
oPC<=sPC;
oMEM_WE<=sMEM_WE;
oADDR<=sMUXB;


pc:         cnt
            Port map( 
                    iCLK=>iCLK,
                    iRST=>iRST,
                    iData=>sPC_in,
                    iEn=>'1',
                    iLOAD=>sPC_LOAD,
                    oData=>sPC
             );
             
al_unit:    alu
            port map(
                iA=>sMUXA,
                iB=>sMUXB,
                iSel=>sALU_Sel,
                oC=>sResult,
                oZERO=>sZERO,
                oSIGN=>sSIGN,
                oCarry=>sCarry
            );
            
MUXA:   mux_9n1
            port map(
                iData0=>sRX(0),
                iData1=>sRX(1),
                iData2=>sRX(2),
                iData3=>sRX(3),
                iData4=>sRX(4),
                iData5=>sRX(5),
                iData6=>sRX(6),
                iData7=>sRX(7),
                iData8=>sData_input,
                iData9=>sRConst_data,
                iSel=>sMUXA_Sel,
                oData=>sMUXA
            );
MUXB:   mux_9n1
            port map(
                iData0=>sRX(0),
                iData1=>sRX(1),
                iData2=>sRX(2),
                iData3=>sRX(3),
                iData4=>sRX(4),
                iData5=>sRX(5),
                iData6=>sRX(6),
                iData7=>sRX(7),
                iData8=>sData_input,
                iData9=>sRConst_data,
                iSel=>sMUXB_Sel,
                oData=>sMUXB
            );
gen_regs:   for i in 0 to 7 generate
        regx: reg_16
            port map(
                    iCLK=>iCLK,
                    inRST=>iRST,
                    iEn=>sREG_WE(i),
                    iData=>sRESULT,
                    oData=>sRX(i)
            );
        end generate;
        
reg_const: reg_16
            port map(
                    iCLK=>iCLK,
                    inRST=>iRST,
                    iEn=>sREG_WE(8),
                    iData=>sRESULT,
                    oData=>sRConst_data
            );       
        
control_unit:  CU
        port map(
                iCLK=>iCLK,
                iRST=>iRST,
                iZero=>sZero,
                iSign=>sSign,
                iCarry=>sCarry,
                iINSTR=>iINSTR,
                iData=>iData,
                iData_mem=>iData_mem,
                oPC_En=>sPC_En,
                oPC_Load=>sPC_Load,
                oPC_IN=>sPC_IN,
                oREG_WE=>sREG_WE,    
                oMUXA_Sel=>sMUXA_Sel,
                oMUXB_Sel=>sMUXB_Sel,
                oALU_Sel=>sALU_Sel,
                oInData=>sData_input,
                oMEM_WE=>sMEM_WE
        );
        

end Behavioral;
