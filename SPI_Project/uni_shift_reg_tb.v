`timescale 1ns/1ps


module uni_shift_reg_tb #(parameter WIDTH = 8)() ;


reg i_clk;
reg i_rst;
reg i_data;
reg i_shift_en;

wire [WIDTH - 1 : 0] o_par_data;
wire o_ser_data;


uni_shift_reg #(WIDTH) 
    shift_reg_1 (
        i_rst,
        i_clk,
        i_data,
        i_shift_en,
        o_ser_data,
        o_par_data 
    );

always begin
    #5 i_clk =~ i_clk;
end


// Variables
integer i;
reg [WIDTH-1:0] test_data = 8'b11110000;


initial begin
    
    // Initializing inputs
    i_clk = 0;
    i_rst = 1;
    i_data = 0;
    i_shift_en = 0;

    // Generating reset 
    @(negedge i_clk) i_rst = 0;
    @(posedge i_clk) i_rst = 1;

    i_shift_en = 1;

    $monitor("[%0t] Serial output : %b",$time, o_ser_data); 
    
    for (i = 0; i< WIDTH; i = i+1) begin
        i_data = test_data[i];
        @(posedge i_clk);
    end


    @(posedge i_clk) i_shift_en = 0;
    $display("[%0t] Output load   : %b",$time, o_par_data);



    $stop;        
end

endmodule

