#!/bin/bash

FLAG='-v --syn-binding --workdir=ALL_LIB --work=work --ieee=synopsys --std=93c -fexplicit'


ghdl -a $FLAG ../VHDL/fp16adder.vhd
ghdl -a $FLAG ../VHDL/fp16mult.vhd
ghdl -a $FLAG ../VHDL/kernel9.vhd
ghdl -a $FLAG ../VHDL/kernel.vhd
ghdl -a $FLAG ../VHDL/controller.vhd
ghdl -a $FLAG ../VHDL/output.vhd
ghdl -a $FLAG ../VHDL/delay3.vhd
ghdl -a $FLAG ../VHDL/vcore.vhd
ghdl -a $FLAG ../VHDL/spislave.vhd
ghdl -a $FLAG ../VHDL/micro.vhd
ghdl -a $FLAG ../VHDL/spimicro.vhd
ghdl -a $FLAG ../MEM/dp16384x16.vhd
ghdl -a $FLAG ../MEM/dp16x16.vhd
ghdl -a $FLAG ../VHDL/top.vhd
#ghdl -e $FLAG top

ghdl -a $FLAG ../TEST/tb_top.vhd
ghdl -e $FLAG tb_top
ghdl -r $FLAG tb_top --wave=tb_top.ghw

