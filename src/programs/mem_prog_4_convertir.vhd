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
     1 => X"00000F13",   -- addi t5, zero, 0
     2 => X"06400393",   -- addi t2, zero, 100
     3 => X"0072C863",   -- blt  t0, t2, pasar
     4 => X"F9C28293",   -- addi t0, t0, -100
     5 => X"100F0F13",   -- addi t5, t5, 256
     6 => X"FF5FF06F",   -- j    centenas
     7 => X"00A00393",   -- addi t2, zero, 10
     8 => X"0072C863",   -- blt  t0, t2, unidades
     9 => X"FF628293",   -- addi t0, t0, -10
    10 => X"010F0F13",   -- addi t5, t5, 16
    11 => X"FF5FF06F",   -- j    decenas
    12 => X"005F0F33",   -- add  t5, t5, t0
    13 => X"0DE02823",   -- sw   t5, 208(zero)
    14 => X"0DE02A23",   -- sw   t5, 212(zero)
    15 => X"0000006F",   -- j    alto
    others => X"00000000");
begin
  rd <= mem(to_integer(unsigned(a(7 downto 2))));
end;