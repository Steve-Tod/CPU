`timescale 1ns/1ps

module ROM (addr,Instruction);
input [31:0] addr;
output [31:0] Instruction;
reg [31:0] Instruction;
localparam ROM_SIZE = 32;
reg [31:0] ROM_DATA[ROM_SIZE-1:0];

always@(*)
    case(addr[7:2]) //Address Must Be Word Aligned.
        0: Instruction <= 32'h3c114000;
        1: Instruction <= 32'h26310004;
        2: Instruction <= 32'h241000aa;
        3: Instruction <= 32'hae200000;
        4: Instruction <= 32'h08100000;
        5: Instruction <= 32'h0c000000;
        6: Instruction <= 32'h00000000;
        7: Instruction <= 32'h3402000a;
        8: Instruction <= 32'h0000000c;
        9: Instruction <= 32'h0000_0000;
        10: Instruction <= 32'h0274_8825;
        11: Instruction <= 32'h0800_0015;
        12: Instruction <= 32'h0274_8820;
        13: Instruction <= 32'h0800_0015;
        14: Instruction <= 32'h0274_882A;
        15: Instruction <= 32'h1011_0002;
        16: Instruction <= 32'h0293_8822;
        17: Instruction <= 32'h0800_0015;
        18: Instruction <= 32'h0274_8822;
        19: Instruction <= 32'h0800_0015;
        20: Instruction <= 32'h0274_8824;
        21: Instruction <= 32'hae11_0003;
        22: Instruction <= 32'h0800_0001;
       default: Instruction <= 32'h0800_0000;
    endcase
endmodule
