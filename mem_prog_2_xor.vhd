library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.all;

entity mem_prog is
  port(a  : in  STD_LOGIC_VECTOR(31 downto 0);
       rd : out STD_LOGIC_VECTOR(31 downto 0));
end;

architecture behave of mem_prog is
  type ramtype is array(0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
  constant mem : ramtype := (
     0 => X"0C802283",   -- lw   t0, 200(zero)
     1 => X"00F2C313",   -- xori t1, t0, 15
     2 => X"1F000393",   -- addi t2, zero, 496
     3 => X"00734E33",   -- xor  t3, t1, t2
     4 => X"0DC02823",   -- sw   t3, 208(zero)
     5 => X"0DC02A23",   -- sw   t3, 212(zero)
     6 => X"0000006F",   -- j    alto
    others => X"00000000");
begin
  rd <= mem(to_integer(unsigned(a(7 downto 2))));
end;