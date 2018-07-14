module ALU(A,B,ALUFun,Sign,Z);
    input [31:0] A,B;
    input [5:0]  ALUFun;
    input Sign;
    output reg[31:0]  Z;
    wire[31:0] adderout,CMPout,Logicout,Shiftout;
    wire zero,neg,over;
    ALU_adder add(.A(A),.B(B),.ALUFun(ALUFun),.Sign(Sign),.S(adderout),.Z(zero),.N(neg),.V(over));
    ALU_CMP   cmp(.Z(zero),.V(over),.N(neg),.ALUFun(ALUFun),.S(CMPout));
    ALU_Logic log(.A(A),.B(B),.ALUFun(ALUFun),.S(Logicout));
    ALU_Shift shift(.A(A),.B(B),.ALUFun(ALUFun),.S(Shiftout));
    always @(*)
    begin
      case(ALUFun[5:4])
        2'b00:Z<=adderout;
        2'b11:Z<=CMPout;
        2'b01:Z<=Logicout;
        2'b10:Z<=Shiftout;
    endcase
  end
        
endmodule
