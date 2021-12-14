library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity uart_rx is
  Port (
      iCLK        :       in  std_logic;
      iRST        :       in  std_logic;
      iUART_RX    :       in  std_logic;
      iEn         :       in  std_logic;
      oRX_busy    :       out std_logic;
      oData       :       out std_logic_vector(7 downto 0);
      oRX_DV      :       out std_logic
 );
 end uart_rx;

architecture Behavioral of uart_rx is

type tState is (idle, data, stop);

SIGNAL  sState_curr     :   tState;
SIGNAL  sState_next     :   tState;

SIGNAL sRX_busy         :   std_logic;

SIGNAL  sTC             :   std_logic;
--SIGNAL  rTC             :   std_logic;

SIGNAL  sTC_samp        :   std_logic;

SIGNAL  rData_counter   :   std_logic_vector(2 downto 0);
SIGNAL  sData_counter   :   std_logic_vector(2 downto 0);
SIGNAL  sStart_count    :   std_logic;

SIGNAL sRX_data         :   std_logic;
SIGNAL rRX_data         :   std_logic;
SIGNAL rrRX_data        :   std_logic;


SIGNAL  sData           :   std_logic_vector(7 downto 0);
SIGNAL  rData           :   std_logic_vector(7 downto 0);

SIGNAL  sData_valid     :   std_logic;


SIGNAL  rrData_counter  :   std_logic_vector(2 downto 0);



component TC_gen is
 Generic(
        tc          :   natural:=10416
        );
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic;
        oTC         :   out std_logic
 );
end component;

begin
state_Tc_gen:    TC_gen
                    generic map(
                        tc=>5207--10415
                    )
                    port map(
                        iCLK=>iCLk,
                        iRST=>iRST,
                        oTC=>sTC
                    );
                    
sample_Tc_gen:    TC_gen
                    generic map(
                        tc=>2603--5207
                    )
                    port map(
                        iCLK=>iCLk,
                        iRST=>iRST,
                        oTC=>sTC_samp
                    );
process(iRST, iCLK)
begin
    if(iRST='0') then
        sState_curr<=idle;
        rData_counter<=(others=>'0');
        rData<=(others=>'0');
        rRX_data<='0';
        rrRX_data<='0';
        --sTC<='0';
    elsif(iCLK'event and iCLK='1') then
        sState_curr<=sState_next;
        rData_counter<=sData_counter;
        rrData_counter<=rData_counter;
        rRX_data<=sRX_data;
        rrRX_data<=rRX_data;
        rData<=sData;
      
        --sTC<=rTC;
    end if;
end process;

Process(rData, sTC, rrData_counter, rrRX_data, sTC_samp)
begin
    sData<=rData;
    if( sTC='0' and sTC_samp='1') then
        sData(to_integer(unsigned(rrData_counter)))<=rrRX_data;
    end if;
end process;

process(rData_counter, sStart_count, sTC, sTC_samp)
begin
            
     if(sStart_count='1') then
       sData_counter<=(others=>'0');
   elsif(sTC='0' and sTC_samp='1') then
       sData_counter<=std_logic_vector(unsigned(rData_counter)+1);
   else
       sData_counter<=rData_counter;
   end if;
end process;

process(sState_curr, rData_counter, sTC, iUART_RX, rRX_data, iEn, sTC_samp)
begin
    sStart_count<='0';
    sRX_data<=rRX_data;
    sData_valid<='0';
    sRX_busy<='1';
    
        case sState_curr is
            when idle   =>  sRX_busy<='0';
                            if(sTC='0' and sTC_samp='1' and iUART_RX='0' and iEn='1') then
                                sState_next<=data;
                                sStart_count<='1';
                            else
                                sState_next<=sState_curr;
                            end if;
                                        
            when data   =>  sRX_data<=iUART_RX;
                       
                            if(unsigned(rData_counter)>6 and sTC='1') then
                                sState_next<=stop;
                            else
                                sState_next<=data;
                            end if;
                            
            when others   =>  if(sTC='1') then --stop
                                sState_next<=idle;
                                sData_valid<='1';
                            else
                                sState_next<=sState_curr;
                               
                            end if;
        end case;
    
end process;

oData<=rData;
oRX_DV<=sData_valid;
oRX_busy<=sRX_busy;

end Behavioral;
