
# 12 MHz
create_clock -name MCLK -period 83.333 [get_ports MCLK]

# 50 MHz (SPI)
create_clock -name SCK -period 20 [get_ports SCK]

# PLL
derive_pll_clocks

derive_clock_uncertainty

#
set_input_delay -clock SCK 1.5 [get_ports {MOSI SS}]
set_false_path -to [get_ports MISO]
set_false_path -to [get_ports IDLE]
set_false_path -from [get_ports nRST]


set_false_path -from [get_registers {spimicro:I_spimicro_0|spislave:I_spislave_0|NIBBLE[*]}] -to *
set_false_path -from [get_registers {spimicro:I_spimicro_0|spislave:I_spislave_0|PIN[*]}] -to *
# resynchro FF
set_false_path -to [get_registers {spimicro:I_spimicro_0|micro:I_micro_0|LSO1}]
set_false_path -to [get_registers {spimicro:I_spimicro_0|micro:I_micro_0|ENSI1}]
set_false_path -to [get_registers {spimicro:I_spimicro_0|micro:I_micro_0|ESI1}]
set_false_path -to [get_registers {spimicro:I_spimicro_0|micro:I_micro_0|SS1}]

set_false_path -to [get_registers {spimicro:I_spimicro_0|spislave:I_spislave_0|sout[*]}]
