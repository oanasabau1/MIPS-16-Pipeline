library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
Port (clk : in STD_LOGIC;
      en : in STD_LOGIC;
      ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
      RD2 : in STD_LOGIC_VECTOR(15 downto 0);
      MemWrite : in STD_LOGIC;			
      MemData : out STD_LOGIC_VECTOR(15 downto 0);
      ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end MEM;

architecture Behavioral of MEM is

type mem_type is array (0 to 31) of STD_LOGIC_VECTOR(15 downto 0);
signal MEM : mem_type := (

X"0005", -- 5
X"000C", -- 12
X"0004", -- 4
X"FFFD", -- -2
X"0011", -- 3
X"0020", -- 32
X"0008", --8
others => X"0000"
);

begin

--synchronous writing on enable in Data Memory
writeInMemory:process(clk) 			
begin
if rising_edge(clk) then
if en = '1' and MemWrite='1' then
MEM(conv_integer(ALUResIn(4 downto 0))) <= RD2;			
end if;
end if;
end process;

--synchronous reading
MemData <= MEM(conv_integer(ALUResIn(4 downto 0)));
ALUResOut <= ALUResIn;

end Behavioral;