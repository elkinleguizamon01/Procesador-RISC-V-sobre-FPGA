library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.all;

entity mem_datos is
  port(clk, we : in  STD_LOGIC;
       a, wd   : in  STD_LOGIC_VECTOR(31 downto 0);
       rd      : out STD_LOGIC_VECTOR(31 downto 0);
       sw_i    : in  STD_LOGIC_VECTOR(8 downto 0);
       key_i   : in  STD_LOGIC_VECTOR(1 downto 0);
       hex_o   : out STD_LOGIC_VECTOR(15 downto 0);
       led_o   : out STD_LOGIC_VECTOR(9 downto 0));
end;

architecture behave of mem_datos is
  constant DIR_SW  : integer := 50;   -- 200 / 4
  constant DIR_KEY : integer := 51;   -- 204 / 4
  constant DIR_HEX : integer := 52;   -- 208 / 4
  constant DIR_LED : integer := 53;   -- 212 / 4

  type ramtype is array(0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
  signal mem   : ramtype := (others => (others => '0'));
  signal hex_r : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal led_r : STD_LOGIC_VECTOR(9 downto 0)  := (others => '0');
  signal wa    : integer range 0 to 63;
begin
  wa <= to_integer(unsigned(a(7 downto 2)));

  -- lectura combinacional con los dispositivos superpuestos
  rd <= (31 downto  9 => '0') & sw_i  when wa = DIR_SW  else
        (31 downto  2 => '0') & key_i when wa = DIR_KEY else
        mem(wa);

  escritura : process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        mem(wa) <= wd;
        if    wa = DIR_HEX then hex_r <= wd(15 downto 0);
        elsif wa = DIR_LED then led_r <= wd(9 downto 0);
        end if;
      end if;
    end if;
  end process;

  hex_o <= hex_r;
  led_o <= led_r;
end;
