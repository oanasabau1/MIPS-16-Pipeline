library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MainControl is
Port (Instr : in STD_LOGIC_VECTOR(2 downto 0);
      RegDst : out STD_LOGIC;
      ExtOp : out STD_LOGIC;
      ALUSrc : out STD_LOGIC;
      Branch : out STD_LOGIC;
      Jump : out STD_LOGIC;
      ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
      MemWrite : out STD_LOGIC;
      MemtoReg : out STD_LOGIC;
      RegWrite : out STD_LOGIC);
end MainControl;

architecture Behavioral of MainControl is

begin

process(Instr)
begin
case (Instr) is 
-- R type
when "000" => RegDst <= '1';
              ExtOp <= '0';  --ExtOp <= 'X'
              ALUSrc <= '0';
              Branch <= '0';
              Jump <= '0';
              ALUOp <= "000";
              MemWrite <= '0';
              MemtoReg <= '0';
              RegWrite <= '1';
-- LW    
when "010" => RegDst <= '0';
              ExtOp <= '1';
              ALUSrc <= '1';
              Branch <= '0';
              Jump <= '0';
              ALUOp <= "001";
              MemWrite <= '0';
              MemtoReg <= '1';
              RegWrite <= '1';
 -- SW   
when "011" => RegDst <= '0';
              ExtOp <= '1';
              ALUSrc <= '1';
              Branch <= '0';
              Jump <= '0';
              ALUOp <= "001";
              MemWrite <= '1';
              MemtoReg <= '0';
              RegWrite <= '0';
-- BEQ    
when "100" => RegDst <= '0';
              ExtOp <= '1';
              ALUSrc <= '0';
              Branch <= '1';
              Jump <= '0';
              ALUOp <= "010";
              MemWrite <= '0';
              MemtoReg <= '0';
              RegWrite <= '0';
-- J    
when "111" => RegDst <= '0';
              ExtOp <= '0';
              ALUSrc <= '0';
              Branch <= '0';
              Jump <= '1';
              ALUOp <= "000";
              MemWrite <= '0';
              MemtoReg <= '0';
              RegWrite <= '0';
    
when others => RegDst <= '0';
               ExtOp <= '0';
               ALUSrc <= '0';
               Branch <= '0';
               Jump <= '0';
               ALUOp <= "000";
               MemWrite <= '0';
               MemtoReg <= '0';
               RegWrite <= '0';
end case;
end process;		

end Behavioral;