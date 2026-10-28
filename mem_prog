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
     1 => X"00000313",   -- addi t1, zero, 0
     2 => X"00000393",   -- addi t2, zero, 0
     3 => X"00538863",   -- beq  t2, t0, fin
     4 => X"00138393",   -- addi t2, t2, 1
     5 => X"00730333",   -- add  t1, t1, t2
     6 => X"FF5FF06F",   -- j    bucle
     7 => X"0C602823",   -- sw   t1, 208(zero)
     8 => X"0C602A23",   -- sw   t1, 212(zero)
     9 => X"0000006F",   -- j    alto
    others => X"00000000");
begin
  rd <= mem(to_integer(unsigned(a(7 downto 2))));
end;
