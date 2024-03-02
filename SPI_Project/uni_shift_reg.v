`timescale 1ns/1ps


module uni_shift_reg #(parameter DATA_WIDTH = 8, DIRECTION = 1)(

    input i_rst,
    input i_clk,
    
    input i_ser_data,
    input [DATA_WIDTH-1:0] i_par_data,
    
    input i_par_load,
    input i_shift_en,
    input i_direction,

    output o_ser_data,
    output [DATA_WIDTH-1 :0] o_par_data
);

// Internal shift Var
reg [DATA_WIDTH-1 : 0] shift_reg;
integer  i ;

generate if (DIRECTION) 
    always @(posedge i_clk or negedge i_rst) begin
        
        // Reseting & Initializing internal signals
        if(~i_rst) begin
            shift_reg <= {DATA_WIDTH {1'b1}};
        end

        // Shifting Operation
        else if (i_shift_en == 1) begin
            if(i_par_load == 1)
                shift_reg <= i_par_data;
            else begin        
                shift_reg <= {shift_reg[DATA_WIDTH-2:0],i_ser_data};
            end
        end
    end

else
    always @(negedge i_clk or negedge i_rst) begin
        
        // Reseting & Initializing internal signals
        if(~i_rst) begin
            shift_reg <= {DATA_WIDTH {1'b1}};
        end

        // Shifting Operation
        else if (i_shift_en == 1) begin
            if(i_par_load == 1)
                shift_reg <= i_par_data;
            else begin        
                shift_reg <= {shift_reg[DATA_WIDTH-2:0],i_ser_data};
            end
        end
    end
endgenerate

assign o_ser_data = shift_reg[DATA_WIDTH - 1];
assign o_par_data = shift_reg;

endmodule
