-- Testbench del programa 4: binario -> decimal (BCD)
-- HEX = centenas(11:8) decenas(7:4) unidades(3:0)
-- Requiere compilar programs/mem_prog_4_convertir.vhd como mem_prog
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_convertir is
end;

architecture sim of tb_convertir is
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
      wait for 300*T;                        -- peor caso: ~60 ciclos

      esp := (n / 100) * 256 + ((n mod 100) / 10) * 16 + (n mod 10);

      if hex_o /= STD_LOGIC_VECTOR(to_unsigned(esp, 16)) or
         led_o /= STD_LOGIC_VECTOR(to_unsigned(esp mod 1024, 10)) then
        errores := errores + 1;
        report "FALLO SW=" & integer'image(n) &
               " HEX=" & integer'image(to_integer(unsigned(hex_o))) &
               " LED=" & integer'image(to_integer(unsigned(led_o))) &
               " (esperado HEX=" & integer'image(esp) &
               " LED=" & integer'image(esp mod 1024) & ")"
          severity error;
      else
        report "OK    SW=" & integer'image(n) &
               " -> BCD 0x" & integer'image(esp);
      end if;
    end procedure;
  begin
    prueba(0);      -- 0x000
    prueba(7);      -- 0x007
    prueba(10);     -- 0x010
    prueba(59);     -- 0x059
    prueba(99);     -- 0x099
    prueba(100);    -- 0x100
    prueba(128);    -- 0x128
    prueba(255);    -- 0x255
    prueba(365);    -- 0x365
    prueba(511);    -- 0x511

    if errores = 0 then
      report "TODAS LAS PRUEBAS PASARON (convertir)";
    else
      report integer'image(errores) & " PRUEBA(S) FALLARON (convertir)" severity error;
    end if;
    fin <= true;
    wait;
  end process;
end;
