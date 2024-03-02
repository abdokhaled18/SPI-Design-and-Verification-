`timescale 1ns/1ps


module spi_cu_old #(parameter DATA_WIDTH = 8, ADDRESS_SIZE = 8) (

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
    output reg o_wr_en
);



wire cmd_is_read;
wire cmd_is_write;
wire cmd_error;
wire last_bit;

reg byte_is_ready_next;
reg cs_end;

always @ (posedge i_clk or negedge i_rst) begin
    if(~i_rst) begin
        byte_is_ready_next <= 0;
        cs_end <= 1;
    end
    else begin 
        byte_is_ready_next <= byte_is_ready;
        cs_end <= i_spi_cs;
    end

end

localparam  IDLE    = 3'b000,
            CMD     = 3'b001,
            ADDRESS = 3'b011,
            WRITE   = 3'b010,
            READ    = 3'b111;

reg [2:0] state_reg, state_next;

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
    IDLE:begin

        o_shift_en  = 0;
        o_count_en  = 0;
        o_count_clr = 1;
        o_wr_en     = 0;
        o_shift_reg_par_load  = 0;

        if(~i_spi_cs) begin
            state_next = CMD;
        end
    end

    CMD:begin

        o_shift_en  = 1;
        o_count_en  = 1;
        o_count_clr = 0;
        o_wr_en     = 0;
        o_shift_reg_par_load  = 0;

        if(~i_spi_cs & byte_is_ready_next)
            state_next = ADDRESS;
    end
    
    ADDRESS:begin

        o_shift_en  = 1;
        o_count_en  = 1;
        o_count_clr = 0;
        o_wr_en     = 0;
        o_shift_reg_par_load  = 0;

        if(~i_spi_cs & cmd_is_write & byte_is_ready_next)
            state_next = WRITE;
        else if(~i_spi_cs & cmd_is_read & byte_is_ready_next)
            state_next = READ;
    end

    WRITE:begin

        o_shift_en  = 1;
        o_count_en  = 1;
        o_count_clr = byte_is_ready_next;
        o_wr_en     = byte_is_ready_next;
        o_shift_reg_par_load  = 0;
        
        if(i_spi_cs) begin
            state_reg = IDLE;
        end

    end

    READ:begin

        o_shift_en  = 1;
        o_count_en  = 1;
        o_count_clr = byte_is_ready_next;
        o_wr_en     = 0;
        o_shift_reg_par_load  = 1;

        if(i_spi_cs) begin
            state_reg = IDLE;
        end
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
assign last_bit = (cs_end == 0 && i_spi_cs == 1);
/*
always @(posedge i_clk or negedge i_rst or state_reg or byte_is_ready) begin
    
    if(~i_rst) begin
        state_reg <= IDLE;
    end

    else begin
        case(state_reg)
        IDLE:begin

            o_shift_en  = 0;
            o_wr_en     = 0;
            o_shift_reg_direction = 0;
            o_shift_reg_par_load  = 0;

            if(~i_spi_cs)
                state_reg <= CMD;
        end

        CMD:begin

            o_shift_en  = 1;
            o_wr_en     = 0;
            o_shift_reg_direction = 0;
            o_shift_reg_par_load  = 0;

            if(~i_spi_cs & byte_is_ready)
                state_reg <= ADDRESS;
        end
        
        ADDRESS:begin

            o_shift_en  = 1;
            o_wr_en     = 0;
            o_shift_reg_direction = 0;
            o_shift_reg_par_load  = 0;

            if(~i_spi_cs & cmd_is_write & byte_is_ready)
                state_reg <= WRITE;
            else if(~i_spi_cs & cmd_is_read & byte_is_ready)
                state_reg <= READ;
        end

        WRITE:begin

            o_shift_en  = 1;
            o_wr_en     = byte_is_ready;
            o_shift_reg_direction = 0;
            o_shift_reg_par_load  = 0;
            
            
            //if(byte_is_ready)  o_wr_en     = 1;
            //else               o_wr_en     = 0;
            
            if(i_spi_cs)
                state_reg <= IDLE;
        end

        READ:begin

            o_shift_en  = 1;
            o_wr_en     = 0;
            o_shift_reg_direction = 1;
            o_shift_reg_par_load  = 1;

            if(i_spi_cs)
                state_reg <= IDLE;
        end
        
        default: begin

            o_shift_en  = 0;
            o_wr_en     = 0;
            o_shift_reg_direction = 0;
            o_shift_reg_par_load = 0;
            
            state_reg <= IDLE;
        end

        endcase
    end
end
*/

reg [ADDRESS_SIZE-1:0] cmd_reg;
always @ (posedge i_clk or negedge i_rst) begin
    if(~i_rst)
        cmd_reg <= {DATA_WIDTH{1'b0}};
    else if((state_reg == CMD) && (byte_is_ready_next == 1))
        cmd_reg <= i_recieved_byte;
end
assign cmd_is_write = (cmd_reg == 8'h02) ? 1'b1 : 1'b0;
assign cmd_is_read  = (cmd_reg == 8'h03) ? 1'b1 : 1'b0;



reg [ADDRESS_SIZE-1:0] address_reg;
always @ (posedge i_clk or negedge i_rst) begin
    if(~i_rst)
        address_reg <= {ADDRESS_SIZE{1'b0}};
    else if((state_reg == ADDRESS) && byte_is_ready_next)
        address_reg <= i_recieved_byte;
    else if((state_reg == WRITE || state_reg == READ) & byte_is_ready_next &(~i_spi_cs) )
        address_reg <= address_reg + 1;
end
assign o_address = address_reg;


endmodule