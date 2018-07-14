module ALU_Shift(A,B,ALUFun,S);
  input [31:0]  A;
  input [31:0]  B;
  input [5:0]   ALUFun;
  output  reg [31:0]  S;
  wire  [31:0]  S0;
  wire  [31:0]  S1;
  wire  [31:0]  R1,R2,R3,R4,R5;
  assign S0=B<<A[4:0];
  assign S1=B>>A[4:0];
  
  assign R1=A[4]?({{16{B[31]}},B[31:16]}):B;
  assign R2=A[3]?({{8{R1[31]}},R1[31:8]}):R1;
  assign R3=A[2]?({{4{R2[31]}},R2[31:4]}):R2;
  assign R4=A[1]?({{2{R3[31]}},R3[31:2]}):R3;
  assign R5=A[0]?({R4[31],R4[31:1]}):R4;
  
  always @(*)
  begin
    case(ALUFun[1:0])
      2'b00:  S=S0;
      2'b01:  S=S1;
      2'b11:  S=R5;
      default:S=B;
    endcase
  end
  
endmodule