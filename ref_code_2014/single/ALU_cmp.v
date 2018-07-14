module ALU_CMP(Z, V, N, op, S);

input Z, V, N;
input [2:0] op; // op=ALUFun[3:1]
output reg [31:0] S;

always @(Z or V or N or op) begin case (op)3'b001 : S <= {31'b0, Z}; // EQ
3'b000 : S <= {31'b0, ~Z};                                           // NEQ
3'b010 : S <= {31'b0, N};                                            // LT
3'b110 : S <= {31'b0, N | Z};                                        // LEZ
3'b101 : S <= {31'b0, N};                                            // LTZ
3'b111 : S <= {31'b0, (~N) & (~Z)};                                  // GTZ
default:
S <= 0;
endcase end endmodule