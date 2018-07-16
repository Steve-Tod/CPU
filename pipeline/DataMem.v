`timescale 1ns/1ps

module DataMem(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite);
    input reset, clk;
    input [31:0] Address, Write_data;
    input MemRead, MemWrite;
    output [31:0] Read_data;

    parameter RAM_SIZE = 256;
    reg [31:0] RAMDATA [RAM_SIZE-1:0];

    assign Read_data =
    (MemRead && (Address < RAM_SIZE)) ? RAMDATA[Address[31:2]] : 32'b0;
    //Y:Actually , We can take Address[9:2] instead of [31:2] because Address < 256

    always@(posedge clk)
       if(MemWrite && (Address < RAM_SIZE))
         RAMDATA[Address[31:2]] <= Write_data;
           //Y:look at the last comment
endmodule
