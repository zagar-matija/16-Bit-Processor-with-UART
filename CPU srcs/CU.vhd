

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--use IEEE.NUMERIC_STD.ALL;

entity CU is
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
        oMEM_WE     :   out     std_logic;
        oInData     :   out     std_logic_vector(15 downto 0)
 );
end CU;

architecture Behavioral of CU is

constant jmp    : std_logic_vector(5 downto 0) := o"20";
constant jmpz   : std_logic_vector(5 downto 0) := o"21";
constant jmps   : std_logic_vector(5 downto 0) := o"22";
constant jmpc   : std_logic_vector(5 downto 0) := o"23";
constant jmpnz  : std_logic_vector(5 downto 0) := o"25";
constant jmpns  : std_logic_vector(5 downto 0) := o"26";
constant jmpnc  : std_logic_vector(5 downto 0) := o"27";

constant ld     : std_logic_vector(5 downto 0) := o"40";
constant st     : std_logic_vector(5 downto 0) := o"60";

constant mvireg : std_logic_vector(5 downto 0) := o"41";
constant mvimem : std_logic_vector(5 downto 0) := o"42";

constant ldconst: std_logic_vector(5 downto 0) := o"46";
constant mvcreg : std_logic_vector(5 downto 0) := o"47";



SIGNAL  sMEM_WE     :   std_logic;

SIGNAL  sMUXA_SEL   :   std_logic_vector(3 downto 0);
SIGNAL  sMUXB_SEL   :   std_logic_vector(3 downto 0);

SIGNAL sALU_Sel     :   std_logic_vector(3 downto 0); 

SIGNAL sREG_WE      :   std_logic_vector(8 downto 0);
SIGNAL sREG_Z       :   std_logic_vector(3 downto 0);

SIGNAL  sPC_En      :   std_logic;
SIGNAL  sPC_Load    :   std_logic;    
SIGNAL  sPC_IN      :   std_logic_vector(15 downto 0);    
 
SIGNAL  rZero       :   std_logic; 
SIGNAL  rSign       :   std_logic; 
SIGNAL  rCarry      :   std_logic; 

SIGNAL  sZero       :   std_logic; 
SIGNAL  sSign       :   std_logic; 
SIGNAL  sCarry      :   std_logic; 

SIGNAL  sInData     :   std_logic_vector(15 downto 0);

begin
 oPC_en<=sPC_en;
 oPC_Load<=sPC_Load;
 oPC_IN<=sPC_IN;
 oREG_WE<=sREG_WE;
 oMUXA_Sel<=sMUXA_Sel;
 oMUXB_Sel<=sMUXB_Sel;
 oALU_Sel<=sALU_Sel;
 oMEM_WE<=sMEM_WE;
 oInData<=sInData;
 process(iZero, iSign, iCarry)
 begin
    sZero<=iZero;
    sSign<=iSign;
    sCarry<=iCarry;
 end process;
 
 process(iCLK, iRST)
 begin
    if(iRST='0') then
        rZero<= '0';
        rSign<= '0';
        rCarry<= '0';
    elsif(iCLK'event and iCLK='1') then
        rZero<= sZero;
        rSign<= sSign;
        rCarry<= sCarry;
    end if;
 end process;
 
process(iINSTR, iData, iData_mem, rZero, rSign, rCarry)
begin
    sALU_Sel    <=(others=>'0');
    sMUXA_Sel   <=(others=>'0');
    sMUXB_Sel   <=(others=>'0');
    sREG_Z      <=(others=>'0');
    sPC_en<='1';
    sPC_Load<='0';
    sPC_in<= x"0000";
    sMEM_WE     <='0';
    sInData<=(others=>'0');
    
        case iInstr(14 downto 9) is
            when jmp =>     sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= (6 downto 0 => '0') & iInstr(8 downto 0);
            when jmpz => if(rZero='1') then    
                            sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= "0000000" & iInstr(8 downto 0);
                         end if;
            when jmps => if (rSign='1') then    
                            sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= (6 downto 0 => '0') & iInstr(8 downto 0);
                         end if;
            when jmpc => if (rCarry='1') then    
                            sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= (6 downto 0 => '0') & iInstr(8 downto 0);
                         end if;
            when jmpnz => if (rZero='0') then    
                            sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= (6 downto 0 => '0') & iInstr(8 downto 0);
                         end if;
            when jmpns => if (rSign='0') then    
                            sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= (6 downto 0 => '0') & iInstr(8 downto 0);
                         end if;
            when jmpnc => if (rCarry='0') then    
                            sPC_en<='0';
                            sPC_Load<='1';
                            sPC_in<= (6 downto 0 => '0') & iInstr(8 downto 0);
                         end if;
                         
            when ld =>      sMUXA_Sel   <='1' & iInstr(5 downto 3);
                            sMUXB_Sel   <='0' & iInstr(2 downto 0);
                            sInData     <=iData_mem;
                            sALU_Sel    <=x"0";
                            sREG_Z      <='0'&iInstr(8 downto 6);
                            
            when st =>      sMUXA_Sel   <='0' & iInstr(5 downto 3);
                            sMUXB_Sel   <='0' & iInstr(2 downto 0);
                            sALU_Sel    <=x"0";
                            sREG_Z      <='0' & iInstr(5 downto 3); 
                            sMEM_WE     <='1';
                            
            when mvimem =>  sMUXA_Sel   <='1' & iInstr(5 downto 3); -- ne radi, uvijek pise po nultoj rijeci u ramu
                            sMUXB_Sel   <='0' & iInstr(2 downto 0);
                            sInData     <=iData;
                            sALU_Sel    <=x"0";
                            sMEM_WE     <='1';
                            sREG_Z      <='1' & iInstr(8 downto 6);        
                              
            when mvireg =>  sMUXA_Sel   <= x"8";
                            sMUXB_Sel   <='0' & iInstr(2 downto 0);
                            sInData     <=iData;
                            sALU_Sel    <=x"0";
                            sREG_Z      <='0' & iInstr(5 downto 3); 
                            
            when ldconst=>  sMUXA_Sel   <= x"8";
                            sMUXB_Sel   <= x"9";
                            sREG_Z      <=x"8"; 
                            
                            if(iInstr(8)='1')then
                                sInData <=iInstr(7 downto 0) & x"00";
                                sALU_SEL<=x"4";
                            else
                                sInData <= x"00" & iInstr(7 downto 0);
                                sALU_Sel    <=x"0";
                            end if;
                            
            when mvcreg =>  sMUXA_Sel   <= x"9";
                            sMUXB_Sel   <=x"0";
                            sInData     <=iData;
                            sALU_Sel    <=x"0";
                            sREG_Z      <='0' & iInstr(5 downto 3);                

            when others=>       
                            sALU_Sel<=iInstr(12 downto 9);
                            sMUXA_Sel<='0' & iInstr(5 downto 3);
                            sMUXB_Sel<='0' & iInstr(2 downto 0);
                            sREG_Z<='0' & iInstr(8 downto 6);    
        end case;
end process;

process(sREG_z)
begin
    case sREG_z is
        when x"0"   => sREG_WE<="000000001";
        when x"1"   => sREG_WE<="000000010";
        when x"2"   => sREG_WE<="000000100";
        when x"3"   => sREG_WE<="000001000";
        when x"4"   => sREG_WE<="000010000";
        when x"5"   => sREG_WE<="000100000";
        when x"6"   => sREG_WE<="001000000";
        when x"7"   => sREG_WE<="010000000";
        when x"8"   => sREG_WE<="100000000";
        when others => sREG_WE<=(others=>'0');
    end case;
end process;



end Behavioral;
