module CPU(reset,sysclk, led, switch, 
digi1, digi2, digi3, digi4, 
UART_RX, UART_TX);

  input reset, sysclk;
  input [7:0] switch;
  input UART_RX;

  output [7:0] led;
  output [6:0] digi1,digi2,digi3,digi4;
  output UART_TX;
  
  reg [31:0] PC;
  wire [31:0] PC_next;
  always @(negedge reset or posedge sysclk)
  //different from the cpu hm，We use the neg of rst
		if (~reset)
			PC <= 32'h80000000;
		else
			PC <= PC_next;
	 
	wire [31:0] PC_plus_4;
	//We cant change the top
	assign PC_plus_4 = {PC[31],PC[30:0] + 31'd4};
	
	wire [31:0] Instruction;
    //PC[31] is meaningless in searching addr
	ROM Rom1(.addr(PC[30:0]), .Instruct(Instruction));
	
	wire IRQ;

	wire [1:0] RegDst;
	wire [2:0] PCSrc;
	wire Sign;
	wire MemRead;
	wire [1:0] MemtoReg;
	wire [5:0] ALUFun;
	wire ExtOp;
	wire LuOp;
	wire MemWrite;
	wire ALUSrc1;
	wire ALUSrc2;
	wire RegWrite;

	Control  Ctrl1(.PC(PC[31]),.OpCode(Instruction[31:26]), 
    .Funct(Instruction[5:0]), .IRQ(IRQ) ,
	.PCSrc(PCSrc), .Sign(Sign), .RegWrite(RegWrite), 
    .RegDst(RegDst), .MemRead(MemRead), 
    .MemWrite(MemWrite), .MemtoReg(MemtoReg), 
	.ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2),
    .ExtOp(ExtOp),  .LuOp(LuOp), .ALUFun(ALUFun));
  
    wire [31:0] Databus1, Databus2, Databus3;
	wire [4:0] Write_register;
	assign Write_register = 
	     (RegDst == 2'b00)? Instruction[15:11]: 
	     (RegDst == 2'b01)? Instruction[20:16]: 
	     (RegDst == 2'b10)? 5'd31 : 5'd26;
	RegFile RegF1(.reset(reset),.clk(sysclk),.Read_register1(Instruction[25:21]),.Read_data1(Databus1),
		.Read_register2(Instruction[20:16]),.Read_data2(Databus2),.RegWrite(RegWrite),
        .Write_register(Write_register),.Write_data(Databus3));	
	wire [31:0] Ext_out;
	assign Ext_out = {ExtOp? {16{Instruction[15]}}: 16'h0000, Instruction[15:0]};
	
	wire [31:0] LU_out;
	assign LU_out = LuOp? {Instruction[15:0], 16'h0000}: Ext_out;
	
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [31:0] ALU_out;
	assign ALU_in1 = ALUSrc1? {27'h00000, Instruction[10:6]}: Databus1;
	assign ALU_in2 = ALUSrc2? LU_out: Databus2;
	ALU ALU1(.ALUFun(ALUFun), .DataA(ALU_in1), .DataB(ALU_in2), .Sign(Sign), .ALUOut(ALU_out));
	
	wire [31:0] Read_data;
	wire [31:0] Read_data1;
	wire [31:0] Read_data2;
	wire MemWrite1,MemWrite2;
	wire [11:0] digi;
    //RAM addr 0x00000000 ~ 0x3FFFFFFF
    //Peri addr 0x40000000 ~ 0x7FFFFFFF 
	assign Read_data = ALU_out[30] ? Read_data2 : Read_data1;
	assign MemWrite1 = (MemWrite && ~ALU_out[30]);  //write the RAM
	assign MemWrite2 = (MemWrite && ALU_out[30]);   //write the peri
 	DataMem data_memory(.reset(reset),.clk(sysclk),.Address(ALU_out), 
     .MemRead(MemRead), .MemWrite(MemWrite1),.Write_data(Databus2),
     .Read_data(Read_data1));
 	Peripheral peripheral(.reset(reset),.clk(sysclk),.rd(MemRead),
     .wr(MemWrite2),.addr(ALU_out),.wdata(Databus2),.rdata(Read_data2),
     .led(led), .switch(switch),.digi(digi),.UART_RX(UART_RX),
     .UART_TX(UART_TX),.irqout(IRQ),.PC31(PC[31]));
	DigitubeScan scan(.digi_in(digi),.digi_out1(digi1),.digi_out2(digi2),.digi_out3(digi3),.digi_out4(digi4));

	assign Databus3 = 
	         (MemtoReg == 2'b00)? ALU_out: 
	         (MemtoReg == 2'b01)? Read_data:
			 (MemtoReg == 2'b10)? PC_plus_4 : PC;//ILLOP use the PC
	
    wire [31:0] Jump_target;
	assign Jump_target = {PC_plus_4[31:28], Instruction[25:0], 2'b00};
	
	wire [31:0] Branch_target;
    wire [31:0]ConBA;
    assign ConBA =  PC_plus_4 + {Ext_out[29:0], 2'b00};
	assign Branch_target = ALU_out[0] ? ConBA : PC_plus_4;
	
	wire [31:0] ILLOP,XADR;
	assign ILLOP = 32'h80000004;
    assign XADR = 32'h80000008;

	
	assign PC_next = 
	          (PCSrc == 3'b000)? PC_plus_4 : 
	          (PCSrc == 3'b001)? Branch_target :
	          (PCSrc == 3'b010)? Jump_target :
	          (PCSrc == 3'b011)? Databus1 :
		      (PCSrc == 3'b100)? ILLOP : XADR;
		        
endmodule
	             
  
  