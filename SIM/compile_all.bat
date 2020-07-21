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
#ghdl -e $FLAG vcore

ghdl -a $FLAG ../TEST/tb_vcore.vhd
ghdl -e $FLAG tb_vcore
ghdl -r $FLAG tb_vcore --wave=tb_vcore.ghw

