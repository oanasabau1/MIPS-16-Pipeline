library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
Port (clk : in STD_LOGIC;
      btn : in STD_LOGIC;
      en : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is

signal count: STD_LOGIC_VECTOR(15 downto 0);
signal Q1, Q2, Q3: STD_LOGIC;

begin

counter:process(clk) 
begin
if rising_edge(clk) then
count <= count + 1;
end if;
end process;

D_flipflop1:process(clk)
begin
if rising_edge(clk) then
if count(15 downto 0)="1111111111111111" then 
Q1 <= btn;
end if;
end if;
end process;

D_flipflop2:process(clk)
begin
if rising_edge(clk) then
Q2 <= Q1;
Q3 <= Q2;
end if;
end process;

en <= Q2 AND (not Q3);

end Behavioral;
