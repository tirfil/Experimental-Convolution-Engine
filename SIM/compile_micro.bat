#!/bin/bash

FLAG='-v --syn-binding --workdir=ALL_LIB --work=work --ieee=synopsys --std=93c -fexplicit'

ghdl -a $FLAG ../VHDL/micro.vhd
ghdl -a $FLAG ../VHDL/spislave.vhd
ghdl -a $FLAG ../VHDL/spimicro.vhd
#ghdl -a $FLAG ../VHDL/kslice.vhd
#ghdl -a $FLAG ../TEST/tb_kslice.vhd
ghdl -a $FLAG ../TEST/tb_spimicro.vhd
ghdl -e $FLAG tb_spimicro
ghdl -r $FLAG tb_spimicro --wave=tb_spimicro.ghw
# ghdl -a $FLAG tb_timer.vhd
# ghdl -e $FLAG heapsort
# ghdl -r $FLAG TB_TIMER --vcd=timer.vcd
