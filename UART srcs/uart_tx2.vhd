

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity uart_tx2 is
  Port (
        iCLK        :       in  std_logic;
        iRST        :       in  std_logic;
        iTX_En      :       in  std_logic;                 
        iTX_data    :       in  std_logic_vector(7 downto 0); 
        oTX_busy    :       out std_logic;  
        oTX_done    :       out std_logic;                                                               
        oUART_TX    :       out std_logic
   );
end uart_tx2;

architecture Behavioral of uart_tx2 is

component TC_gen is
 Generic(
        tc :   natural:=10415

        );
 Port ( 
        iCLK        :   in  std_logic;
        iRST        :   in  std_logic;
        oTC         :   out std_logic
 );
end component;

--type word is array (0 to 2) of std_logic_vector(7 downto 0);

--constant cSOS       :   word:=(x"53", x"4f", x"53");

type tState is (idle, start, data, stop);

SIGNAL  sState_curr    :   tState;
SIGNAL  sState_next    :   tState;

SIGNAL  sTC            :   std_logic;

SIGNAL  sTX_busy       :   std_logic;

SIGNAL  sTX_done       :   std_logic;

SIGNAL  rData_counter  :    std_logic_vector(2 downto 0);
SIGNAL  sData_counter  :    std_logic_vector(2 downto 0);
SIGNAL  sStart_count   :   std_logic;
SIGNAL  sUART_TX       :   std_logic;

SIGNAL  rData_in       :   std_logic_vector(7 downto 0);
SIGNAL  sData_in       :   std_logic_vector(7 downto 0);

--signal sConst_rotate    :   std_logic_vector(2 downto 0);
--signal rConst_rotate    :   std_logic_vector(2 downto 0);

begin
process(sTC, iTX_Data, iTX_En, rData_in)
begin
    if(iTX_En='1' and sTC='1') then
        sData_in<=iTX_data;     
    else 
        sData_in<=rData_in;
    end if;
end process;

state_Tc_gen:    TC_gen
            generic map(
                tc=>5207--10415
            )
            port map(
                iCLK=>iCLk,
                iRST=>iRST,
                oTC=>sTC
            );
                    

process(iRST, iCLK)
begin
    if(iRST='0') then
        sState_curr<=idle;
        rData_counter<=(others=>'0');
        rData_in<=(others=>'0');
--        rConst_rotate<=(others=>'0');
    elsif(iCLK'event and iCLK='1') then
        sState_curr<=sState_next;
        rData_counter<=sData_counter;
        rData_in<=sData_in;
--        rConst_rotate<=sConst_rotate;
               
    end if;
end process;

process(rData_counter, sStart_count, sState_next, sTC)
begin
--    if(sState_next=stop and unsigned(rConst_rotate)<2 and sTC='1') then
--            sConst_rotate<=std_logic_vector(unsigned(rConst_rotate)+1);
--    elsif(sState_next=stop and unsigned(rConst_rotate)>1) then
--            sConst_rotate<=(others=>'0');
--    else
--            sConst_rotate<=rConst_rotate;
--    end if;
        
    if(sStart_count='1') then
        sData_counter<=(others=>'0');
    elsif(sTC='1') then
        sData_counter<=std_logic_vector(unsigned(rData_counter)+1);
    else
        sData_counter<=rData_counter;
    end if;
end process;

process(sState_curr, rData_counter, sTC, iTX_en, iTX_data, rData_in)
begin
    sStart_count<='0';
    sUART_TX<='1';
    sTX_done<='0';
    sTX_busy<='1';
        case sState_curr is
            when idle   =>  sTX_busy<='0';
                            if(iTX_en='1' and sTC='1') then
                                sState_next<=start;
                            else
                                sState_next<=idle;
                            end if;
            when start   =>  if(sTC='1') then
                                    sState_next<=data;
                                else
                                    sState_next<=sState_curr;
                                end if;
                             sStart_count<='1';
                             sUART_TX<='0';
                             
            when data   =>  sUART_TX<=rData_in(to_integer(unsigned(rData_counter)));
                            if(unsigned(rData_counter)>=7 and sTC='1') then
                                sState_next<=stop;
                            else
                                sState_next<=data;
                            end if;
                            
            when others   =>  if(sTC='1') then  --stop state
                                sState_next<=idle;
                                sTX_done<='1';
                            else
                                sState_next<=stop;
                            end if;
        end case;
    
end process;

oUART_TX<=sUART_TX;
oTX_done<=sTX_done;
oTX_busy<=sTX_busy;
end Behavioral;
