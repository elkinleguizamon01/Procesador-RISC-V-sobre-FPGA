-- Testbench del programa 2: (SW xor 15) xor 496 = SW xor 0x1FF
-- Requiere compilar programs/mem_prog_2_xor.vhd como mem_prog
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_xor is
end;

architecture sim of tb_xor is
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
    variable esp_hex : STD_LOGIC_VECTOR(15 downto 0);
    variable esp_led : STD_LOGIC_VECTOR(9 downto 0);

    procedure prueba(n : integer) is
    begin
      sw_i  <= STD_LOGIC_VECTOR(to_unsigned(n, 9));
      reset <= '1';
      wait for 2*T;
      reset <= '0';
      wait for 50*T;

      esp     := to_integer(to_unsigned(n, 9) xor to_unsigned(511, 9));
      esp_hex := STD_LOGIC_VECTOR(to_unsigned(esp, 16));
      esp_led := STD_LOGIC_VECTOR(to_unsigned(esp, 10));

      if hex_o /= esp_hex or led_o /= esp_led then
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
    prueba(0);      -- 511
    prueba(511);    -- 0
    prueba(15);     -- 496
    prueba(1);      -- 510
    prueba(100);    -- 411
    prueba(256);    -- 255
    prueba(341);    -- 170 (0x155 -> 0x0AA)
    prueba(170);    -- 341

    if errores = 0 then
      report "TODAS LAS PRUEBAS PASARON (xor)";
    else
      report integer'image(errores) & " PRUEBA(S) FALLARON (xor)" severity error;
    end if;
    fin <= true;
    wait;
  end process;
end;
