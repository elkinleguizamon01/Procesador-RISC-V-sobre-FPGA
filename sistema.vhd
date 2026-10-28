library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity sistema is
  port(clk, reset : in  STD_LOGIC;
       sw_i       : in  STD_LOGIC_VECTOR(8 downto 0);
       key_i      : in  STD_LOGIC_VECTOR(1 downto 0);
       hex_o      : out STD_LOGIC_VECTOR(15 downto 0);
       led_o      : out STD_LOGIC_VECTOR(9 downto 0));
end;

architecture struct of sistema is
  component riscvsingle
    port(clk, reset           : in  STD_LOGIC;
         PC                   : out STD_LOGIC_VECTOR(31 downto 0);
         Instr                : in  STD_LOGIC_VECTOR(31 downto 0);
         MemWrite             : out STD_LOGIC;
         ALUResult, WriteData : out STD_LOGIC_VECTOR(31 downto 0);
         ReadData             : in  STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component mem_prog
    port(a  : in  STD_LOGIC_VECTOR(31 downto 0);
         rd : out STD_LOGIC_VECTOR(31 downto 0));
  end component;
  component mem_datos
    port(clk, we : in  STD_LOGIC;
         a, wd   : in  STD_LOGIC_VECTOR(31 downto 0);
         rd      : out STD_LOGIC_VECTOR(31 downto 0);
         sw_i    : in  STD_LOGIC_VECTOR(8 downto 0);
         key_i   : in  STD_LOGIC_VECTOR(1 downto 0);
         hex_o   : out STD_LOGIC_VECTOR(15 downto 0);
         led_o   : out STD_LOGIC_VECTOR(9 downto 0));
  end component;

  signal PC, Instr, ReadData, DataAdr, WriteData : STD_LOGIC_VECTOR(31 downto 0);
  signal MemWrite : STD_LOGIC;
begin
  cpu : riscvsingle port map(
          clk       => clk,
          reset     => reset,
          PC        => PC,
          Instr     => Instr,       -- sale de mem_prog
          MemWrite  => MemWrite,
          ALUResult => DataAdr,
          WriteData => WriteData,
          ReadData  => ReadData);   -- sale de mem_datos

  prog : mem_prog port map(
          a  => PC,
          rd => Instr);

  dato : mem_datos port map(
          clk   => clk,
          we    => MemWrite,        -- la genera la unidad de control
          a     => DataAdr,
          wd    => WriteData,
          rd    => ReadData,
          sw_i  => sw_i,
          key_i => key_i,
          hex_o => hex_o,
          led_o => led_o);
end;
