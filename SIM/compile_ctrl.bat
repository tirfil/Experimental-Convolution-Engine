#!/bin/bash

FLAG='-v --syn-binding --workdir=ALL_LIB --work=work --ieee=synopsys --std=93c -fexplicit'

ghdl -a $FLAG ../VHDL/controller.vhd
#ghdl -a $FLAG ../VHDL/kslice.vhd
#ghdl -a $FLAG ../TEST/tb_kslice.vhd
ghdl -a $FLAG ../TEST/tb_controller.vhd
ghdl -e $FLAG tb_controller
ghdl -r $FLAG tb_controller --wave=tb_controller.ghw
# ghdl -a $FLAG tb_timer.vhd
# ghdl -e $FLAG heapsort
# ghdl -r $FLAG TB_TIMER --vcd=timer.vcd
