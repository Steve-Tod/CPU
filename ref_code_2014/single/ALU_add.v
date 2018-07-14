module ALU_addsub(A, B, op, Sign, S, Z, V, N);
// op=ALUfun[0]
input [31:0] A, B;
reg [31:0] BB;
input op, Sign;
output Z, V, N;
output [31:0] S;
reg [32:0] Sum;
wire V_Sign;
always @(*) begin BB = B;
if (Sign)
  begin if (op) begin BB = ~B + 1;
end end Sum = A + BB;
end assign V_Sign = (A[31] == BB[31]) ? Sum[32] ^ Sum[31] : 0;
assign V = (~Sign) ? Sum[32] : V_Sign;
assign S = Sum [31:0];
assign Z = ~(| S);
assign N = (Sign) ? S[31] : 0;
endmodule

    module Test_add;
reg [31:0] A, B;
reg op, Sign;
initial begin A = 32'd3;
B = 32'd5;
Sign = 1;
op = 1;
end ALU_addsub ZY(A, B, op, Sign, S, Z, V, N);
endmodule
