# Procesador RISC-V monociclo en FPGA (DE1)

Implementación en VHDL de un procesador **RISC-V de 32 bits monociclo** conectado a una memoria de programa, una memoria de datos y periféricos de la tarjeta **Terasic DE1** (interruptores, pulsadores, LEDs y displays de 7 segmentos). El procesador ejecuta pequeños programas en ensamblador RISC-V que leen los interruptores y muestran el resultado en los LEDs y en los displays.

## Características

- Procesador monociclo basado en el diseño de Harris & Harris (*Digital Design and Computer Architecture: RISC-V Edition*).
- Instrucciones soportadas:
  - Memoria: `lw`, `sw`
  - Tipo R: `add`, `sub`, `and`, `or`, `xor`, `slt`
  - Tipo I (ALU): `addi`, `andi`, `ori`, `xori`, `slti`
  - Saltos: `beq`, `blt`, `jal`
- ALU con operación XOR y comparación con signo (`slt`) para soportar `xor/xori` y `blt`.
- E/S mapeada en memoria (interruptores, pulsadores, display y LEDs).
- Divisor de reloj con dos modos: **automático** (reloj lento) y **paso a paso** (con pulsador antirrebote).
- Cuatro programas de ejemplo intercambiables.

## Estructura del repositorio

```
.
├── README.md
├── .gitignore
├── src/
│   ├── top_de1.vhd        # Top-level: conecta la tarjeta DE1 con el sistema
│   ├── divisor.vhd        # Divisor de reloj + antirrebote del pulsador
│   ├── hex7seg.vhd        # Decodificador hexadecimal a 7 segmentos
│   ├── sistema.vhd        # CPU + memoria de programa + memoria de datos
│   ├── riscvsingle.vhd    # Procesador (datapath, controlador, ALU, regfile, etc.)
│   ├── mem_datos.vhd      # Memoria de datos + periféricos mapeados
│   └── mem_prog.vhd       # Programa activo (copia de uno de programs/)
└── programs/
    ├── mem_prog_1_suma.vhd       # Suma 1..N
    ├── mem_prog_2_xor.vhd        # XOR con constantes
    ├── mem_prog_3_blt.vhd        # Comparaciones con blt
    └── mem_prog_4_convertir.vhd  # Binario a decimal (BCD)
```

> `riscvsingle.vhd` agrupa varias entidades: `mux2`, `mux3`, `flopr`, `flopenr`, `adder`, `extend`, `regfile`, `alu`, `maindec`, `aludec`, `datapath`, `controller` y `riscvsingle`.

## Jerarquía del diseño

```
top_de1
├── divisor        (reloj de 50 MHz -> clkp)
├── sistema
│   ├── riscvsingle
│   │   ├── controller (maindec + aludec)
│   │   └── datapath   (regfile, alu, extend, adders, muxes, PC)
│   ├── mem_prog       (ROM de instrucciones)
│   └── mem_datos      (RAM + periféricos)
└── hex7seg x4         (HEX0..HEX3)
```

## Controles de la tarjeta DE1

| Entrada | Función |
|---|---|
| `KEY0` | Reset (activo en bajo, internamente se invierte) |
| `KEY1` | Pulso de reloj en modo paso a paso (con antirrebote) |
| `KEY3..KEY2` | Entradas de pulsadores para el programa (dirección 204) |
| `SW8..SW0` | Dato de entrada para el programa (dirección 200) |
| `SW9` | Modo de reloj: `1` = automático, `0` = paso a paso con `KEY1` |
| `LEDR9..LEDR0` | Salida de LEDs (dirección 212) |
| `HEX3..HEX0` | Salida de 16 bits en hexadecimal (dirección 208) |

## Mapa de memoria

La memoria de datos tiene 64 palabras (se indexa con `a[7:2]`). Los periféricos están superpuestos a ella:

| Dirección (byte) | Índice de palabra | Periférico | Acceso |
|---|---|---|---|
| `200` (0xC8) | 50 | Interruptores `SW[8:0]` | Lectura |
| `204` (0xCC) | 51 | Pulsadores `KEY[3:2]` | Lectura |
| `208` (0xD0) | 52 | Displays HEX (16 bits) | Escritura |
| `212` (0xD4) | 53 | LEDs (10 bits) | Escritura |

## Programas de ejemplo

Solo puede estar compilado un `mem_prog` a la vez (todos tienen la entidad `mem_prog`). Para cambiar de programa, copia el archivo deseado de `programs/` sobre `src/mem_prog.vhd`, por ejemplo:

```bash
cp programs/mem_prog_4_convertir.vhd src/mem_prog.vhd
```

| Programa | Qué hace | Resultado en HEX / LEDs |
|---|---|---|
| `mem_prog_1_suma` | Calcula la suma `1 + 2 + ... + N`, con `N = SW` | Suma (los displays muestran los 16 bits bajos) |
| `mem_prog_2_xor` | `(SW xor 15) xor 496`, equivalente a `SW xor 0x1FF` | Los 9 bits de `SW` invertidos |
| `mem_prog_3_blt` | Compara `SW` con `100` y `-1` usando `blt` y acumula banderas | `4` si `SW < 100`, `5` si `SW >= 100` |
| `mem_prog_4_convertir` | Convierte `SW` (0 a 511) a decimal restando 100 y 10 sucesivamente | Dígitos decimales: centenas en `HEX2`, decenas en `HEX1`, unidades en `HEX0` |

### Ejemplo del programa 1 (ensamblador)

```asm
        lw   t0, 200(zero)    # t0 = SW
        addi t1, zero, 0      # suma = 0
        addi t2, zero, 0      # i = 0
bucle:  beq  t2, t0, fin
        addi t2, t2, 1
        add  t1, t1, t2
        j    bucle
fin:    sw   t1, 208(zero)    # HEX
        sw   t1, 212(zero)    # LEDs
alto:   j    alto
```

## Cómo compilar y programar (Quartus)

1. Crea un proyecto nuevo en Quartus Prime para el dispositivo de la DE1.
2. Agrega todos los archivos de `src/` al proyecto.
3. Define `top_de1` como entidad de nivel superior (*Top-Level Entity*).
4. Asigna los pines (`CLOCK_50`, `KEY`, `SW`, `LEDR`, `HEX0` a `HEX3`) según el manual de la DE1.
5. Compila y programa la tarjeta con el archivo `.sof`.

Las salidas `HEX` son activas en bajo (`s(6..0) = g f e d c b a`).

## Notas

- **Frecuencia del reloj automático:** el divisor conmuta la señal cada `DIV = 5 000 000` ciclos de 50 MHz, por lo que el periodo completo es de 0,2 s (unos **5 Hz**), aunque el comentario del código diga 10 Hz. Para 10 Hz reales usa `DIV => 2500000`.
- `KEY(3 downto 2)` se leen en la dirección 204, pero ninguno de los programas actuales los utiliza.
- Con 9 interruptores, `SW` solo toma valores de 0 a 511 (sin signo), por lo que en el programa de `blt` la rama de números negativos no se activa.
- El `regfile` incluye `mem` en la lista de sensibilidad (el original solo tenía `a1` y `a2`), y la ALU incluye `v` en la suya.

## Créditos

Basado en el procesador monociclo RISC-V de Sarah Harris y David Harris, *Digital Design and Computer Architecture: RISC-V Edition*, adaptado para la tarjeta DE1.
