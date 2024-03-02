`timescale 1ns/1ps


module uni_counter #(parameter MOD = 8 , WIDTH = $clog2(MOD))(

    input i_rst,
    input i_clk,
    input i_en,
    input i_up,
    input i_clr,

    output [WIDTH-1:0] o_count,
    output o_max_count,
    output o_min_count 
);

reg [WIDTH-1:0] count_reg;

always @(posedge i_clk or negedge i_rst)  begin
    if (~i_rst || i_clr) begin
        count_reg <= {WIDTH {1'b0}};    
    end
    else if (i_en == 1) begin
        if (i_up == 1) 
            count_reg <= count_reg + 1;
        else 
            count_reg <= count_reg - 1;
    end
end

assign o_count = count_reg;

assign o_max_count = (count_reg == {WIDTH{1'b1}});
assign o_min_count = (count_reg == {WIDTH{1'b0}});
endmodule