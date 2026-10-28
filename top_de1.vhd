library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.all;

entity top_de1 is
  port(CLOCK_50 : in  STD_LOGIC;
       KEY      : in  STD_LOGIC_VECTOR(3 downto 0);
       SW       : in  STD_LOGIC_VECTOR(9 downto 0);
       LEDR     : out STD_LOGIC_VECTOR(9 downto 0);
       HEX0     : out STD_LOGIC_VECTOR(6 downto 0);
       HEX1     : out STD_LOGIC_VECTOR(6 downto 0);
       HEX2     : out STD_LOGIC_VECTOR(6 downto 0);
       HEX3     : out STD_LOGIC_VECTOR(6 downto 0));
end;

architecture struct of top_de1 is
  component divisor
    generic(DIV : positive);
    port(clk50, modo, paso : in STD_LOGIC; clkp : out STD_LOGIC);
  end component;
  component sistema
    port(clk, reset : in  STD_LOGIC;
         sw_i       : in  STD_LOGIC_VECTOR(8 downto 0);
         key_i      : in  STD_LOGIC_VECTOR(1 downto 0);
         hex_o      : out STD_LOGIC_VECTOR(15 downto 0);
         led_o      : out STD_LOGIC_VECTOR(9 downto 0));
  end component;
  component hex7seg
    port(d : in STD_LOGIC_VECTOR(3 downto 0); s : out STD_LOGIC_VECTOR(6 downto 0));
  end component;
  signal clkp  : STD_LOGIC;
  signal reset : STD_LOGIC;
  signal hex   : STD_LOGIC_VECTOR(15 downto 0);
begin
  reset <= not KEY(0);                       -- los pulsadores son activos en bajo

  div : divisor generic map(DIV => 5000000)  -- 10 Hz en modo automatico
                port map(CLOCK_50, SW(9), KEY(1), clkp);

  sis : sistema port map(clkp, reset, SW(8 downto 0), KEY(3 downto 2), hex, LEDR);

  d0 : hex7seg port map(hex( 3 downto  0), HEX0);
  d1 : hex7seg port map(hex( 7 downto  4), HEX1);
  d2 : hex7seg port map(hex(11 downto  8), HEX2);
  d3 : hex7seg port map(hex(15 downto 12), HEX3);
end;
