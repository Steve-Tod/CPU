`timescale 1ns/1ns

module ROM (addr,data);
//notice : only 31 bit addr input
input [30:0] addr;
output [31:0] data;

localparam ROM_SIZE = 256;
reg [31:0] ROMDATA[ROM_SIZE-1:0];

assign data=(addr[30:2] < ROM_SIZE)?ROMDATA[addr[30:2]]:32'b0;

integer i;
initial begin
ROMDATA[0] <= 32'h08000009;      //j
ROMDATA[1] <= 32'h08000030;      //j
ROMDATA[2] <= 32'h0800007c;      //j
ROMDATA[3] <= 32'h3c1d4000;      //lui
ROMDATA[4] <= 32'h20090003;      //addi
ROMDATA[5] <= 32'hafa90008;      //sw
ROMDATA[6] <= 32'h001ff840;      //sll
ROMDATA[7] <= 32'h001ff842;      //srl
ROMDATA[8] <= 32'h03e00008;      //jr
ROMDATA[9] <= 32'h0c000003;      //jal
ROMDATA[10] <= 32'h20140010;      //addi
ROMDATA[11] <= 32'h20130008;      //addi
ROMDATA[12] <= 32'h20120001;      //addi
ROMDATA[13] <= 32'h20110000;      //addi
ROMDATA[14] <= 32'hafa00008;      //sw
ROMDATA[15] <= 32'h3c15ffff;      //lui
ROMDATA[16] <= 32'h0015b403;      //sra
ROMDATA[17] <= 32'hafb60004;      //sw
ROMDATA[18] <= 32'h2015fa6e;      //addi
ROMDATA[19] <= 32'hafb50000;      //sw
ROMDATA[20] <= 32'h20160003;      //addi
ROMDATA[21] <= 32'hafb60008;      //sw
ROMDATA[22] <= 32'hafa0000c;      //sw
ROMDATA[23] <= 32'hafa00014;      //sw
ROMDATA[24] <= 32'h8fb00020;      //lw
ROMDATA[25] <= 32'h32100008;      //andi
ROMDATA[26] <= 32'h1613fffd;      //bne
ROMDATA[27] <= 32'h12200001;      //beq
ROMDATA[28] <= 32'h12320004;      //beq
ROMDATA[29] <= 32'h8fa4001c;      //lw
ROMDATA[30] <= 32'h00807020;      //add
ROMDATA[31] <= 32'h22310001;      //addi
ROMDATA[32] <= 32'h08000018;      //j
ROMDATA[33] <= 32'h8fa5001c;      //lw
ROMDATA[34] <= 32'h00a07820;      //add
ROMDATA[35] <= 32'h00a46022;      //sub
ROMDATA[36] <= 32'h05800003;      //bltz
ROMDATA[37] <= 32'h00055820;      //add
ROMDATA[38] <= 32'h00042820;      //add
ROMDATA[39] <= 32'h000b2020;      //add
ROMDATA[40] <= 32'h00852022;      //sub
ROMDATA[41] <= 32'h00a46022;      //sub
ROMDATA[42] <= 32'h0580fffd;      //bltz
ROMDATA[43] <= 32'h1480fff7;      //bne
ROMDATA[44] <= 32'hafa50018;      //sw
ROMDATA[45] <= 32'hafa5000c;      //sw
ROMDATA[46] <= 32'h20110000;      //addi
ROMDATA[47] <= 32'h08000018;      //j
ROMDATA[48] <= 32'h8fb80008;      //lw
ROMDATA[49] <= 32'h0000c820;      //add
ROMDATA[50] <= 32'h2339fff9;      //addi
ROMDATA[51] <= 32'h0319c824;      //and
ROMDATA[52] <= 32'hafb90008;      //sw
ROMDATA[53] <= 32'h8fa80014;      //lw
ROMDATA[54] <= 32'h00084202;      //srl
ROMDATA[55] <= 32'h20090008;      //addi
ROMDATA[56] <= 32'h200a0004;      //addi
ROMDATA[57] <= 32'h31cb000f;      //andi
ROMDATA[58] <= 32'h1109000c;      //beq
ROMDATA[59] <= 32'h20090004;      //addi
ROMDATA[60] <= 32'h200a0002;      //addi
ROMDATA[61] <= 32'h31eb00f0;      //andi
ROMDATA[62] <= 32'h000b5902;      //srl
ROMDATA[63] <= 32'h11090007;      //beq
ROMDATA[64] <= 32'h20090002;      //addi
ROMDATA[65] <= 32'h200a0001;      //addi
ROMDATA[66] <= 32'h31eb000f;      //andi
ROMDATA[67] <= 32'h11090003;      //beq
ROMDATA[68] <= 32'h200a0008;      //addi
ROMDATA[69] <= 32'h31cb00f0;      //andi
ROMDATA[70] <= 32'h000b5902;      //srl
ROMDATA[71] <= 32'h200d00c0;      //addi
ROMDATA[72] <= 32'h1160002b;      //beq
ROMDATA[73] <= 32'h200c0001;      //addi
ROMDATA[74] <= 32'h200d00f9;      //addi
ROMDATA[75] <= 32'h116c0028;      //beq
ROMDATA[76] <= 32'h200c0002;      //addi
ROMDATA[77] <= 32'h200d00a4;      //addi
ROMDATA[78] <= 32'h116c0025;      //beq
ROMDATA[79] <= 32'h200c0003;      //addi
ROMDATA[80] <= 32'h200d00b0;      //addi
ROMDATA[81] <= 32'h116c0022;      //beq
ROMDATA[82] <= 32'h200c0004;      //addi
ROMDATA[83] <= 32'h200d0099;      //addi
ROMDATA[84] <= 32'h116c001f;      //beq
ROMDATA[85] <= 32'h200c0005;      //addi
ROMDATA[86] <= 32'h200d0092;      //addi
ROMDATA[87] <= 32'h116c001c;      //beq
ROMDATA[88] <= 32'h200c0006;      //addi
ROMDATA[89] <= 32'h200d0082;      //addi
ROMDATA[90] <= 32'h116c0019;      //beq
ROMDATA[91] <= 32'h200c0007;      //addi
ROMDATA[92] <= 32'h200d00f8;      //addi
ROMDATA[93] <= 32'h116c0016;      //beq
ROMDATA[94] <= 32'h200c0008;      //addi
ROMDATA[95] <= 32'h200d0080;      //addi
ROMDATA[96] <= 32'h116c0013;      //beq
ROMDATA[97] <= 32'h200c0009;      //addi
ROMDATA[98] <= 32'h200d0090;      //addi
ROMDATA[99] <= 32'h116c0010;      //beq
ROMDATA[100] <= 32'h200c000a;      //addi
ROMDATA[101] <= 32'h200d0088;      //addi
ROMDATA[102] <= 32'h116c000d;      //beq
ROMDATA[103] <= 32'h200c000b;      //addi
ROMDATA[104] <= 32'h200d0083;      //addi
ROMDATA[105] <= 32'h116c000a;      //beq
ROMDATA[106] <= 32'h200c000c;      //addi
ROMDATA[107] <= 32'h200d00c6;      //addi
ROMDATA[108] <= 32'h116c0007;      //beq
ROMDATA[109] <= 32'h200c000d;      //addi
ROMDATA[110] <= 32'h200d00a1;      //addi
ROMDATA[111] <= 32'h116c0004;      //beq
ROMDATA[112] <= 32'h200c000e;      //addi
ROMDATA[113] <= 32'h200d0086;      //addi
ROMDATA[114] <= 32'h116c0001;      //beq
ROMDATA[115] <= 32'h200d008e;      //addi
ROMDATA[116] <= 32'h000a5200;      //sll
ROMDATA[117] <= 32'h014d4020;      //add
ROMDATA[118] <= 32'hafa80014;      //sw
ROMDATA[119] <= 32'h8fb80008;      //lw
ROMDATA[120] <= 32'h20190002;      //addi
ROMDATA[121] <= 32'h0319c825;      //or
ROMDATA[122] <= 32'hafb90008;      //sw
ROMDATA[123] <= 32'h03400008;      //jr
ROMDATA[124] <= 32'h00000000;      //sll

end
endmodule

