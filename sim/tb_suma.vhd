-- Testbench del programa 1: suma 1..N (N = SW)
-- Requiere compilar programs/mem_prog_1_suma.vhd como mem_prog
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity tb_suma is
end;

architecture sim of tb_suma is
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
      wait for 2500*T;                       -- el bucle tarda ~4*N ciclos

      esp     := n*(n+1)/2;
      esp_hex := STD_LOGIC_VECTOR(to_unsigned(esp mod 65536, 16));
      esp_led := STD_LOGIC_VECTOR(to_unsigned(esp mod 1024, 10));

      if hex_o /= esp_hex or led_o /= esp_led then
        errores := errores + 1;
        report "FALLO N=" & integer'image(n) &
               " HEX=" & integer'image(to_integer(unsigned(hex_o))) &
               " (esperado " & integer'image(esp mod 65536) & ")" &
               " LED=" & integer'image(to_integer(unsigned(led_o))) &
               " (esperado " & integer'image(esp mod 1024) & ")"
          severity error;
      else
        report "OK    N=" & integer'image(n) & " suma=" & integer'image(esp);
      end if;
    end procedure;
  begin
    prueba(5);      -- 15
    prueba(0);      -- 0
    prueba(1);      -- 1
    prueba(10);     -- 55
    prueba(100);    -- 5050
    prueba(255);    -- 32640
    prueba(511);    -- 130816 (HEX muestra los 16 bits bajos)

    if errores = 0 then
      report "TODAS LAS PRUEBAS PASARON (suma)";
    else
      report integer'image(errores) & " PRUEBA(S) FALLARON (suma)" severity error;
    end if;
    fin <= true;
    wait;
  end process;
end;
