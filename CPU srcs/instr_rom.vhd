

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;


entity instr_rom is
 Port ( 
        iAdr    :       in  std_logic_vector(8 downto 0);
        oData   :       out std_logic_vector(14 downto 0)
 );
end instr_rom;

architecture Behavioral of instr_rom is

type rom is ARRAY (0 to 511) of std_logic_vector(14 downto 0);

constant mov    : std_logic_vector(5 downto 0) := o"00";
constant add    : std_logic_vector(5 downto 0) := o"01";
constant sub    : std_logic_vector(5 downto 0) := o"02";
constant and1   : std_logic_vector(5 downto 0) := o"03";
constant or1    : std_logic_vector(5 downto 0) := o"04";
constant not1   : std_logic_vector(5 downto 0) := o"05";
constant inc    : std_logic_vector(5 downto 0) := o"06";
constant dec    : std_logic_vector(5 downto 0) := o"07";
constant shl1   : std_logic_vector(5 downto 0) := o"10";
constant shr1   : std_logic_vector(5 downto 0) := o"11";
constant neg    : std_logic_vector(5 downto 0) := o"12";
constant ashr   : std_logic_vector(5 downto 0) := o"13";

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

constant r0   : std_logic_vector(2 downto 0) := o"0";
constant r1   : std_logic_vector(2 downto 0) := o"1";
constant r2   : std_logic_vector(2 downto 0) := o"2";
constant r3   : std_logic_vector(2 downto 0) := o"3";
constant r4   : std_logic_vector(2 downto 0) := o"4";
constant r5   : std_logic_vector(2 downto 0) := o"5";
constant r6   : std_logic_vector(2 downto 0) := o"6";
constant r7   : std_logic_vector(2 downto 0) := o"7";

constant N3   : std_logic_vector(2 downto 0) := o"0";

--functions:

constant    F_ADD       :   std_logic_vector(8 downto 0):=o"733";--
constant    F_SUB       :   std_logic_vector(8 downto 0):=o"731";--
constant    F_MUL       :   std_logic_vector(8 downto 0):=o"724";--
constant    F_DIV       :   std_logic_vector(8 downto 0):=o"716"; --

constant    F_TX        :   std_logic_vector(8 downto 0):=o"606";--
constant    F_CALC      :   std_logic_vector(8 downto 0):=o"735";--
constant    F_MULTI_10  :   std_logic_vector(8 downto 0):=o"756";--

--locations:

constant    JMPMK1  :   std_logic_vector(8 downto 0):=o"051";
constant    ERROR   :   std_logic_vector(8 downto 0):=o"634";
constant    LOAD    :   std_logic_vector(8 downto 0):=o"006";



Constant rROM     :   rom := (  

--inst  rz  rx  ry
ldconst &'0'&x"00",        
ldconst &'1'&x"10",
mvcreg  &n3 &r7 &n3,    --spremi adresu control registra u r7 (x1000 -> 0001000000000000)

ldconst &'0'&x"05",
mvcreg  &n3 &r4 &n3,    --spremi u r1 podatak za spremiti u control     
st      &n3 &r4 &r7,    --5--spremi u uart kontrolni registar vrijednost x0005



ldconst &'0'&x"01",     --o6--LOAD
mvcreg  &n3 &r7 &n3,    --spremi u r7 vrijednost x0001 s kojom cemo maskirati rx_busy


ldconst &'0'&x"02", --o10
ldconst &'1'&x"10",
mvcreg  &n3 &r2 &n3,    --u r2 je status reg adresa


ld      &r4 &n3 &r2,    ----spremi vrijednost statusnog reg uarta (adresa x1002/r2) u r4
and1    &r5 &r4 &r7,    --maskiraj rx_busy bit
jmpz    &o"013",        --loop koji ucitava status dok ne pocne transmisija(rx_busy)

ld      &r4 &n3 &r2,    --spremi vrijednost statusnog reg uarta (adresa x1002/r0) u r4
and1    &r5 &r4 &r7,    --maskiraj rx_busy bit
jmpnz    &o"016",       ----loop koji ucitava status dok ne zavrsi transmisija(rx_busy=0)
   
ldconst &'0'&x"00",     
ldconst &'1'&x"12",
mvcreg  &n3 &r2 &n3,    --spremi adresu uart rx ram-a u r2

ld      &r5 &n3 &r2,    --20-spremi primljeni podatak u r5, r2 drzi adresu rama gdje citamo --valek 21


ldconst &'0'&x"7f",
mvcreg  &n3 &r2 &n3,
and1    &r5 &r5 &r2,    --postavi 8. bit u '0'

--provjera ';':
    ldconst &'0'&x"3b",         --24      
    mvcreg  &n3 &r4 &n3,        --u r4 spremi ascii ';' 
    sub     &r4 &r5 &r4,        --oduzmi od primljenog podatka ascii ';' radi usporedbe
    jmpz    &F_CALC,            --jump na CALCULATE, r3 je operator 
--provjera operatora:
    ldconst &'0'&x"30",         --28--ucitaj ascii 0
    mvcreg  &n3 &r4 &n3,
    sub     &r4 &r5 &r4,        --provjeri je li znak broj
    jmpns    &o"045",           --31--ako nije preskoci upis operatora i flaga za prijelaz na novi broj--jmp to JMPMK6
        
        mov     &r3 &r5 &n3,    --stavi u r3 primljeni znak jer je operator
        ldconst &'0'&x"01",
        mvcreg  &n3 &r5 &n3,
        or1     &r6 &r6 &r5,    --postavi da je sada zastavica 1, tj da prelazimo na drugi broj
        jmp     &LOAD,
        
--ascii to bin:
    ldconst &'0'&x"30",         --JMPMK6--o45--37
    mvcreg  &n3 &r4 &n3,
    sub     &r5 &r5 &r4,        --posto je r5 ascii znamenka, oduzmi ascii 0 da dobijemo bin

    jmp     &F_MULTI_10,        
    
--zbroji dosadasnji broj i novu znamenku:
    --jmp here from multi function:
    ldconst &'0'&x"01",         --JMPMK1--o51--maska za provjeru je li prvi ili drugi broj
    mvcreg  &n3 &r4 &n3,
    and1    &r4 &r6 &r4,
    jmpz    &o"057",           --jmp to JMPMK2
    add     &r1 &r1 &r5,
    jmp     &LOAD,        --jmp na novo ucitavanje
    add     &r0 &r0 &r5,    ----o57--JMPMK2
 
jmp     &LOAD,    --jump na ucitavanje slj znaka 





o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",
o"00000", o"00000", o"00000", o"00000", o"00000",

o"00000", o"00000",

--f_DIV10
    sub     &r2 &r2 &r2,        --o614--postavi r2 na 0, služi za pra?enje broja znamenki
 
    mov     &r0 &r7 &n3,        --kopiraj rezultat  u r0
    
    ldconst &'0'&x"0a",
    mvcreg  &n3 &r1 &n3,        --u r1 spremamo 10 s kojim djelimo
    
    sub     &r3 &r3 &r3,    --o620--JMPMK14 reset r3 pa djeljenje
    sub     &r4 &r0 &r1,    --o621--JMPMK10 --djeljenje 
    jmps    &o"626",        --jmp to jmpmk11
    inc     &r3 &r3 &N3,
    sub     &r0 &r0 &r1,
    jmp     &o"621",                    --end djeljenje --jmp to jmpmk10
    --r0 je ostatak, r3 je rezultat djeljenja
    inc     &r2 &r2 &n3,       --o626 --povecavamo brojac znamenki  --jmpmk11
    mov     &r0 &r3 &n3,       ----rezultat djeljenja smjestamo u r0 te ce se opet djeliti s 10   
    jmpnz   &o"620",            --jmp to jmpmk14
--

--podesavanje pozicije tx rama na zadnji znak, upisuju se unatrag
    ldconst &'0'&x"00",
    ldconst &'1'&x"11",
    mvcreg  &n3 &r5 &n3,        --na r5 spremamo adresu tx rama
    
    add     &r5 &r5 &r2,        --adresi tx rama dodajemo onoliko znakova koliko ima rezultat, a zatim oduzmemo 1
    dec     &r5 &r5 &n3,
--

--u setting podesi tx_len        
    ldconst &'0'&x"01",         --
    ldconst &'1'&x"10",
    mvcreg  &n3 &r4 &n3,        --u r4 spremi setings adresu
    
    shl1    &r2 &r2 &n3,   
    shl1    &r2 &r2 &n3,   
    shl1    &r2 &r2 &n3,   
    shl1    &r2 &r2 &n3,   --pomakni counter da bude na poziciji tx_len u settings reg
    
    st      &n3 &r2 &r4,        -- spremi u settings num counter na poziciju tx_len
--    

--djeljenje s 10 u svrhu upisivanja ostataka u tx ram
    
    mov     &r0 &r7 &n3,    --spremi u r0 rez
    
    ldconst &'0'&x"0a",     --o651
    mvcreg  &n3 &r1 &n3,        --u r1 spremamo 10 s kojim djelimo
    
    sub     &r3 &r3 &r3,    --o651--JMPMK15 reset r3 pa djeljenje
    sub     &r4 &r0 &r1,    --o652--JMPMK12 --djeljenje 
    jmps    &o"657",        --jmp to jmpmk13
    inc     &r3 &r3 &N3,
    sub     &r0 &r0 &r1,
    jmp     &o"652",         --end djeljenje --jmp to jmpmk12
    --r0 je ostatak, r3 je rezultat djeljenja
    ldconst &'0'&x"30",         --o657--jmpmk13
    mvcreg  &n3 &r6 &n3,        ----u r6 ucitaj ascii 0 za zbrajanje s ostatkom djeljenja
    add     &r0 &r6 &r0,        
    
    st      &n3 &r0 &r5,        --spremi na adresu tx rama podatak iz r0(ostatak djeljenja s 10 + x30)   
    dec     &r5 &r5 &n3,        --pomakni adresu tx rama po kojoj se pise
    mov     &r0 &r3 &n3,        --spremi rez djeljenja kao slj broj koji se djeli
    jmpnz   &o"651",            --jmp to jmpmk15    
    
    --jmp     &F_TX,     
--END F_DIV10

 --F_TX:
   
    ldconst &'0'&x"00",         ----upis ctrl reg adrese u r2
    ldconst &'1'&x"10",         --
    mvcreg  &n3 &r2 &n3,        --o671
    
    ldconst &'0'&x"06",         --upis podatka za ctrl, aktivni su reset i tx_en
    mvcreg  &n3 &r3 &n3,
    
    st      &n3 &r3 &r2,        --pocetak transmisije
------------------------------    
    ldconst &'0'&x"c0",
    ldconst &'1'&x"03",
    mvcreg  &n3 &r0 &n3,    ----spremi u r0 vrijednost x03c0 s kojom cemo maskirati tx_pos
    
    
    ldconst &'0'&x"02", 
    ldconst &'1'&x"10",     --
    mvcreg  &n3 &r2 &n3,    --u r2 je status reg adresa
    
    
    ld      &r4 &n3 &r2,    --o702--spremi vrijednost statusnog reg uarta (adresa x1002/r2) u r4
    and1    &r5 &r4 &r0,    --maskiraj tx_pos bitove
    jmpz    &o"702",        --loop koji ucitava status dok ne pocne transmisija(tx_pos/=0)
    
    ld      &r4 &n3 &r2,    --o705--spremi vrijednost statusnog reg uarta (adresa x1002/r2) u r4
    and1    &r5 &r4 &r0,    --maskiraj tx_pos bitove
    jmpnz    &o"705",       --707--loop koji ucitava status dok ne zavrsi transmisija(tx_pos=0)
     
    ldconst &'0'&x"00",     --o710
    mvcreg  &n3 &r1 &n3,        --zapisi podatak za ctrl reg--x0000
    
    ldconst &'1'&x"10",
    mvcreg  &n3 &r2 &n3,    --zapisi adresu control reg u r1--x1000
    
    st      &n3 &r1 &r2,    --zapisi r1 na adresu iz r2
    jmp     &o"715",        --loop forever --461
    
 --END F_TX
 --F_Div:
     sub     &r7 &r7  &r7,  --o716--inicijalizacija r7 na 0--462

     sub     &r4 &r0 &r1,    --JMPMK8--o717
     jmps    &F_TX,
     inc     &r7 &r7 &N3,
     sub     &r0 &r0 &r1,
     jmp     &o"717",
 --END F_DIV
  
 --F_MUL:
     sub     &r7 &r7  &r7,  --o724--inicijalizacija r7 na 0

     dec     &r1 &r1 &n3,    --JMPMK7 --o725
     jmps    &F_TX,
     add     &r7 &r7 &r0,
     jmp     &o"725",
 --END F_MUL
 
 --F_SUB:
    sub     &r7 &r0 &r1,        --o731
    jmp     &F_TX,
 --END F_SUB
 
 --F_ADD:
    add     &r7 &r0 &r1,        --o733
    jmp     &F_TX,
 --END F_ADD
 
 --F_CALC:
    ldconst &'0'&x"2b",         --477--o735
    mvcreg  &n3 &r4 &n3,
    sub     &r4 &r4 &r3,        --usporedi je li operator '+'
    jmpz    &F_ADD,
    
    ldconst &'0'&x"2d",
    mvcreg  &n3 &r4 &n3,
    sub     &r4 &r4 &r3,        --usporedi je li operator '-'
    jmpz    &F_SUB,
    
    ldconst &'0'&x"2a",
    mvcreg  &n3 &r4 &n3,
    sub     &r4 &r4 &r3,        --usporedi je li operator '*'
    jmpz    &F_MUL,
    
    ldconst &'0'&x"2f",
    mvcreg  &n3 &r4 &n3,
    sub     &r4 &r4 &r3,        --usporedi je li operator '/'
    jmpz    &F_DIV,
    
    
    jmp     &ERROR,              --ako nije nijedan od operatora posalji error
 --END F_CALC
 
--F_MULTI_10:
--provjeri mnozi li se prvi ili drugi broj
    ldconst &'0'&x"01",             --494--o756--
    mvcreg  &n3 &R4 &n3,
    and1    &r4 &r4 &r6,
    jmpnz    &o"771",           -- jmp to JMPMK3, multiply second operand 
    
--pomnozi prvi broj s 10:
    ldconst &'0'&x"09",
    mvcreg &n3 &r4 &n3,
    mov     &r7 &r0 &n3,            -----500-----
    add     &r0 &r0 &r7,        --JMPMK4  --o765
    dec     &r4 &r4 &n3,
    jmpnz    &o"765",               --jmp to JMPMK4
    jmp     &JMPMK1,
    
--pomnozi drugi broj s 10:
    ldconst &'0'&x"09",         --JMPMK3 --o771
    mvcreg  &n3 &r4 &n3,
    mov     &r7 &r1 &n3,
    add     &r1 &r1 &r7,        --JMPMK5    --o774
    dec     &r4 &r4 &n3,
    jmpnz    &o"774",               --jmp to JMPMK5
    jmp     &JMPMK1
--END F_MULTI_10
);
                              
SIGNAL sData    :   std_logic_vector(14 downto 0);

begin

process(iAdr)
begin
    sData<=rRom(to_integer(unsigned(iAdr)));
end process;

oData<=sData;

end Behavioral;
