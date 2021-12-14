
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fAdder is
  Port ( 
    A       :   in  std_logic;
    B       :   in  std_logic;
    Cin     :   in  std_logic;
    S       :   out std_logic;
    Cout    :   out std_logic
  );
end fAdder;

architecture Behavioral of fAdder is
    SIGNAL  sS  :   STD_LOGIC;
    SIGNAL  sC  :   STD_LOGIC;

begin
    process(a,b,Cin)
    begin
        sS<=A xor B xor Cin;
        sC <= (a and b) or (a and Cin) or (b and Cin);
    end process;
    S<=sS;
    Cout<=sC;
end Behavioral;
