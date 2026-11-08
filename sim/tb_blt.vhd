-- Testbench del programa 3: comparaciones con blt
-- Resultado: 4 si SW < 100, 5 si SW >= 100 (SW es siempre >= 0 con 9 bits)
-- Requiere compilar programs/mem_prog_3_blt.vhd como mem_prog
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_blt is
end;

architecture sim of tb_blt is
  component sistema
    port(clk, reset : in  STD_LOGIC;
         sw_i       : in  STD_LOGIC_VECTOR(8 downto 0);
         key_i      : in  STD_LOGIC_VECTOR(1 downto 0);
         hex_o      : out STD_LOGIC_VECTOR(15 downto 0);
         led_o      : out STD_LOGIC_VECTOR(9 downto 0));
  end component;

  constant T : time := 20 ns;
  signal clk, reset : STD_LOGIC := '0';
  signal sw_i  : STD_LOGIC_VECTOR(8 downto 0) := (others => '0');
  signal key_i : STD_LOGIC_VECTOR(1 downto 0) := "11";
  signal hex_o : STD_LOGIC_VECTOR(15 downto 0);
  signal led_o : STD_LOGIC_VECTOR(9 downto 0);
  signal fin   : boolean := false;
begin
  dut : sistema port map(clk, reset, sw_i, key_i, hex_o, led_o);

  reloj : process
  begin
    while not fin loop
      clk <= '0'; wait for T/2;
      clk <= '1'; wait for T/2;
    end loop;
    wait;
  end process;

  estimulo : process
    variable errores : integer := 0;
    variable esp     : integer;

    procedure prueba(n : integer) is
    begin
      sw_i  <= STD_LOGIC_VECTOR(to_unsigned(n, 9));
      reset <= '1';
      wait for 2*T;
      reset <= '0';
      wait for 50*T;

      if n < 100 then esp := 4; else esp := 5; end if;

      if hex_o /= STD_LOGIC_VECTOR(to_unsigned(esp, 16)) or
         led_o /= STD_LOGIC_VECTOR(to_unsigned(esp, 10)) then
        errores := errores + 1;
        report "FALLO SW=" & integer'image(n) &
               " HEX=" & integer'image(to_integer(unsigned(hex_o))) &
               " LED=" & integer'image(to_integer(unsigned(led_o))) &
               " (esperado " & integer'image(esp) & ")"
          severity error;
      else
        report "OK    SW=" & integer'image(n) & " -> " & integer'image(esp);
      end if;
    end procedure;
  begin
    -- se alternan resultados 4 y 5 para detectar valores "viejos"
    prueba(0);      -- 4
    prueba(100);    -- 5  (frontera)
    prueba(99);     -- 4  (frontera)
    prueba(511);    -- 5
    prueba(1);      -- 4
    prueba(101);    -- 5
    prueba(50);     -- 4
    prueba(255);    -- 5

    if errores = 0 then
      report "TODAS LAS PRUEBAS PASARON (blt)";
    else
      report integer'image(errores) & " PRUEBA(S) FALLARON (blt)" severity error;
    end if;
    fin <= true;
    wait;
  end process;
end;
