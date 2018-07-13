//compile
//000 001 add     000 000 sub

//110 000 beq     110 010 bne    110 100 bltz    110 110 bgtz
//111 000 blez    111 010 slt slti sltiu

//101 100 sll     101 101 srl    101 110 sra

//011 100 and     011 101 or     011 110 xor    011 111 nor

module Control(OpCode, Funct, IRQ
	PCSrc, Sign, RegWrite, RegDst, 
	MemRead, MemWrite, MemtoReg, 
	ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUFun);

	input [5:0] OpCode;
	input [5:0] Funct;
    input IRQ;

	output [2:0] PCSrc;
	output Sign;
	output RegWrite;
	output [1:0] RegDst;
	output MemRead;
	output MemWrite;
	output [1:0] MemtoReg;
	output ALUSrc1;
	output ALUSrc2;
	output ExtOp;
	output LuOp;
	output [5:0] ALUFun;

    parameter ALUADD = 6'b00_0001;
    parameter ALUSUB = 6'b00_0000;
    parameter ALUAND = 6'b01_1100;
    parameter ALUOR  = 6'b01_1101;
    parameter ALUXOR = 6'b01_1110;
    parameter ALUNOR = 6'b01_1111;
    parameter ALUSLL = 6'b10_1100;
    parameter ALUSRL = 6'b10_1101;
    parameter ALUSRA = 6'b10_1110;
    parameter ALUEQ = 6'b11_0000;
    parameter ALUNEQ = 6'b11_0010;
    parameter ALULT = 6'b11_1010;
    parameter ALULEZ = 6'b11_1000;
    parameter ALULTZ = 6'b11_0100;
    parameter ALUGTZ = 6'b11_0110;  

    wire UnDefine;
    assign UnDefine =
    (    OpCode == 6'h00    ||
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
	
	assign PCSrc[2:0] =
        IRQ? 3'b100 :
        UnDefine? 3'b101 :
	(    OpCode == 6'h04 || 
         OpCode == 6'h05 || 
         OpCode == 6'h06 || 
         OpCode == 6'h07 || 
         OpCode == 6'h01) ? 3'b001:
	(    OpCode == 6'h02 || 
         OpCode == 6'h03) ? 3'b010:
	(    OpCpde == 6'h00 && 
        ( Funct == 6'h08 || Funct == 6'h09)) ? 3'b011 : 3'b000;
	assign Sign = 
    //exist question
	(   (OpCode == 6'h00 && 
        (Funct == 6'h20  || Funct == 6'h22)) || 
        OpCode == 6'h08 || 
        OpCode == 6'h0a || 
        OpCode == 6'h01 || 
        OpCode == 6'h04 || 
        OpCode == 6'h05 ||
        OpCode == 6'h06 || 
        OpCode == 6'h07) ? 1:
		 0;
	assign RegWrite = 
        (IRQ || UnDefine)? 1 :   //We should keep the PC + 4 in this situation
	(   OpCode == 6'h2b || 
        OpCode == 6'h04 ||
        OpCode == 6'h02 || 
        OpCode == 6'h05 || 
        OpCode == 6'h06 || 
        OpCode == 6'h07 ||  
        OpCode == 6'h01 ||
        (OpCode == 6'h00 && Funct == 6'h08)) ? 0:
		1;
	assign RegDst[1:0] = 
        (IRQ || UnDefine)? 2'b11:
		(OpCode == 6'h00)? 2'b00:
		(OpCode == 6'h03)? 2'b10:
		2'b01;
	assign MemRead = 
		(OpCode == 6'h23)? 1:
		0;
	assign MemWrite = 
		(OpCode == 6'h2b)?1:
		0;
	assign MemtoReg[1:0]=
	(   UnDefine ||                    //choose PC + 4
        OpCode == 6'h03 || 
        (OpCode == 6'h00 && Funct == 6'h09))? 2'b10:
        IRQ? 2'b11:                   //If IRQ  we should keep the PC not PC+4
	//We should set the bus3 = PC when Mem2Reg == 3
    	(OpCode == 6'h23)? 2'b01:
        2'b00;
	assign ALUSrc1 = 
	(   OpCode == 6'h00 && 
        (Funct == 6'h00 || 
        Funct == 6'h02 || 
        Funct == 6'h03))? 1:
		0;
	assign ALUSrc2 =
	(   OpCode == 6'h00 || 
        OpCode == 6'h04 || 
        OpCode == 6'h05 || 
        OpCode == 6'h06 ||
        OpCode == 6'h07 || 
        OpCode == 6'h01 )? 0:
		1;
	assign ExtOp = 
    //exist question
		(OpCode == 6'h0c)? 0:
		1;
	assign LuOp = 
    //exist question
		(OpCode == 6'h0f)? 1:
		0;
	
    reg [5:0]ALUOp;
	always @(*)
        case (Funct)
            6'h00: ALUOp <= ALUSLL;
            6'h02: ALUOp <= ALUSRL;
            6'h03: ALUOp <= ALUSRA;
            6'h20: ALUOp <= ALUADD;
            6'h21: ALUOp <= ALUADD;
            6'h22: ALUOp <= ALUSUB;
            6'h23: ALUOp <= ALUSUB;
            6'h24: ALUOp <= ALUAND;
            6'h25: ALUOp <= ALUOR;
            6'h26: ALUOp <= ALUXOR;
            6'h27: ALUOp <= ALUNOR;
            6'h2a: ALUOp <= ALULT;
            default: aluFunct <= ALUADD;
        endcase
    always @(*)
        case (OpCode)
          6'h00: ALUFun <= ALUOp;
          6'h0c: ALUFun <= ALUAND;
          6'h04: ALUFun <= ALUEQ;
          6'h05: ALUFun <= ALUNEQ;
          6'h0a: ALUFun <= ALULT;
          6'h0b: ALUFun <= ALULT;
          6'h06: ALUFun <= ALULEZ;
          6'h01: ALUFun <= ALULTZ;
          6'h07: ALUFun <= ALUGTZ;
          default: ALUFun <= ALUADD;
        endcase    	
	
endmodule