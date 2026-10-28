library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity mux2 is -- two-input multiplexer
  generic(width: integer :=8);
  port(d0, d1: in  STD_LOGIC_VECTOR(width-1 downto 0);
       s:      in  STD_LOGIC;
       y:      out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of mux2 is
begin
  y <= d1 when s='1' else d0;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity mux3 is -- three-input multiplexer
  generic(width: integer :=8);
  port(d0, d1, d2: in  STD_LOGIC_VECTOR(width-1 downto 0);
       s:          in  STD_LOGIC_VECTOR(1 downto 0);
       y:          out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture behave of mux3 is
begin
  process(d0, d1, d2, s) begin
    if    (s = "00") then y <= d0;
    elsif (s = "01") then y <= d1;
    elsif (s = "10") then y <= d2;
    end if;
  end process;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;
use IEEE.NUMERIC_STD.all;

entity flopr is -- flip-flop with synchronous reset
  generic(width: integer);
  port(clk, reset: in  STD_LOGIC;
       d:          in  STD_LOGIC_VECTOR(width-1 downto 0);
       q:          out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture asynchronous of flopr is
begin
  process(clk, reset) begin
    if reset='1' then           q <= (others => '0');
    elsif rising_edge(clk) then q <= d;
    end if;
  end process;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;
use IEEE.NUMERIC_STD.all;

entity flopenr is
  generic(width: integer); -- flip-flop with synchronous reset and enable
  port(clk, reset, en: in  STD_LOGIC;
       d:              in  STD_LOGIC_VECTOR(width-1 downto 0);
       q:              out STD_LOGIC_VECTOR(width-1 downto 0));
end;

architecture asynchronous of flopenr is
begin
  process(clk, reset, en) begin
    if reset='1' then                      q <= (others => '0');
    elsif rising_edge(clk) and en='1' then q <= d;
    end if;
  end process;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;
use IEEE.NUMERIC_STD.all;

entity adder is -- adder
  port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
       y:    out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of adder is
begin
  y <= std_logic_vector(unsigned(a) + unsigned(b));
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity extend is -- extend unit
  port(instr:  in  STD_LOGIC_VECTOR(31 downto 7);
    immsrc: in  STD_LOGIC_VECTOR(1  downto 0);
    immext: out STD_LOGIC_VECTOR(31 downto 0));
end;
    
architecture behave of extend is
begin
  process(instr, immsrc) begin
    case immsrc is
      -- I-type
      when "00" =>
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 20);
      -- S-types (stores)
      when "01" =>
        immext <= (31 downto 12 => instr(31)) & instr(31 downto 25) & instr(11 downto 7);
      -- B-type (branches)
      when "10" =>
        immext <= (31 downto 12 => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
      -- J-type (jal)
      when "11" =>
        immext <= (31 downto 20 => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
      when others =>
        immext <= (31 downto 0 => '-');
    end case;
  end process;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;
use IEEE.NUMERIC_STD.all;

entity regfile is -- three-port register file
  port(clk:        in  STD_LOGIC;
       we3:        in  STD_LOGIC;
       a1, a2, a3: in  STD_LOGIC_VECTOR(4  downto 0);
       wd3:        in  STD_LOGIC_VECTOR(31 downto 0);
       rd1, rd2:   out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of regfile is
  type ramtype is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem: ramtype;
begin
  -- three ported register file
  -- read two ports combinationally (A1/RD1, A2/RD2)
  -- write third port on rising edge of clock (A3/WD3/WE3)
  -- register 0 hardwired to 0
  process(clk) begin
    if rising_edge(clk) then
      if we3='1' then mem(to_integer(unsigned(a3))) <= wd3;
      end if;
    end if;
  end process;
  process(a1, a2, mem) begin   -- mem anadida: el original solo tenia a1 y a2
    if (to_integer(unsigned(a1))=0) then rd1 <= X"00000000";
    else rd1 <= mem(to_integer(unsigned(a1)));
    end if;
    if (to_integer(unsigned(a2))=0) then rd2 <= X"00000000";
    else rd2 <= mem(to_integer(unsigned(a2)));
    end if;
  end process;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;
use IEEE.NUMERIC_STD.all;

entity alu is
  port(a, b:       in     STD_LOGIC_VECTOR(31 downto 0);
       ALUControl: in     STD_LOGIC_VECTOR(2  downto 0);
       ALUResult:  out    STD_LOGIC_VECTOR(31 downto 0);
       Zero:       out    STD_LOGIC);
end;

architecture behave of alu is
  signal condinvb, sum: STD_LOGIC_VECTOR(31 downto 0);
  signal v, isAddSub: STD_LOGIC;
  signal ALUResulti: STD_LOGIC_VECTOR(31 downto 0);
  signal cin: UNSIGNED(31 downto 0);
begin
  ALUResult <= ALUResulti;
  condinvb <= not b when Alucontrol(0)='1' else b;
  cin <= (0 => Alucontrol(0), others => '0');
  sum <= std_logic_vector(unsigned(a) + unsigned(condinvb) + cin);
  isAddSub <= (not ALUControl(2) and not ALUControl(1)) or
              (not ALUControl(1) and     ALUControl(0));
             
  process(a, b, ALUControl, sum, v) begin   -- v anadida: el original no la tenia
    case Alucontrol is
      when "000"  => ALUResulti <= sum;
      when "001"  => ALUResulti <= sum;
      when "010"  => ALUResulti <= a and b;
      when "011"  => ALUResulti <= a or b;         
      when "101"  => ALUResulti <= (0 => (sum(31) xor v), others => '0');
      when others => ALUResulti <= (others => 'X');
    end case;
  end process;
  
  Zero <= '1' when ALUResulti = X"00000000" else '0';
  v <= not(ALUControl(0) xor a(31) xor b(31)) and (a(31) xor sum(31)) and isAddSub;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity maindec is -- main control decoder
  port(op:             in  STD_LOGIC_VECTOR(6 downto 0);
       ResultSrc:      out STD_LOGIC_VECTOR(1 downto 0);
       MemWrite:       out STD_LOGIC;
       Branch, ALUSrc: out STD_LOGIC;
       RegWrite, Jump: out STD_LOGIC;
       ImmSrc:         out STD_LOGIC_VECTOR(1 downto 0);
       ALUOp:          out STD_LOGIC_VECTOR(1 downto 0));
end;

architecture behave of maindec is
  signal controls: STD_LOGIC_VECTOR(10 downto 0);
begin
  process(op) begin
    case op is
      when "0000011" => controls <= "10010010000"; -- lw
      when "0100011" => controls <= "00111000000"; -- sw
      when "0110011" => controls <= "1--00000100"; -- R-type
      when "1100011" => controls <= "01000001010"; -- beq
      when "0010011" => controls <= "10010000100"; -- I-type ALU
      when "1101111" => controls <= "11100100001"; -- jal
      when others    => controls <= "-----------"; -- not valid
    end case;
  end process;

  (RegWrite, ImmSrc(1), ImmSrc(0), ALUSrc, MemWrite,
   ResultSrc(1), ResultSrc(0), Branch, ALUOp(1), ALUOp(0), Jump) <= controls;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity aludec is -- ALU control decoder
  port(opb5:       in  STD_LOGIC;
       funct3:     in  STD_LOGIC_VECTOR(2 downto 0);
       funct7b5:   in  STD_LOGIC;
       ALUOp:      in  STD_LOGIC_VECTOR(1 downto 0);
       ALUControl: out STD_LOGIC_VECTOR(2 downto 0));
end;

architecture behave of aludec is
  signal RtypeSub: STD_LOGIC;
begin
  RtypeSub <= funct7b5 and opb5; -- TRUE for R-type subtract
  process(opb5, funct3, funct7b5, ALUOp, RtypeSub) begin
    case ALUOp is
      when "00" =>                     ALUControl <= "000"; -- addition
      when "01" =>                     ALUControl <= "001"; -- subtraction
      when others => case funct3 is           -- R-type or I-type ALU
                       when "000" => if RtypeSub = '1' then
                                       ALUControl <= "001"; -- sub
                                     else
                                       ALUControl <= "000"; -- add, addi
                                     end if;
                       when "010" =>   ALUControl <= "101"; -- slt, slti
                       when "110" =>   ALUControl <= "011"; -- or, ori
                       when "111" =>   ALUControl <= "010"; -- and, andi
                       when others =>  ALUControl <= "---"; -- unknown
                     end case;
    end case;
  end process;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;
use IEEE.NUMERIC_STD.all;

entity datapath is -- RISC-V datapath
  port(clk, reset:           in     STD_LOGIC;
       ResultSrc:            in     STD_LOGIC_VECTOR(1  downto 0);
       PCSrc, ALUSrc:        in     STD_LOGIC;
       RegWrite:             in     STD_LOGIC;
       ImmSrc:               in     STD_LOGIC_VECTOR(1  downto 0);
       ALUControl:           in     STD_LOGIC_VECTOR(2  downto 0);
       Zero:                 out    STD_LOGIC;
       PC:                   out    STD_LOGIC_VECTOR(31 downto 0);
       Instr:                in     STD_LOGIC_VECTOR(31 downto 0);
       ALUResult, WriteData: out    STD_LOGIC_VECTOR(31 downto 0);
       ReadData:             in     STD_LOGIC_VECTOR(31 downto 0));
end;

architecture struct of datapath is
  component flopr generic(width: integer);
    port(clk, reset: in  STD_LOGIC;
         d:          in  STD_LOGIC_VECTOR(width-1 downto 0);
         q:          out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;
  component adder
    port(a, b: in  STD_LOGIC_VECTOR(31 downto 0);
         y:    out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component mux2 generic(width: integer);
    port(d0, d1: in  STD_LOGIC_VECTOR(width-1 downto 0);
         s:      in  STD_LOGIC;
         y:      out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;
  component mux3 generic(width: integer);
    port(d0, d1, d2: in  STD_LOGIC_VECTOR(width-1 downto 0);
         s:          in  STD_LOGIC_VECTOR(1 downto 0);
         y:          out STD_LOGIC_VECTOR(width-1 downto 0));
  end component;
  component regfile
    port(clk:        in  STD_LOGIC;
         we3:        in  STD_LOGIC;
         a1, a2, a3: in  STD_LOGIC_VECTOR(4  downto 0);
         wd3:        in  STD_LOGIC_VECTOR(31 downto 0);
         rd1, rd2:   out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component extend
    port(instr:  in  STD_LOGIC_VECTOR(31 downto 7);
         immsrc: in  STD_LOGIC_VECTOR(1  downto 0);
         immext: out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component alu
    port(a, b:       in     STD_LOGIC_VECTOR(31 downto 0);
         ALUControl: in     STD_LOGIC_VECTOR(2  downto 0);
         ALUResult:  out    STD_LOGIC_VECTOR(31 downto 0);
         Zero:       out    STD_LOGIC);
  end component;
    
  signal PCNext, PCPlus4, PCTarget: STD_LOGIC_VECTOR(31 downto 0);
  signal ImmExt:                    STD_LOGIC_VECTOR(31 downto 0);
  signal SrcA, SrcB:                STD_LOGIC_VECTOR(31 downto 0);
  signal Result:                    STD_LOGIC_VECTOR(31 downto 0);
  signal PCi, ALUResulti, WriteDatai: STD_LOGIC_VECTOR(31 downto 0);
begin
  PC <= PCi;  ALUResult <= ALUResulti;  WriteData <= WriteDatai;

  -- next PC logic
  pcreg: flopr generic map(32) port map(clk, reset, PCNext, PCi);
  pcadd4: adder port map(PCi, X"00000004", PCPlus4);
  pcaddbranch: adder port map(PCi, ImmExt, PCTarget);
  pcmux: mux2 generic map(32) port map(PCPlus4, PCTarget, PCSrc, PCNext);
    
  -- register file logic
  rf: regfile port map(clk, RegWrite, Instr(19 downto 15), Instr(24 downto 20),
                         Instr(11 downto 7), Result, SrcA, WriteDatai);
  ext: extend port map(Instr(31 downto 7), ImmSrc, ImmExt);
    
  -- ALU logic
  srcbmux: mux2 generic map(32) port map(WriteDatai, ImmExt, ALUSrc, SrcB);
  mainalu: alu port map(SrcA, SrcB, ALUControl, ALUResulti, Zero);
  resultmux: mux3 generic map(32) port map(ALUResulti, ReadData, PCPlus4, ResultSrc,
                                           Result);
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity controller is -- single-cycle controller
  port(op:             in     STD_LOGIC_VECTOR(6 downto 0);
       funct3:         in     STD_LOGIC_VECTOR(2 downto 0);
       funct7b5, Zero: in     STD_LOGIC;
       ResultSrc:      out    STD_LOGIC_VECTOR(1 downto 0);
       MemWrite:       out    STD_LOGIC;
       PCSrc, ALUSrc:  out    STD_LOGIC;
       RegWrite:       out    STD_LOGIC;
       Jump:           out    STD_LOGIC;
       ImmSrc:         out    STD_LOGIC_VECTOR(1 downto 0);
       ALUControl:     out    STD_LOGIC_VECTOR(2 downto 0));
end;

architecture struct of controller is
  component maindec
    port(op:             in  STD_LOGIC_VECTOR(6 downto 0);
         ResultSrc:      out STD_LOGIC_VECTOR(1 downto 0);
         MemWrite:       out STD_LOGIC;
         Branch, ALUSrc: out STD_LOGIC;
         RegWrite, Jump: out STD_LOGIC;
         ImmSrc:         out STD_LOGIC_VECTOR(1 downto 0);
         ALUOp:          out STD_LOGIC_VECTOR(1 downto 0));
  end component;
  component aludec
    port(opb5:       in  STD_LOGIC;
         funct3:     in  STD_LOGIC_VECTOR(2 downto 0);
         funct7b5:   in  STD_LOGIC;
         ALUOp:      in  STD_LOGIC_VECTOR(1 downto 0);
         ALUControl: out STD_LOGIC_VECTOR(2 downto 0));
  end component;
  
  signal ALUOp:   STD_LOGIC_VECTOR(1 downto 0);
  signal Branch:  STD_LOGIC;
  signal JumpInt: STD_LOGIC;
begin
  md: maindec port map(op, ResultSrc, MemWrite, Branch,
                       ALUSrc, RegWrite, JumpInt, ImmSrc, ALUOp);
  ad: aludec port map(op(5), funct3, funct7b5, ALUOp, ALUControl);

  Jump  <= JumpInt;
  PCSrc <= (Branch and Zero) or JumpInt;
end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity riscvsingle is -- single cycle RISC-V processor
  port(clk, reset:           in  STD_LOGIC;
       PC:                   out STD_LOGIC_VECTOR(31 downto 0);
       Instr:                in  STD_LOGIC_VECTOR(31 downto 0);
       MemWrite:             out STD_LOGIC;
       ALUResult, WriteData: out STD_LOGIC_VECTOR(31 downto 0);
       ReadData:             in  STD_LOGIC_VECTOR(31 downto 0));
end;

architecture struct of riscvsingle is
  component controller
    port(op:             in  STD_LOGIC_VECTOR(6 downto 0);
         funct3:         in  STD_LOGIC_VECTOR(2 downto 0);
         funct7b5, Zero: in  STD_LOGIC;
         ResultSrc:      out STD_LOGIC_VECTOR(1 downto 0);
         MemWrite:       out STD_LOGIC;
         PCSrc, ALUSrc:  out STD_LOGIC;
         RegWrite, Jump: out STD_LOGIC;
         ImmSrc:         out STD_LOGIC_VECTOR(1 downto 0);
         ALUControl:     out STD_LOGIC_VECTOR(2 downto 0));
  end component;
  component datapath
    port(clk, reset:           in  STD_LOGIC;
         ResultSrc:            in  STD_LOGIC_VECTOR(1  downto 0);
         PCSrc, ALUSrc:        in  STD_LOGIC;
         RegWrite:             in  STD_LOGIC;
         ImmSrc:               in  STD_LOGIC_VECTOR(1  downto 0);
         ALUControl:           in  STD_LOGIC_VECTOR(2  downto 0);
         Zero:                 out STD_LOGIC;
         PC:                   out STD_LOGIC_VECTOR(31 downto 0);
         Instr:                in  STD_LOGIC_VECTOR(31 downto 0);
         ALUResult, WriteData: out STD_LOGIC_VECTOR(31 downto 0);
         ReadData:             in  STD_LOGIC_VECTOR(31 downto 0));
  end component;
    
  signal ALUSrc, RegWrite, Jump, Zero, PCSrc: STD_LOGIC;
  signal ResultSrc, ImmSrc: STD_LOGIC_VECTOR(1 downto 0);
  signal ALUControl: STD_LOGIC_VECTOR(2 downto 0);
begin
  c: controller port map(Instr(6 downto 0), Instr(14 downto 12),
                         Instr(30), Zero, ResultSrc, MemWrite,
                         PCSrc, ALUSrc, RegWrite, Jump,
                         ImmSrc, ALUControl);
  dp: datapath port map(clk, reset, ResultSrc, PCSrc, ALUSrc, 
                        RegWrite, ImmSrc, ALUControl, Zero, 
                        PC, Instr, ALUResult,  WriteData, 
                        ReadData);
end;
