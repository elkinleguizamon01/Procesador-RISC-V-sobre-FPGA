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
     1 => X"06400313",   -- addi t1, zero, 100
     2 => X"FFF00393",   -- addi t2, zero, -1
     3 => X"00000E13",   -- addi t3, zero, 0
     4 => X"0062C463",   -- blt  t0, t1, a
     5 => X"001E0E13",   -- addi t3, t3, 1
     6 => X"0053C463",   -- blt  t2, t0, b
     7 => X"002E0E13",   -- addi t3, t3, 2
     8 => X"0072C463",   -- blt  t0, t2, c
     9 => X"004E0E13",   -- addi t3, t3, 4
    10 => X"0DC02823",   -- sw   t3, 208(zero)
    11 => X"0DC02A23",   -- sw   t3, 212(zero)
    12 => X"0000006F",   -- j    alto
    others => X"00000000");
begin
  rd <= mem(to_integer(unsigned(a(7 downto 2))));
end;