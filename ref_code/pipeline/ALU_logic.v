module ALU_logic(A,B,op,S);
		
input  [31:0] A,B;
input  [3:0] op;                     //op=ALUFun[3:0]
output reg [31:0] S;

always @ (A or B or op)
begin
  case(op)
    4'b1000:S = A&B;          //AND
    4'b1110:S = A|B;          //OR
    4'b0110:S = A^B;          //XOR
    4'b0001:S = ~(A|B);       //NOR
    4'b1010:S = A;            //"A"
    default:S = 0;
  endcase
end
endmodule

