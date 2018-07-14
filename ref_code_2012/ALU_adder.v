module adder_1(s,cin,a,b,cout); //?????
  input  a,b,cin;
  output s,cout;
  wire   x,s2,s3;
  xor u0(x,a,b);
  xor u1(s,x,cin);
  and u2(s2,x,cin);
  and u3(s3,a,b);
  or  u4(cout,s2,s3);
endmodule

module adder_ahead_4(A,B,CIN,S,COUT);//?????????
  input [3:0]  A,B;
  input        CIN;
  output[3:0]  S;
  output       COUT;
  wire  [2:0]  C,P,G;
  assign G[0]=A[0]&B[0];
  assign P[0]=A[0]^B[0];
  assign G[1]=A[1]&B[1];
  assign P[1]=A[1]^B[1];
  assign G[2]=A[2]&B[2];
  assign P[2]=A[2]^B[2];
  assign C[0]=(P[0]&&CIN)||G[0];
  assign C[1]=G[1]||(P[1]&&G[0])||(P[1]&&P[0]&&CIN);
  assign C[2]=G[2]||(P[2]&&G[1])||(P[2]&&P[1]&&G[0])||(P[2]&&P[1]&&P[0]&&CIN);
  adder_1 uo(.s(S[0]),.cin(CIN),.a(A[0]),.b(B[0]));
  adder_1 u1(.s(S[1]),.cin(C[0]),.a(A[1]),.b(B[1]));
  adder_1 u2(.s(S[2]),.cin(C[1]),.a(A[2]),.b(B[2]));
  adder_1 u3(.s(S[3]),.cin(C[2]),.a(A[3]),.b(B[3]),.cout(COUT));
endmodule

module adder32(A,B,CIN,S,COUT);
input[31:0] A,B;
input CIN;
output[31:0] S;
output COUT;
wire[6:0] ci;
adder_ahead_4 a0(A[3:0],B[3:0],CIN,S[3:0],ci[0]);
adder_ahead_4 a1(A[7:4],B[7:4],ci[0],S[7:4],ci[1]);
adder_ahead_4 a2(A[11:8],B[11:8],ci[1],S[11:8],ci[2]);
adder_ahead_4 a3(A[15:12],B[15:12],ci[2],S[15:12],ci[3]);
adder_ahead_4 a4(A[19:16],B[19:16],ci[3],S[19:16],ci[4]);
adder_ahead_4 a5(A[23:20],B[23:20],ci[4],S[23:20],ci[5]);
adder_ahead_4 a6(A[27:24],B[27:24],ci[5],S[27:24],ci[6]);
adder_ahead_4 a7(A[31:28],B[31:28],ci[6],S[31:28],COUT);
endmodule

module ALU_adder(A,B,ALUFun,Sign,S,Z,N,V);
  input[31:0]  A;
  input[31:0]  B;
  input[5:0]   ALUFun;
  input        Sign;//Sign=1,???
  output[31:0] S;
  output       Z;
  output reg   V;//V=1???
  output reg      N;//N=1,????
  
  wire[31:0]   input_B;
  wire         Cin;
  assign input_B=ALUFun[0]?(~B):B;
  assign Cin=ALUFun[0];
  adder32 ad32(.A(A),.B(input_B),.CIN(Cin),.S(S),.COUT(COUT));
  always @(*)
  begin
    if(Sign)
      begin
        if(ALUFun[0])
          V=((A[31]^B[31])&(B[31]^~S[31]))?1'b1:1'b0;
        else
          V=((A[31]^~B[31])&(B[31]^S[31]))?1'b1:1'b0;
      end
    else
      V=1'b0;
  end
  
  assign Z=(S==32'd0)?1'b1:1'b0;
  
  always @(*)
  begin
    if(Sign)
      N=(S[31]&~V)|(~S[31]&V);//???????
    else
      N=ALUFun[0]&~COUT;
  end      
    
endmodule