`timescale 1ns/1ps


module spi_cu #(parameter DATA_WIDTH = 8, ADDRESS_SIZE = 8) (

    input i_rst,
    input i_clk,
    input i_spi_cs,
    input byte_is_ready,
    input [DATA_WIDTH-1:0] i_recieved_byte,

    output [ADDRESS_SIZE-1:0] o_address,
    output reg o_shift_en,
    output reg o_shift_reg_direction,
    output reg o_shift_reg_par_load,
    output reg o_count_en,
    output reg o_count_clr,
    output reg o_wr_en,

    output o_done
);



wire cmd_is_read;
wire cmd_is_write;


// Determine the current type of recieving byte
// When byte_count = 0 , command is being recieved
// When byte_count = 1 , address is being recieved
// When byte_count >= 2 , data is being recieved or transmitted
reg [ADDRESS_SIZE-1:0] byte_count;
always @ (posedge i_clk or negedge i_rst ) begin
    if(~i_rst) begin
        byte_count <= {ADDRESS_SIZE{1'b0}};
    end
    else if(byte_is_ready) begin
            byte_count <= byte_count + 1;
    end
end


localparam  IDLE    = 1'b0,
            OPR     = 1'b1;

reg state_reg, state_next;

always @(posedge i_clk or negedge i_rst) begin
    
    if(~i_rst) begin
        state_reg <= IDLE;
    end
    else begin
        state_reg <= state_next;
    end
end

always @* begin

    state_next = state_reg;

    case(state_reg)

    // Slave not Recieving (chip select deasserted)
    IDLE:begin

        o_shift_en  = ~i_spi_cs;
        o_count_en  = ~i_spi_cs;
        o_count_clr = 1;
        o_wr_en     = 0;
        o_shift_reg_par_load  = 0;

        if(~i_spi_cs) begin
            state_next = OPR;
        end
    end

    // Active operation state
    OPR:begin

        o_shift_en  = ~i_spi_cs;
        o_count_en  = ~i_spi_cs;
        o_count_clr = 0;
        o_wr_en     = 0;
        o_shift_reg_par_load  = 0;

        if(cmd_is_write && byte_count >= 2 && byte_is_ready) begin
            o_wr_en = 1;
        end

        if(cmd_is_read && byte_count >= 1 && byte_is_ready) begin
            o_shift_reg_par_load = 1;
        end

        if(i_spi_cs)
            state_next = IDLE;
    end
    
    default: begin

        o_shift_en  = 0;
        o_count_en  = 0;
        o_count_clr = 0;
        o_wr_en     = 0;
        o_shift_reg_par_load = 0;
        
        state_next = IDLE;
    end

    endcase
end

// [Purpose] Store recieved command to operate on
reg [ADDRESS_SIZE-1:0] cmd_reg;
always @ (posedge i_clk or negedge i_rst) begin
    if(~i_rst)
        cmd_reg <= {DATA_WIDTH{1'b0}};
    else if((byte_count == 0) && (byte_is_ready == 1))
        cmd_reg <= i_recieved_byte;
end
assign cmd_is_write = (cmd_reg == 8'h02) ? 1'b1 : 1'b0;
assign cmd_is_read  = (cmd_reg == 8'h03) ? 1'b1 : 1'b0;


// [Purpose] Store recieved address to access the reg file
reg [ADDRESS_SIZE-1:0] address_reg;
always @ (posedge i_clk or negedge i_rst) begin
    if(~i_rst)
        address_reg <= {ADDRESS_SIZE{1'b0}};
    else if((byte_count == 1) && byte_is_ready)
        address_reg <= i_recieved_byte;
    else if((byte_count >= 2) & byte_is_ready &(~i_spi_cs))
        address_reg <= address_reg + 1;
end
assign o_address = (cmd_is_read)? ((byte_count == 1) ? i_recieved_byte : address_reg + 1) : address_reg;

// [purpose] Reset slave state vars to idle values when transmittion complete
always @(posedge i_spi_cs) begin
    byte_count  <= {ADDRESS_SIZE{1'b0}};
    state_reg   <= IDLE;
end

// Flag indicates that transmittion is done
assign o_done = i_spi_cs;

endmodule