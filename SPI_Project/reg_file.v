`timescale 1ns/1ps


module reg_file #(parameter DATA_WIDTH = 8, ADDRESS_SIZE = 8, LENGTH = (2**ADDRESS_SIZE))(

    input i_clk,

    input [ADDRESS_SIZE-1:0] i_address,
    input [DATA_WIDTH-1:0] i_data,
    input i_wr_en,

    output [DATA_WIDTH-1:0] o_data

);


// Create Register file memory
reg [DATA_WIDTH-1:0] reg_file_mem [LENGTH-1:0];


// Negative edge triggered 
always @(negedge i_clk) begin
    if (i_wr_en)
        reg_file_mem[i_address] <= i_data;
end
assign o_data = reg_file_mem[i_address];
endmodule