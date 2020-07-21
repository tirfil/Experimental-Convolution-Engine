#!/bin/bash

FLAG='-v --syn-binding --workdir=ALL_LIB --work=work --ieee=synopsys --std=93c -fexplicit'

#ghdl -a $FLAG ../VHDL/ksliceoto.vhd
#ghdl -a $FLAG ../TEST/tb_ksliceoto.vhd
ghdl -a $FLAG ../VHDL/dp16x16.vhd
ghdl -e $FLAG dp16x16
ghdl -r $FLAG dp16x16 --wave=dp16x16.ghw
#ghdl -a $FLAG ../VHDL/fp16mult.vhd
#ghdl -a $FLAG ../VHDL/kernel9.vhd
#ghdl -a $FLAG ../VHDL/kernel.vhd
#ghdl -a $FLAG ../VHDL/kslice.vhd
#ghdl -a $FLAG ../TEST/tb_kslice.vhd
#ghdl -a $FLAG ../TEST/tb_kernel.vhd
#ghdl -e $FLAG tb_kernel
#ghdl -r $FLAG tb_kernel --wave=tb_kernel.ghw
# ghdl -a $FLAG tb_timer.vhd
# ghdl -e $FLAG heapsort
# ghdl -r $FLAG TB_TIMER --vcd=timer.vcd
