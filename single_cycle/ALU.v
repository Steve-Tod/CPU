module ALU(DataA,DataB,ALUFun,Sign,ALUOut);
input [31:0] DataA, DataB;
input [5:0] ALUFun;
input Sign;
output reg ALUOut[31:0];
wire  [31:0] S1,S2,S3,S4;
wire  Zero,Overflow,Negitive;

ALU_AddSub ALU1(DataA,DataB,ALUFun[0],Sign,S1,Zero,Overflow,Negitive);
ALU_Cmp ALU2(Zero,Overflow,Negitive,ALUFun[3:1],S2);
ALU_Logic ALU3(DataA, DataB, ALUFun[3:0],S3);
ALU_Shift ALU4(DataA,DataB,ALUFun[1:0],S4);

always @(*)
begin
   case(ALUFun[5:4])
    2'b00 : Out = S1;
    2'b11 : Out = S2;
    2'b01 : Out = S3;
    2'b10 : Out = S4;
    endcase
end
endmodule


module ALU_AddSub(DataA,DataB,Op,Sign,S,Zero,Overflow,Negitive);
input [31:0]DataA,DataB;
reg[31:0]Temp_B;
input Op,Sign;              //sign = 1 stands for MSB
output Zero,Negitive,Overflow;
reg [32:0]Sum;
wire Overflow;            //Data is saved as the Bu Ma
assign ss = {DataA[31],DataB[31]};  //sign of two
always @(*) begin
   Temp_B = DataB;           //self
   if(Op == 1)begin            // Op = 1  for Add
      Sum = DataA + DataB;
   end
   if(Op == 0)begin           //Op = 0 for Sub
      Temp_B = ~DataB + 1
      Sum = DataA + Temp_B;
   end
end
assign Overflow = ~Sign ? Sum[32] :
(DataA[31]==Temp_B[31]) ? Sum[32]^ Sum[31] : 0;
assign S = Sum[31:0];
assign Zero = ~(|S);
assign Negitive = ~Sign ?  0 :
                  ((ss == 2'b11 && Op == 1)||(ss == 2'b10 && Op == 0))? 1 :
                  ((ss == 2'b00 && Op == 1)||(ss == 2'b01 && Op == 0))? 0 :
                  S[31];
endmodule

module ALU_Cmp(Zero,Overflow,Negitive,Op,S);
input Zero,Overflow,Negitive;
input [2:0]Op;
output reg [31:0] S;

always@(Zero or Overflow or Negitive or Op)
//??? if Overflow  what should we do?
// I Try to make the Negitive assign more complex
begin
 //if(Overflow) N = ~N;   // is it right??  //Nope
 case(Op)
   3'b000 : S <= {31'b0,Zero}; //Beq
   3'b001 : S <= {31'b0,~Zero}; // Bne
   3'b101 : S <= {31'b0,Negitive};  //slt..
   3'b100 : S <= {31'b0,Negitive|Zero}; //Blez
   3'b010 : S <= {31'b0, Negitive}; //Bltz
   3'b011 : S <= {31'b0,(~Negitive)&(~Zero)};//Bgtz
   default : S <= 0;
 endcase
end
endmodule

module ALU_Logic(DataA, DataB, Op ,S);

input [31:0] DataA, DataB;
input [3:0]Op;  // Funct[3:0]
output reg [31:0]S;

always@(DataA or DataB or Op)
begin
     case(Op)
       4'b1100 : S = DataA&DataB;
       4'b1101 : S = DataA|DataB;
       4'b1110 : S = DataA^DataB;
       4'b1111 : S = ~(DataA|DataB);
       default : S = 0;
     endcase
end
endmodule

module ALU_Shift(DataA,DataB,Op,S);

input [31:0]DataA, DataB;
input [1:0]Op;  //Fun[1:0]
output reg  [31:0]S;

always @(*)
begin
   case(Op)
     2'b00 : S = (DataB << DataA[4:0])  //sll
     2'b01 : S = (DataB >> DataA[4:0])  //srl
     2'b10 : S = ({{32{DataB[31]}}, DataB} >> DataA[4:0])
     default : S = 0;
     endcase
end
endmodule
