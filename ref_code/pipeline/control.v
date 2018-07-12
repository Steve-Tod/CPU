
module control(OpCode, Funct, IRQ,
    PCSrc, RegDst, RegWr,
    ALUSrc1, ALUSrc2, ALUFun, 
    Sign,MemWr, MemRd, MemToReg, 
    EXTOp, LUOp);
    input [5:0] OpCode;
    input [5:0] Funct;
    input IRQ;

    output [2:0] PCSrc;
    output [1:0] RegDst;
    output RegWr;
    output ALUSrc1;
    output ALUSrc2;
    output reg [5:0] ALUFun;
    output Sign;
    output MemWr;
    output MemRd;
    output [1:0] MemToReg;
    output EXTOp;
    output LUOp;
    
    wire undefINS;
    assign undefINS = 
        (OpCode == 6'h00    ||
         OpCode == 6'h01    ||
         OpCode == 6'h02    ||
         OpCode == 6'h03    ||
         OpCode == 6'h04    ||
         OpCode == 6'h05    ||
         OpCode == 6'h06    ||
         OpCode == 6'h07    ||
         OpCode == 6'h08    ||
         OpCode == 6'h09    ||
         OpCode == 6'h0a    ||
         OpCode == 6'h0b    ||
         OpCode == 6'h0c    ||
         OpCode == 6'h0f    ||
         OpCode == 6'h23    ||
         OpCode == 6'h2b) ? 1'b0 : 1'b1;
         
    assign PCSrc = 
        IRQ ? 3'd4 :
        undefINS ? 3'd5 :
        (OpCode == 6'h04   ||
         OpCode == 6'h05   ||
         OpCode == 6'h06   ||
         OpCode == 6'h07   ||
         OpCode == 6'h01) ? 3'd1 :
        (OpCode == 6'h02   ||
         OpCode == 6'h03) ? 3'd2 :
        (OpCode == 6'h00 && (Funct == 6'h08 || Funct == 6'h09)) ? 3'd3 : 3'd0;
        
    assign  RegDst =
        (IRQ || undefINS) ? 2'd3 :
        (OpCode == 6'h00) ? 2'd0 :
        (OpCode == 6'h03) ? 2'd2 : 2'd1;
    
    assign RegWr =
        (IRQ || undefINS) ? 1'b1 :
        (OpCode == 6'h02    ||
         OpCode == 6'h04    ||
         OpCode == 6'h05    ||
         OpCode == 6'h06    ||
         OpCode == 6'h07    ||
         OpCode == 6'h01    ||
         OpCode == 6'h2b    ||
         (OpCode == 6'h00) && (Funct ==6'h08) ) ? 1'b0 : 1'b1;
         
    assign ALUSrc1 =
        (OpCode == 6'h00   && 
        (Funct == 6'h00     ||
         Funct == 6'h02     ||
         Funct == 6'h03) ) ? 1'b1 : 1'b0;
        
    
    assign ALUSrc2 =
        (OpCode == 6'h00    ||
         OpCode == 6'h01    ||
         OpCode == 6'h04    ||
         OpCode == 6'h05    ||
         OpCode == 6'h06    ||
         OpCode == 6'h07) ? 1'b0 : 1'b1;
    
    assign MemWr =
        (OpCode == 6'h2b) ? 1'b1 : 1'b0;
        
    assign MemRd =
        (OpCode == 6'h23) ? 1'b1 : 1'b0;
        
    assign MemToReg =
        IRQ ? 2'd3 : 
        undefINS ? 2'd2 :
        (OpCode == 6'h23) ? 2'd1 : 
        (OpCode == 6'h03 || 
        (OpCode == 6'h00 && Funct == 6'h09)) ? 2'd2 :  
        2'd0;
        
    assign EXTOp =
        (OpCode == 6'h0c) ? 1'b0 : 1'b1;
        
    assign LUOp =
        (OpCode == 6'h0f) ? 1'b1 : 1'b0;
         
    
    assign Sign = 
        (OpCode == 6'h01  ||
         OpCode == 6'h04  ||
         OpCode == 6'h05  ||
         OpCode == 6'h06  ||
         OpCode == 6'h07) ? 1'b1 : 
        (OpCode == 6'h00) ? ~Funct[0]: ~OpCode[0];

    parameter aluADD = 6'b00_0000;
    parameter aluSUB = 6'b00_0001;
    parameter aluAND = 6'b01_1000;
    parameter aluOR  = 6'b01_1110;
    parameter aluXOR = 6'b01_0110;
    parameter aluNOR = 6'b01_0001;
    parameter aluA = 6'b01_1010;
    parameter aluSLL = 6'b10_0000;
    parameter aluSRL = 6'b10_0001;
    parameter aluSRA = 6'b10_0011;
    parameter aluEQ = 6'b11_0011;
    parameter aluNEQ = 6'b11_0001;
    parameter aluLT = 6'b11_0101;
    parameter aluLEZ = 6'b11_1101;
    parameter aluLTZ = 6'b11_1011;
    parameter aluGTZ = 6'b11_1111;   
    
   reg [5:0] aluFunct;
	 always @(*)
		case (Funct)
			6'b00_0000: aluFunct <= aluSLL;
			6'b00_0010: aluFunct <= aluSRL;
			6'b00_0011: aluFunct <= aluSRA;
			6'b10_0000: aluFunct <= aluADD;
			6'b10_0001: aluFunct <= aluADD;
			6'b10_0010: aluFunct <= aluSUB;
			6'b10_0011: aluFunct <= aluSUB;
			6'b10_0100: aluFunct <= aluAND;
			6'b10_0101: aluFunct <= aluOR;
			6'b10_0110: aluFunct <= aluXOR;
			6'b10_0111: aluFunct <= aluNOR;
			6'b10_1010: aluFunct <= aluLT;
			6'b10_1011: aluFunct <= aluLT;
			default: aluFunct <= aluADD;
		endcase
	
	always @(*)
		case (OpCode)
			6'h00: ALUFun <= aluFunct;
		  6'h0c: ALUFun <= aluAND;
		  6'h04: ALUFun <= aluEQ;
		  6'h05: ALUFun <= aluNEQ;
		  6'h0a: ALUFun <= aluLT;
		  6'h0b: ALUFun <= aluLT;
		  6'h06: ALUFun <= aluLEZ;
      6'h01: ALUFun <= aluLTZ;
      6'h07: ALUFun <= aluGTZ;
			default: ALUFun <= aluADD;
		endcase    
        
endmodule
      
    
      
      
        
    
        
        
    
        

         
    
    
    
    