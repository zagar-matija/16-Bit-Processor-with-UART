library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rxtx_top is
  Port (
        iCLK        :       in  std_logic;
        iRST        :       in  std_logic;
        
        iCntRst     :       in  std_logic;
        
        iUART_RX    :       in  std_logic;
        iRX_En      :       in  std_logic:='1';
        iRX_LEN     :       in  std_logic_vector(3 downto 0);       
        iRX_adr_r   :       in  std_logic_vector(3 downto 0);   
                
        oRX_pos     :       out std_logic_vector(3 downto 0);   
        oRX_data    :       out std_logic_vector(7 downto 0);
        oRX_busy    :       out std_logic;
        
        iTX_En      :       in  std_logic;            
        iTX_WE      :       in  std_logic;                                                                                   
        iTX_LEN     :       in  std_logic_vector(3 downto 0);                                                                                    
        iTX_adr_W   :       in  std_logic_vector(3 downto 0);                                                                                 
        iTX_data    :       in  std_logic_vector(7 downto 0);                                                                                   
                
        oTX_pos     :       out std_logic_vector(3 downto 0);
        oTX_busy    :       out std_logic;  
        oUART_TX    :       out std_logic
        
   );
end rxtx_top;

architecture Behavioral of rxtx_top is

SIGNAL  sRX_data            :   std_logic_vector(7 downto 0);
SIGNAL  sRX_WE              :   std_logic;
SIGNAL  sRX_Adr_w           :   std_logic_vector(3 downto 0);

SIGNAL  sTX_Adr_r           :   std_logic_vector(3 downto 0);
SIGNAL  sTX_data_in            :   std_logic_vector(7 downto 0);
SIGNAL  sTX_done            :   std_logic;


component cnt_gen is
 Generic(
        ADRESS_BITS :   natural:=3
        );
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic;
        iSoftRST    :   in  std_logic; --active high
        iEn         :   in  std_logic;        
        iTC         :   in  std_logic_vector(ADRESS_BITS-1 downto 0):=x"c";
        iUpDown     :   in  std_logic;
        oADR        :   out std_logic_vector(ADRESS_BITS-1 downto 0)
 );
end component;

component uart_tx2 is
  Port (
        iCLK        :       in  std_logic;
        iRST        :       in  std_logic;
        iTX_En      :       in  std_logic;          
        iTX_data    :       in  std_logic_vector(7 downto 0);   
        oTX_done    :       out std_logic;                   
        oTX_busy    :       out std_logic;  
        oUART_TX    :       out std_logic
   );
end component;

component uart_rx is
  Port (
      iCLK        :       in  std_logic;
      iRST        :       in  std_logic;
      iUART_RX    :       in  std_logic;
      iEn         :       in  std_logic;
      oData       :       out std_logic_vector(7 downto 0);
      oRX_busy    :       out std_logic;
      oRX_DV      :       out std_logic
 );
 end component;
 
 component DPRAM is
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
 end component;
 
 
begin

--process(sRX_ADR_W, sTX_ADR_R)
--begin
    oTX_pos<=sTX_ADR_R;
    oRX_pos<=sRX_ADR_W;
--end process;
--RX Dio:

rx: uart_rx
    port map(
        iCLK=>iCLK,
        iRST=>iRST,
        iUART_RX=>iUART_RX,
        iEn=>iRX_En,
        oRX_busy=>oRX_busy,
        oData=>sRX_data,
        oRX_DV=>sRX_WE
    );
    
cnt_rx:     cnt_gen
        Generic map(
            ADRESS_BITS=>4
            )
        Port map( 
            iCLK=>iCLk,
            iRST=>iRST,
            iEn=>sRX_WE,
            iSoftRst=>iCntRst,
            iTC=>iRX_LEN,
            iUpDown=>'1',
            oADR=>sRX_ADR_W
     );
     
rx_ram: dpram
        Generic map(
            ADRESS_BITS=>4,
            RAM_DEPTH=>16,
            WORD_LENGHT=>8
            )
        Port map( 
            iCLK=>iCLk,
            iRST=>iRST,
            iAdr_w=>sRX_adr_w,
            iAdr_r=>iRX_Adr_R,
            iData=>sRX_data,
            iWE=>sRX_WE,
            oData=>oRX_data
       );
       
--TX dio:
       
tx: uart_tx2
       port map(
           iCLK=>iCLK,
           iRST=>iRST,
           iTX_En=>iTX_En,         
           iTX_data=>sTX_data_in,
           oUART_TX=>oUART_TX,
           oTX_busy=>oTX_busy,
           oTX_done=>sTX_done
       );
cnt_tx:     cnt_gen
           Generic map(
               ADRESS_BITS=>4
               )
           Port map( 
               iCLK=>iCLk,
               iRST=>iRST,
               iSoftRst=>iCntRst,  
               iEn=>sTX_done,
               iTC=>iTX_LEN,
               iUpDown=>'1',
               oADR=>sTX_ADR_R
        );
tx_ram: dpram
            Generic map(
                ADRESS_BITS=>4,
                RAM_DEPTH=>16,
                WORD_LENGHT=>8
                )
            Port map( 
                iCLK=>iCLk,
                iRST=>iRST,
                iAdr_w=>iTX_adr_w,
                iAdr_r=>sTX_Adr_R,
                iData=>iTX_data,
                iWE=>iTX_WE,
                oData=>sTX_data_in
           );
end Behavioral;
