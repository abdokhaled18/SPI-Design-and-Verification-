onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb /spi_top_tb/i_spi_cs
add wave -noupdate -expand -group tb /spi_top_tb/i_spi_sck
add wave -noupdate -expand -group tb /spi_top_tb/i_spi_mosi
add wave -noupdate -expand -group tb /spi_top_tb/o_spi_miso
add wave -noupdate /spi_top_tb/spi_top_inst/spi_dp_inst/counter_1/o_max_count
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/address_reg
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/cmd_reg
add wave -noupdate -expand -group CU -color Magenta /spi_top_tb/spi_top_inst/spi_cu_inst/state_reg
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/state_next
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/o_address
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/i_spi_cs
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/i_clk
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/byte_is_ready
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/byte_is_ready_next
add wave -noupdate -expand -group CU -radix binary /spi_top_tb/spi_top_inst/spi_cu_inst/i_recieved_byte
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/o_shift_reg_direction
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/o_shift_reg_par_load
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/o_shift_en
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/o_wr_en
add wave -noupdate -expand -group CU /spi_top_tb/spi_top_inst/spi_cu_inst/o_count_clr
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/shift_reg_1/o_par_data
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/shift_reg_1/shift_reg
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/counter_1/i_en
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/counter_1/count_reg
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/counter_1/i_clr
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/shift_reg_1/i_par_data
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/shift_reg_1/o_ser_data
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/shift_reg_1/i_ser_data
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/reg_file_inst/i_address
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/reg_file_inst/i_wr_en
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/reg_file_inst/i_data
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/reg_file_inst/o_data
add wave -noupdate -expand -group DU /spi_top_tb/spi_top_inst/spi_dp_inst/reg_file_inst/reg_file_mem
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1404636 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 376
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {156523 ps}
