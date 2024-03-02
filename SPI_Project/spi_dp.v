`timescale 1ns/1ps

module spi_dp #(parameter DATA_WIDTH = 8, ADDRESS_SIZE = 8)(

    input i_rst,

    // Control of shift register
    input i_shift_en,
    input i_shift_reg_direction,
    input i_shift_reg_par_load,
    
    // Control of internal counter
    input i_count_en,
    input i_count_clr,
    
    // Control of register file
    input i_reg_file_wr_en,
    input [ADDRESS_SIZE-1:0] i_reg_file_address,
    
    // System I/Os
    input i_sys_clk,
    input [ADDRESS_SIZE-1:0] i_sys_address,
    input i_sys_wr_en,
    output [DATA_WIDTH-1:0] o_sys_data,
    
    // SPI slave I/Os
    input i_clk,
    input i_spi_cs,
    input i_spi_mosi,
    output o_spi_miso,
    
    // Flow control flags
    input o_done,
    output [DATA_WIDTH-1:0] o_recieved_byte,
    output byte_is_ready
);


wire [DATA_WIDTH-1:0] o_shift_reg_par_data;
wire [DATA_WIDTH-1:0] o_reg_file_data;

/*
wire [DATA_WIDTH-1:0] reg_file_in;
wire [DATA_WIDTH-1:0] reg_file_out;
wire reg_file_wr;
wire reg_file_clk;

always @* begin
  if(o_done) begin

  end
end
*/

uni_shift_reg #(DATA_WIDTH,1) 
    shift_reg_mosi (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_ser_data(i_spi_mosi),
        .i_par_data(0),
        .i_shift_en(i_shift_en),
        .i_direction(i_shift_reg_direction),
        .i_par_load(0),
        .o_ser_data(),
        .o_par_data(o_shift_reg_par_data) 
    );

uni_shift_reg #(DATA_WIDTH,0) 
    shift_reg_miso (
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_ser_data(0),
        .i_par_data(o_reg_file_data),
        .i_shift_en(i_shift_en),
        .i_direction(0),
        .i_par_load(i_shift_reg_par_load),
        .o_ser_data(o_spi_miso),
        .o_par_data() 
    );      


uni_counter #(8) 
    counter_1 (
        .i_rst(i_rst),
        .i_clk(i_clk),
        .i_en(i_count_en),
        .i_up(1),
        .i_clr(i_count_clr),
        .o_count(),
        .o_max_count(byte_is_ready),
        .o_min_count() 
    );

  
reg_file #(DATA_WIDTH, ADDRESS_SIZE)
    reg_file_inst(
        i_clk,
        i_reg_file_address,
        o_shift_reg_par_data,
        i_reg_file_wr_en,
        o_reg_file_data
    );


assign o_recieved_byte = o_shift_reg_par_data;

endmodule
