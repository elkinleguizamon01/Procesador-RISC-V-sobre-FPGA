library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity divisor is
  generic(DIV : positive := 5000000);        -- 50 MHz / 5e6 = 10 Hz
  port(clk50 : in  STD_LOGIC;
       modo  : in  STD_LOGIC;
       paso  : in  STD_LOGIC;                -- pulsador, activo en bajo
       clkp  : out STD_LOGIC);
end;

architecture behave of divisor is
  signal cuenta : unsigned(31 downto 0) := (others => '0');
  signal lento  : STD_LOGIC := '0';
  signal f1, f2 : STD_LOGIC := '1';
  signal anti   : unsigned(19 downto 0) := (others => '0');
  signal estable, previo, pulso : STD_LOGIC := '1';
begin
  reloj_lento : process(clk50)
  begin
    if rising_edge(clk50) then
      if cuenta = DIV-1 then cuenta <= (others => '0'); lento <= not lento;
      else cuenta <= cuenta + 1;
      end if;
    end if;
  end process;

  antirrebote : process(clk50)
  begin
    if rising_edge(clk50) then
      f1 <= paso;  f2 <= f1;
      if f2 /= estable then
        anti <= anti + 1;
        if anti = (anti'range => '1') then estable <= f2; end if;
      else
        anti <= (others => '0');
      end if;
      previo <= estable;
      pulso  <= (not estable) and previo;     -- un ciclo por pulsacion
    end if;
  end process;

  clkp <= lento when modo = '1' else pulso;
end;
