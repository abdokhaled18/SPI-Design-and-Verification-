`timescale 1ns/1ps

`define CLK_PERIOD #5

module spi_top_tb #(parameter DATA_WIDTH = 8)() ;

reg i_rst;
reg i_spi_sck ;
reg i_spi_mosi;
reg i_spi_cs;

wire o_spi_miso;
wire o_done;

spi_top #(DATA_WIDTH) 
    spi_top_inst (
        i_rst,
        i_spi_sck,
        i_spi_mosi,
        i_spi_cs,
        o_spi_miso,
        o_done 
    );

// Generating master clock
always@* begin
    
    if(i_spi_cs == 0) begin
        `CLK_PERIOD i_spi_sck <= ~i_spi_sck;
    end
    else 
        i_spi_sck <= 0;
end

// Variables
integer i,j;
reg [DATA_WIDTH-1:0] cmd_test = 8'h02;
reg [DATA_WIDTH-1:0] adddress_test = 8'h00;
reg [DATA_WIDTH-1:0] data_test = 8'b10101010;


initial begin
    
    $display("In the main initial ....");

    // Initializing inputs
    i_rst = 1;
    i_spi_sck = 0;
    i_spi_mosi = 0;
    i_spi_cs = 1;

    // Generating reset 
    apply_reset(i_rst);

    // ---------------------------
    // Testing write tansaction
    // ---------------------------
    write_transaction(8'h02, 8'hfd, 8'b10011001, 3);
    write_transaction(8'h02, 8'h00, 8'b10101010, 5);

    // ---------------------------
    // Testing read tansaction
    // ---------------------------
    read_transaction(8'h03, 8'h00, 3);
    read_transaction(8'h03, 8'hfd, 3);

    // ---------------------------
    // Testing write tansaction
    // ---------------------------
    write_transaction(8'h02, 8'h55, 8'b10011101, 9);
    $stop;        
end

task write_transaction (input [DATA_WIDTH-1:0] trans_cmd, input [DATA_WIDTH-1:0] trans_add, input [DATA_WIDTH-1:0] trans_data, input integer frame_width); begin

    $display("------- Starting WRITE transmittion ------ ");
    // Initiating a transaction
    i_spi_cs = 0;
    //@(negedge i_spi_sck);
    //@(posedge i_spi_sck)
    
    // Transmitting command
    $display("Recieving Write Command ....");
    for (i = DATA_WIDTH-1 ; i>= 0; i = i-1) begin
        i_spi_mosi = trans_cmd[i];
        @(negedge i_spi_sck);
    end

    // Transmitting Address
    $display("Recieving Address ....");
    for (i = DATA_WIDTH-1 ; i>= 0; i = i-1)  begin
        i_spi_mosi = trans_add[i];
        @(negedge i_spi_sck);
    end

    // Transmitting data
    for(i = 0; i < frame_width; i = i+1) begin
        $display("Recieving byte no.%0d \t 0x%0h \t add = 0x%0h - 0x%0d ....", i, trans_data, (trans_add+i), (trans_add+i));
        for (j = DATA_WIDTH-1 ; j>= 0; j = j-1)  begin
            i_spi_mosi = trans_data[j];
            @(negedge i_spi_sck);
        end
        trans_data = trans_data + 8'h01; 
    end

    @(posedge i_spi_sck);
    $display("------- End of WRITE transmition -------");
    i_spi_cs = 1;

    #(100);
    end
endtask

task read_transaction (input [DATA_WIDTH-1:0] trans_cmd, input [DATA_WIDTH-1:0] trans_add, input integer frame_width); begin

    $display("------- Starting READ transmittion ------ ");
    // Initiating a transaction
    i_spi_cs = 0;
    //@(negedge i_spi_sck);
    //@(posedge i_spi_sck)
    
    // Transmitting command
    $display("Recieving read Command ....");
    for (i = DATA_WIDTH-1 ; i>= 0; i = i-1)  begin
        i_spi_mosi = trans_cmd[i];
        @(negedge i_spi_sck);
    end

    // Transmitting Address
    $display("Recieving Address ....");
    for (i = DATA_WIDTH-1 ; i>= 0; i = i-1)  begin
        i_spi_mosi = trans_add[i];
        @(negedge i_spi_sck);
    end

    // Transmitting data
    for(i = 0; i < frame_width; i = i+1) begin
        $display("Sending byte no.%0d \t at address 0x%0h  from slave to master....", i, trans_add);
        for (j = 0; j< DATA_WIDTH; j = j+1) begin
            @(negedge i_spi_sck);
        end
    end

    @(posedge i_spi_sck);
    $display("------- End of READ transmition -------");
    i_spi_cs = 1;

    #(10);
    end
endtask

task apply_reset (input rst); begin

    repeat(5)      `CLK_PERIOD i_rst = 0;
    repeat(10)     `CLK_PERIOD i_rst = 1;

    end
endtask

endmodule
