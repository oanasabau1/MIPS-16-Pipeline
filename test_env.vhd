library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
 Port (clk : in STD_LOGIC;
       btn : in STD_LOGIC_VECTOR (4 downto 0); 
       sw : in STD_LOGIC_VECTOR (15 downto 0);
       led : out STD_LOGIC_VECTOR (15 downto 0);
       an : out STD_LOGIC_VECTOR (3 downto 0);
       cat : out STD_LOGIC_VECTOR (6 downto 0));  
end test_env;

architecture Behavioral of test_env is

component MPG is 
Port (clk : in STD_LOGIC;
      btn : in STD_LOGIC;
      en : out STD_LOGIC);
end component MPG;

component InstructionFetch is
Port (clk: in STD_LOGIC;
      rst : in STD_LOGIC;
      en : in STD_LOGIC;
      BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
      JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
      Jump : in STD_LOGIC;
      PCSrc : in STD_LOGIC;
      Instruction : out STD_LOGIC_VECTOR(15 downto 0);
      PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end component InstructionFetch;

component InstructionDecode is
Port (clk: in STD_LOGIC;
      en : in STD_LOGIC;    
      Instr : in STD_LOGIC_VECTOR(12 downto 0);
      WD : in STD_LOGIC_VECTOR(15 downto 0);
      WA : in STD_LOGIC_VECTOR(2 downto 0);
      RegWrite : in STD_LOGIC;
      ExtOp : in STD_LOGIC;
      RD1 : out STD_LOGIC_VECTOR(15 downto 0);
      RD2 : out STD_LOGIC_VECTOR(15 downto 0);
      Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
      func : out STD_LOGIC_VECTOR(2 downto 0);
      sa : out STD_LOGIC;
      rt : out STD_LOGIC_VECTOR(2 downto 0);
      rd : out STD_LOGIC_VECTOR(2 downto 0));
end component InstructionDecode;

component MainControl is
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
end component MainControl;

component ExecutionUnit is
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
end component ExecutionUnit;

component MEM is
port (clk : in STD_LOGIC;
      en : in STD_LOGIC;
      ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
      RD2 : in STD_LOGIC_VECTOR(15 downto 0);
      MemWrite : in STD_LOGIC;			
      MemData : out STD_LOGIC_VECTOR(15 downto 0);
      ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component MEM;

component SSD is
Port (clk : in STD_LOGIC;
      digits : in STD_LOGIC_VECTOR (15 downto 0);
      cat : out STD_LOGIC_VECTOR (6 downto 0);
      an : out STD_LOGIC_VECTOR (3 downto 0));
end component SSD;

signal Instruction, PCinc, RD1, RD2, WD, Ext_imm: STD_LOGIC_VECTOR(15 downto 0);
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData: STD_LOGIC_VECTOR(15 downto 0);
signal rt, rd, func, rWA : STD_LOGIC_VECTOR(2 downto 0);
signal sa, zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(15 downto 0);
signal en, rst, PCSrc : STD_LOGIC;
--main controls
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);

--pipeline registers 
--IF_ID
signal PCinc_IF_ID, Instruction_IF_ID : STD_LOGIC_VECTOR(15 downto 0);
--ID_EX
signal PCInc_ID_EX, RD1_ID_EX, RD2_ID_EX, Ext_imm_ID_EX : STD_LOGIC_VECTOR(15 downto 0);
signal func_ID_EX, rt_ID_EX, rd_ID_EX, ALUOp_ID_EX : STD_LOGIC_VECTOR(2 downto 0);
signal sa_ID_EX, MemToReg_ID_EX, RegWrite_ID_EX, MemWrite_ID_EX, Branch_ID_EX, ALUSrc_ID_EX, RegDst_ID_EX : STD_LOGIC;
--EX_MEM
signal BranchAddress_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM : STD_LOGIC_VECTOR(15 downto 0);
signal rd_EX_MEM : STD_LOGIC_VECTOR(2 downto 0);
signal zero_EX_MEM, MemToReg_EX_MEM, RegWrite_EX_MEM, MemWrite_EX_MEM, Branch_EX_MEM : STD_LOGIC;
--MEM_WB
signal MemData_MEM_WB, ALURes_MEM_WB : STD_LOGIC_VECTOR(15 downto 0);
signal rd_MEM_WB : STD_LOGIC_VECTOR(2 downto 0);
signal MemToReg_MEM_WB, RegWrite_MEM_WB : STD_LOGIC;

begin

--buttons: reset, enable
monopulse1: MPG port map(clk=>clk, btn=>btn(0), en=>en);
monopulse2: MPG port map(clk=>clk, btn=>btn(1), en=>rst);

--main unit
instr_fetch: InstructionFetch port map(clk=>clk, rst=>rst, en=>en, BranchAddress=>BranchAddress_EX_MEM, JumpAddress=>JumpAddress, 
                                       Jump=>Jump, PCSrc=>PCSrc, Instruction=>Instruction, PCinc=>PCinc);
instr_decode: InstructionDecode port map(clk=>clk, en=>en, Instr=>Instruction_IF_ID(12 downto 0), WD=>WD, WA=>rd_MEM_WB,
                                         RegWrite=>RegWrite_MEM_WB, ExtOp=>ExtOp, RD1=>RD1, RD2=>RD2,
                                         Ext_imm=>Ext_imm, func=>func, sa=>sa, rt=>rt, rd=>rd);
instr_mainControl: MainControl port map(Instr=>Instruction_IF_ID(15 downto 13), RegDst=>RegDst, ExtOp=>ExtOp, ALUSrc=>ALUSrc,
                                        Branch=>Branch, Jump=>Jump, ALUOp=>ALUOp,
                                        MemWrite=>MemWrite, MemtoReg=>MemtoReg, RegWrite=>RegWrite);
instr_execute: ExecutionUnit port map(PCinc=>PCinc_ID_EX, RD1=>RD1_ID_EX, RD2=>RD2_ID_EX, Ext_imm=>Ext_imm_ID_EX, func=>func_ID_EX,
                                      sa=>sa_ID_EX, rt=>rt_ID_EX, rd=>rd_ID_EX, RegDst=>RegDst_ID_EX, ALUSrc=>ALUSrc_ID_EX, 
                                      ALUOp=>ALUOp_ID_EX, BranchAddress=>BranchAddress, ALURes=>ALURes, Zero=>Zero, rWa=>rWa);
instr_MEM: MEM port map(clk=>clk, en=>en, ALUResIn=>ALURes_EX_MEM, RD2=>RD2_EX_MEM, MemWrite=>MemWrite_EX_MEM, MemData=>MemData, ALUResOut=>ALURes1);
                                      
--branch control
PCSrc <= Zero_EX_MEM and Branch_EX_MEM;

--jump address
JumpAddress <= PCinc_IF_ID(15 downto 13) & Instruction_IF_ID(12 downto 0);
      
--WriteBack unit 
with MemtoReg_MEM_WB select 
WD <= MemData_MEM_WB when '1',
ALURes_MEM_WB when '0',
(others=>'X') when others;

--pipeline registers
D_register:process(clk)
begin
if rising_edge(clk) then
if en='1' then 
--IF_ID
PCinc_IF_ID <=PCinc;
Instruction_IF_ID <= Instruction;
--ID_EX
PCinc_ID_EX <= PCinc_IF_ID;
RD1_ID_EX <= RD1;
RD2_ID_EX <= RD2;
Ext_imm_ID_EX <= Ext_imm;
sa_ID_EX <= sa;
func_ID_EX <= func;
rt_ID_EX <= rt;
rd_ID_EX <= rd;
MemtoReg_ID_EX <= MemtoReg;
RegWrite_ID_EX <= RegWrite;
MemWrite_ID_EX <= MemWrite;
Branch_ID_EX <= Branch;
ALUSrc_ID_EX <= ALUSrc;
ALUOp_ID_EX <= ALUOp;
RegDst_ID_EX <= RegDst;
--EX_MEM
BranchAddress_EX_MEM <= BranchAddress;
Zero_EX_MEM <= Zero;
ALURes_EX_MEM <= ALURes;
RD2_EX_MEM <= RD2_ID_EX;
rd_EX_MEM <= rWa;
MemtoReg_EX_MEM <= MemtoReg_ID_EX;
RegWrite_EX_MEM <= RegWrite_ID_EX;
MemWrite_EX_MEM <= MemWrite_ID_EX;
Branch_EX_MEM <= Branch_ID_EX;
--MEM_WB
MemData_MEM_WB <= MemData;
ALURes_MEM_WB <= ALURes1;
rd_MEM_WB <= rd_EX_MEM;
MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
RegWrite_MEM_WB <= RegWrite_EX_MEM;
end if;
end if;
end process;
                                       
--SSD display MUX
with sw(7 downto 5) select 
digits <= Instruction when "000",
          PCinc when "001",
          RD1_ID_EX when "010",
          RD2_ID_EX when "011",
          Ext_Imm_ID_EX when "100",
          ALURes when "101",
          MemData when "110",
          WD when "111",
          (others => 'X') when others;
    
display: SSD port map(clk=>clk, digits=>digits, an=>an, cat=>cat);

--main controls on the leds
led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;