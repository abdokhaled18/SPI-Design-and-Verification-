

`timescale 1ns/1ps

module reg_file_tb #(parameter DATA_WIDTH = 8, LENGTH = 64, ADDRESS_SIZE = 8)();

reg i_clk;

reg [ADDRESS_SIZE-1:0] i_address;
reg [DATA_WIDTH-1:0] i_data;
reg i_wr_en;
wire [DATA_WIDTH-1:0] o_data;

reg_file  reg_file_inst (
        i_clk,
        i_address,
        i_data,
        i_wr_en,
        o_data 
    );

always begin
    #5 i_clk =~ i_clk;
end


// Variables
integer i;

initial begin
    
    // Initializing inputs
    i_clk = 0;
    i_address = 8'h00;
    i_data = 8'h00;
    i_wr_en = 0;


    // Default Writing case
    @(posedge i_clk) i_data = 8'h15; i_address = 8'h02; i_wr_en = 1;
    @(negedge i_clk) 
    
    @(posedge i_clk) i_data = 8'h99; i_address = 8'ha6; i_wr_en = 1;
    @(negedge i_clk)

    // Default Reading Case
    @(posedge i_clk) i_data = 8'h84; i_address = 8'h02; i_wr_en = 0;
    @(negedge i_clk) 

    // Over writing case
    @(posedge i_clk) i_data = 8'hff; i_address = 8'ha6; i_wr_en = 1;
    @(negedge i_clk) 

    // Reading the overwritten Case
    @(posedge i_clk) i_data = 8'hea; i_address = 8'ha6; i_wr_en = 0;
    @(negedge i_clk) 

    
    @(posedge i_clk)
    @(posedge i_clk)
    @(posedge i_clk)
    @(posedge i_clk)

    $stop;        
end

endmodule

