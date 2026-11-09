set -e
cd "$(dirname "$0")/.."

case "$1" in
  1) PROG=src/src/programs/mem_prog_1_suma.vhd;      TB=tb_suma ;;
  2) PROG=src/src/programs/mem_prog_2_xor.vhd;       TB=tb_xor ;;
  3) PROG=src/src/programs/mem_prog_3_blt.vhd;       TB=tb_blt ;;
  4) PROG=src/src/programs/mem_prog_4_convertir.vhd; TB=tb_convertir ;;
  *) echo "Uso: $0 1|2|3|4"; exit 1 ;;
esac

mkdir -p build
cd build
ghdl -a --std=08 ../src/riscvsingle.vhd ../src/mem_datos.vhd "../$PROG" \
                 ../src/sistema.vhd "../sim/$TB.vhd"
ghdl -e --std=08 "$TB"
ghdl -r --std=08 "$TB" --vcd="$TB.vcd"
echo "Forma de onda: build/$TB.vcd (abrir con GTKWave)"
