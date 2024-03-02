
`timescale 1ns/1ps

module sys_top #(parameter DATA_WIDTH = 8)(

    input i_rst,
    input clk,
    input i_spi_sck,
    input i_spi_mosi,
    input i_spi_cs,

    output o_spi_miso,
    output [DATA_WIDTH-1:0] data_read
);



wire trans_is_done;


spi_top #(DATA_WIDTH) 
    spi_top_inst (
        i_rst,
        i_spi_sck,
        i_spi_mosi,
        i_spi_cs,
        o_spi_miso,
        trans_is_done 
);



endmodule
