
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_mms is
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
end uart_mms;

architecture Behavioral of uart_mms is
    SIGNAL  sCONTROL_WE         :       std_logic;
    SIGNAL  sControl_we_or_rst         :       std_logic;
    SIGNAL  sCONTROL_Data       :       std_logic_vector(15 downto 0);
    SIGNAL  sCONTROL_Data_in    :       std_logic_vector(15 downto 0);

    
    SIGNAL  sStatus_data        :       std_logic_vector(15 downto 0);
    SIGNAL  sStatus_in          :       std_logic_vector(15 downto 0);

    SIGNAL  sSETTINGS_WE        :       std_logic;
    SIGNAL  sSETTINGS_Data      :       std_logic_vector(15 downto 0);

    SIGNAL  sTX_RAM_WE          :       std_logic;
    SIGNAL  sTX_RAM_adr         :       std_logic_vector(3 downto 0);
    
    SIGNAL  sRX_RAM_adr         :       std_logic_vector(3 downto 0);
    SIGNAL  sRX_RAM_data        :       std_logic_vector(7 downto 0);

    
    SIGNAL  sData_out           :       std_logic_vector(15 downto 0);
    
    Signal  sTX_RAM_adr_temp    :       std_logic_vector(15 downto 0);
    Signal  sRX_RAM_adr_temp    :       std_logic_vector(15 downto 0);    


 component rxtx_top is
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
begin

sStatus_in(15 downto 10)<=(others=>'0');

uart: rxtx_top
    Port map(
        iCLK=>iCLk,
        iRST=>iRST,
        
        iCntRst=>sControl_data(2),
        
        iUART_RX=>iUART_RX,               --?
        iRX_En      =>sControl_data(0),
        iRX_LEN     =>sSettings_data(3 downto 0),       
        iRX_adr_r   =>sRX_RAM_adr,   
                
        oRX_pos     =>sStatus_in(5 downto 2),--rj
        oRX_data    =>sRX_RAM_data,
        oRX_busy    =>sStatus_in(0),
        
        iTX_En      =>sControl_data(1),        
        iTX_WE      =>sTX_RAM_WE,                                                                                   
        iTX_LEN     =>sSettings_data(7 downto 4),                                                                                  
        iTX_adr_W   =>sTX_RAM_adr,                                                                    
        iTX_data    =>iData(7 downto 0),                                                                             
                
        oTX_pos     =>sStatus_in(9 downto 6),
        oTX_busy    =>sStatus_in(1),  
        oUART_TX    => oUART_TX--???      
   );
ctrl_reg:   reg_16
        port map(
            iCLK=>iCLk,
            inRST=>iRST,
            iEn=>sControl_we_or_rst,
            iData=>sCONTROL_Data_in,
            oData=>sCONTROL_Data
        );
        
settings_reg:   reg_16
        port map(
            iCLK=>iCLk,
            inRST=>iRST,
            iEn=>sSETTINGS_WE,
            iData=>iData,
            oData=>sSETTINGS_Data
        );
status_reg:   reg_16
            port map(
                iCLK=>iCLk,
                inRST=>iRST,
                iEn=>'1',
                iData=>sStatus_in, 
                oData=>sSTATUS_data
            );
            
process(iData, sCONTROL_WE, sCONTROL_Data)  -- clearing the control reg reset 
begin
    sControl_we_or_rst<='0';
    if(sCONTROL_WE='1') then
        sCONTROL_Data_in<=iData;
        sControl_we_or_rst<='1';
    elsif(sControl_data(2)='1') then
        sCONTROL_Data_in<=sCONTROL_Data and x"fffb";
        sControl_we_or_rst<='1';
    else
        sControl_data_in <= sControl_data;
    end if;
end process;

process(iAddr)
begin
    sTX_RAM_adr_temp<=std_logic_vector(unsigned(iADDR)-x"1100");
    sRX_RAM_adr_temp<=std_logic_vector(unsigned(iADDR)-x"1200");
end process;

process(iWE, iADDR, sSettings_data, sControl_data, sRX_RAM_data, sStatus_data, sTX_RAM_adr_temp, sRX_RAM_adr_temp)
begin
    sCONTROL_WE<='0';
    sSETTINGS_WE<='0';
    sTX_RAM_WE<='0';
    sTX_RAM_WE<='0';
    sTX_RAM_adr<=(others=>'0');
    sRX_RAM_adr<=(others=>'0');
    sData_out<=(others=>'0');
    
    if(iADDR>=x"1000" and iADDR<x"1300") then
        if(iADDR=x"1000" ) then                 --ctrl reg control, rw
            if(iWE='1') then
                sCONTROL_WE<='1';
            else
                sData_out<=sControl_data;
            end if;
        elsif(IADDR=x"1001") then               --settings reg control, rw
            if(iWE='1') then
                sSETTINGS_WE<='1';
            else
                sData_out<=sSettings_data;
            end if;
        elsif(IADDR=x"1002") then               -- status reg, read only
            if(iWE='0') then
                sData_out<=sStatus_data;
            end if;
              
        elsif(iADDR>=x"1100" and iADDR<x"1110" and iWE='1') then        --tx ram access, write only
                sTX_RAM_WE<='1';
                sTX_RAM_adr<=sTX_RAM_adr_temp(3 downto 0);
        elsif(iADDR>=x"1200" and iADDR<x"1210" and iWE='0') then        --rx ram access, read only
                sRX_RAM_adr<=sRX_RAM_adr_temp(3 downto 0);
                sData_out<=x"00" & sRX_RAM_data;
        end if;
    end if;
end process;
    
oData<=sDAta_out;

end Behavioral;
