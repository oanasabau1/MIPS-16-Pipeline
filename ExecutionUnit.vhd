library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ExecutionUnit is
Port (PCinc : in STD_LOGIC_VECTOR(15 downto 0);
      RD1 : in STD_LOGIC_VECTOR(15 downto 0);
      RD2 : in STD_LOGIC_VECTOR(15 downto 0);
      Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
      func : in STD_LOGIC_VECTOR(2 downto 0);
      sa : in STD_LOGIC;
      rt : in STD_LOGIC_VECTOR(2 downto 0);
      rd : in STD_LOGIC_VECTOR(2 downto 0);
      RegDst : in STD_LOGIC;
      ALUSrc : in STD_LOGIC;
      ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
      BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
      ALURes : out STD_LOGIC_VECTOR(15 downto 0);
      Zero : out STD_LOGIC;
      rWa : out STD_LOGIC_VECTOR(2 downto 0));
end ExecutionUnit;

architecture Behavioral of ExecutionUnit is

signal ALUIn1, ALUIn2, ALUResAux : STD_LOGIC_VECTOR(15 downto 0);
signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);

begin

-- MUX for ALU input 2
MUX_ALU:process(ALUSrc)
begin
case ALUSrc is
   when '0' => ALUIn2 <= RD2;
   when '1' => ALUIn2 <= Ext_Imm;
   when others => ALUIn2 <= (others => 'X');
end case;
end process;
      
ALU_Control:process(ALUOp, func)
begin
case ALUOp is
    when "000" => -- R type INSTRUCTIONS
        case func is
            when "000" => ALUCtrl <= "000"; -- ADD
            when "001" => ALUCtrl <= "001"; -- SUB
            when "010" => ALUCtrl <= "010"; -- SLL
            when "011" => ALUCtrl <= "011"; -- SRL
            when "100" => ALUCtrl <= "100"; -- AND
            when "101" => ALUCtrl <= "101"; -- OR
            when "110" => ALUCtrl <= "110"; -- XOR
            when "111" => ALUCtrl <= "111"; -- SLT
            when others => ALUCtrl <= (others => '0'); 
        end case;
    when "001" => ALUCtrl <= "000"; -- +
    when "010" => ALUCtrl <= "001"; -- -
    when "101" => ALUCtrl <= "100"; -- &
    when "110" => ALUCtrl <= "101"; -- |
    when others => ALUCtrl <= (others => '0'); 
end case;
end process;

ALU:process(ALUCtrl, RD1, AluIn2, sa, ALUResAux)
begin
case ALUCtrl  is
    when "000" => -- ADD
        ALUResAux <= RD1 + ALUIn2;
    when "001" =>  -- SUB
        ALUResAux <= RD1 - ALUIn2;                                    
    when "010" => -- SLL
        case sa is
            when '0' => ALUResAux <= ALUIn2;
            when '1' => ALUResAux <= ALUIn2(14 downto 0) & "0";
            when others => ALUResAux <= (others => '0');
         end case;
    when "011" => -- SRL
        case sa is
            when '0' => ALUResAux <= ALUIn2;
            when '1' => ALUResAux <= "0" & ALUIn2(15 downto 1);
            when others => ALUResAux <= (others => '0');
        end case;
    when "100" => -- AND
        ALUResAux<=RD1 and ALUIn2;		
    when "101" => -- OR
        ALUResAux<=RD1 or ALUIn2; 
    when "110" => -- XOR
        ALUResAux<=RD1 xor ALUIn2;		
    when "111" => -- SLT
        if signed(RD1) < signed(ALUIn2) then
            ALUResAux <= X"0001";
        else 
            ALUResAux <= X"0000";
        end if;
    when others => 
        ALUResAux <= (others => '0');              
end case;

zero_detecter:case ALUResAux is
    when X"0000" => Zero <= '1';
    when others => Zero <= '0';
end case;

end process;

RegDstMUX:process(RegDst)
begin
case RegDst is
when '0' => rWa <= rt;
when '1' => rWa <= rd;
when others => rWa <= (others => 'X');
end case;
end process;

ALURes <= ALUResAux;
BranchAddress <= PCinc + Ext_Imm;

end Behavioral;