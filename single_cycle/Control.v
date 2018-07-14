module Control(PC,OpCode, Funct, IRQ ,
	PCSrc, Sign, RegWrite, RegDst, 
	MemRead, MemWrite, MemtoReg, 
	ALUSrc1, ALUSrc2, ExtOp, LuOp, ALUFun);

	input [5:0] OpCode;
	input [5:0] Funct;
    input IRQ;
    input PC;//PC[31]

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

    parameter ALUADD = 6'b00_0000;
    parameter ALUSUB = 6'b00_0001;
    parameter ALUAND = 6'b01_1000;
    parameter ALUOR  = 6'b01_1110;
    parameter ALUXOR = 6'b01_0110;
    parameter ALUNOR = 6'b01_0001;
    parameter ALUSLL = 6'b10_0000;
    parameter ALUSRL = 6'b10_0001;
    parameter ALUSRA = 6'b10_0011;
    parameter ALUEQ =  6'b11_0011;
    parameter ALUNEQ = 6'b11_0001;
    parameter ALULT =  6'b11_0101;
    parameter ALULEZ = 6'b11_1101;
    parameter ALULTZ = 6'b11_1011;
    parameter ALUGTZ = 6'b11_1111; 
    //add a function
    //i dont know how to use it
    //but it's requested
    parameter ALUA = 6'b01_1010; 


    wire UnDefine;
    assign UnDefine =
    (    OpCode == 6'h01    ||
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
         OpCode == 6'h2b) ? 1'b0 : 
    (   OpCode == 6'h00 &&
       (Funct == 6'h20 ||
        Funct == 6'h21 ||
        Funct == 6'h22 ||
        Funct == 6'h23 ||
        Funct == 6'h24 ||
        Funct == 6'h25 ||
        Funct == 6'h26 ||
        Funct == 6'h27 ||
        Funct == 6'h2a ||
        Funct == 6'h00 ||
        Funct == 6'h02 ||
        Funct == 6'h03 ||
        Funct == 6'h08 ||
        Funct == 6'h09 ||
        ) 
    )? 1'b0 : 1'b1; 


	XADR = ~PC & UnDefine;
    ILLOP = ~PC & IRQ;

	assign PCSrc[2:0] =
         ILLOP? 3'b100 :
         XADR? 3'b101 :
	(    OpCode == 6'h04 || 
         OpCode == 6'h05 || 
         OpCode == 6'h06 || 
         OpCode == 6'h07 || 
         OpCode == 6'h01) ? 3'b001:
	(    OpCode == 6'h02 || 
         OpCode == 6'h03) ? 3'b010:
	(    OpCode == 6'h00 && 
        ( Funct == 6'h08 || Funct == 6'h09)) ? 3'b011 : 3'b000;
	assign Sign = 
    //exist question
	(   (OpCode == 6'h00 && 
        (Funct == 6'h20 || Funct == 6'h22)) || 
        OpCode == 6'h08 || 
        OpCode == 6'h0a || 
        OpCode == 6'h01 || 
        OpCode == 6'h04 || 
        OpCode == 6'h05 ||
        OpCode == 6'h06 || 
        OpCode == 6'h07) ? 1:
		 0;
	assign RegWrite = 
        (ILLOP || XADR)? 1 :   //We should keep the PC + 4 in this situation
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
        (ILLOP || XADR)? 2'b11:
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
        XADR ? 2'b10:                  //choose PC + 4
        ILLOP ? 2'b11 :            //choose PC
	(    OpCode == 6'h03 || 
        (OpCode == 6'h00 && Funct == 6'h09))? 2'b10:
    	(OpCode == 6'h23)? 2'b01:
        2'b00;
	assign ALUSrc1 = 
	(   OpCode == 6'h00 && 
        (Funct == 6'h00 || 
        Funct == 6'h02  || 
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