module ALU(ALUFun,A,B,Sign,Out);
input [5:0]ALUFun;
input [31:0]A,B;
input Sign;
output reg [31:0]Out;
wire [1:0]op;
wire [31:0] S1,S2,S3,S4;
assign op = ALUFun[5:4];
ALU_addsub ALU_addsub1(A,B,ALUFun[0],Sign,S1,Z,V,N);
ALU_CMP ALU_CMP1(Z,V,N,ALUFun[3:1],S2);
ALU_logic ALU_logic1(A,B,ALUFun[3:0],S3);
ALU_shift ALU_shift1(A,B,ALUFun[1:0],S4);
always @(*) begin
	case(op)
	2'b00:Out=S1;
	2'b11:Out=S2;
	2'b01:Out=S3;
	2'b10:Out=S4;
	endcase
end
endmodule

module Test_ALU;
reg [5:0]ALUFun;
reg [31:0]A,B;
reg Sign;
wire [1:0]op;
initial
begin
	ALUFun=6'b011010;
	A=32'd15;
	B=32'd31;
	Sign=1;
end
ALU ZY(ALUFun,A,B,Sign,Out);
endmodule