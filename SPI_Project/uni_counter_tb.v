
`timescale 1ns/1ps


module uni_counter_tb #(parameter MOD = 8 , WIDTH = $clog2(MOD))() ;

reg i_rst;
reg i_clk;

reg i_en;
reg i_up;

wire [WIDTH - 1 : 0] o_count;
wire o_max_count;
wire o_min_count;

uni_counter #(8) 
    counter_1 (
        i_rst,
        i_clk,
        i_en,
        i_up,
        o_count,
        o_max_count,
        o_min_count 
    );

always begin
    #5 i_clk =~ i_clk;
end


// Variables
integer i;

initial begin
    
    // Initializing inputs
    i_clk = 0;
    i_rst = 1;
    

    // Generating reset 
    @(negedge i_clk) i_rst = 0;
    @(posedge i_clk) i_rst = 1;

    i_en = 1;
    i_up = 1;

    @(posedge o_max_count)
    @(posedge o_max_count)
    
    i_up = 0;
    @(posedge o_min_count)

    repeat(4) @(posedge i_clk)
    i_en = 0;

    $stop;        
end

endmodule

