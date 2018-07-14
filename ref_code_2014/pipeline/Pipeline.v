module Pipeline(reset,sysclk, led, switch, digi1, digi2, digi3, digi4, UART_RX, UART_TX);
  input reset, sysclk;
  output [7:0] led;
  input [7:0] switch;
  output [6:0] digi1;
  output [6:0] digi2;
  output [6:0] digi3;
  output [6:0] digi4;
  input UART_RX;
  output UART_TX;
  
  reg [31:0] IF_PC;
  wire [31:0] IF_PC_plus_4;
  assign IF_PC_plus_4 = IF_PC + 32'd4;
  
  wire [31:0] PC_next;
  wire IF_PC_Write;	
  always @(negedge reset or posedge sysclk)
		if (~reset)
			IF_PC <= 32'h80000000;
		else if(IF_PC_Write)
			IF_PC <= PC_next;
	 
	wire [31:0] IF_Instruction;
	ROM ROM(.addr(IF_PC[30:0]), .data(IF_Instruction));
	
	wire IF_ID_Write,IF_ID_Flush;
	wire [31:0] ID_PC_plus_4,ID_Instruction;
  IF_ID  IF_ID1(.clk(sysclk),.reset(reset),
	         .IF_ID_Write(IF_ID_Write),
	         .IF_ID_Flush(IF_ID_Flush),
	         .IF_PC_4(IF_PC_plus_4),
	         .IF_Instruct(IF_Instruction),
	         .ID_PC_4(ID_PC_plus_4),
	         .ID_Instruct(ID_Instruction));
	         
	wire IRQ;
	wire [2:0] ID_PCSrc;
	wire [1:0] ID_RegDst;
	wire ID_RegWr;
	wire ID_ALUSrc1;
  wire ID_ALUSrc2;
  wire [5:0] ID_ALUFun;
  wire ID_Sign;
  wire ID_MemWr;
  wire ID_MemRd;
  wire [1:0] ID_MemToReg;
  wire ID_EXTOp;
  wire ID_LUOp;
	control  control(.OpCode(ID_Instruction[31:26]), .Funct(ID_Instruction[5:0]), .IRQ(IRQ),
    .PCSrc(ID_PCSrc), .RegDst(ID_RegDst), .RegWr(ID_RegWr),
    .ALUSrc1(ID_ALUSrc1), .ALUSrc2(ID_ALUSrc2), .ALUFun(ID_ALUFun), 
    .Sign(ID_Sign),.MemWr(ID_MemWr), .MemRd(ID_MemRd), .MemToReg(ID_MemToReg), 
    .EXTOp(ID_EXTOp), .LUOp(ID_LUOp));
    
  wire [31:0] ID_Ext_out;
	assign ID_Ext_out = {ID_EXTOp? {16{ID_Instruction[15]}}: 16'h0000, ID_Instruction[15:0]};
	
  wire [31:0] ID_LU_out;
	assign ID_LU_out = ID_LUOp? {ID_Instruction[15:0], 16'h0000}: ID_Ext_out;
	
	wire [31:0] ID_ConBA0;
	assign ID_ConBA0=ID_PC_plus_4+(ID_Ext_out << 2);
	
  wire ID_EX_Flush;
  wire [31:0] EX_ConBA0;
  wire [31:0] ID_DataBusA,ID_DataBusB;
  wire [2:0] EX_PCSrc;
	wire [1:0] EX_RegDst;
	wire EX_RegWr;
	wire EX_ALUSrc1;
  wire EX_ALUSrc2;
  wire [5:0] EX_ALUFun;
  wire EX_Sign;
  wire EX_MemWr;
  wire EX_MemRd;
  wire [1:0] EX_MemToReg;
  wire [31:0] EX_LU_out;
  wire [4:0] EX_Shamt,EX_Rd,EX_Rt,EX_Rs;
  wire [31:0] EX_PC_plus_4;
  wire [31:0] EX_DataBusA0,EX_DataBusB0;
  ID_EX ID_EX1(.clk(sysclk),.reset(reset),
	    .ID_EX_Flush(ID_EX_Flush),
			.ID_PCSrc(ID_PCSrc),.ID_RegDst(ID_RegDst),.ID_RegWr(ID_RegWr),.ID_ALUSrc1(ID_ALUSrc1),.ID_ALUSrc2(ID_ALUSrc2),
			.ID_ALUFun(ID_ALUFun),.ID_Sign(ID_Sign),.ID_MemWr(ID_MemWr),.ID_MemRd(ID_MemRd),.ID_MemToReg(ID_MemToReg),
			.ID_Imm32(ID_LU_out),.ID_ConBA0(ID_ConBA0),.ID_Shamt(ID_Instruction[10:6]),.ID_DataBusA(ID_DataBusA),.ID_DataBusB(ID_DataBusB),
			.ID_Rt(ID_Instruction[20:16]),.ID_Rs(ID_Instruction[25:21]),.ID_Rd(ID_Instruction[15:11]),
			.ID_PC_4(ID_PC_plus_4),
			.EX_PCSrc(EX_PCSrc),.EX_RegDst(EX_RegDst),.EX_RegWr(EX_RegWr),.EX_ALUSrc1(EX_ALUSrc1),.EX_ALUSrc2(EX_ALUSrc2),
			.EX_ALUFun(EX_ALUFun),.EX_Sign(EX_Sign),.EX_MemWr(EX_MemWr),.EX_MemRd(EX_MemRd),.EX_MemToReg(EX_MemToReg),
			.EX_Imm32(EX_LU_out),.EX_ConBA0(EX_ConBA0),.EX_Shamt(EX_Shamt),.EX_DataBusA(EX_DataBusA0),.EX_DataBusB(EX_DataBusB0),
			.EX_Rt(EX_Rt),.EX_Rs(EX_Rs),.EX_Rd(EX_Rd),
			.EX_PC_4(EX_PC_plus_4));
	
	
	wire [4:0] EX_Write_register;
	wire [4:0] WB_Write_register;
	wire [31:0] WB_WriteReg_Data;
	wire WB_RegWr;
	wire MEM_RegWr;
	wire [4:0] MEM_Write_register;
	wire [31:0] WB_WriteReg_Data_FOR;
	assign EX_Write_register = 
	     (EX_RegDst == 2'b00)? EX_Rd: 
	     (EX_RegDst == 2'b01)? EX_Rt: 
	     (EX_RegDst == 2'b10)? 5'd31 : 5'd26;
	RegFile register_file(.reset(reset),.clk(sysclk),.addr1(ID_Instruction[25:21]),.data1(ID_DataBusA),
		.addr2(ID_Instruction[20:16]),.data2(ID_DataBusB),.wr(MEM_RegWr),.addr3(MEM_Write_register),.data3(WB_WriteReg_Data_FOR));
	
  wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [31:0] EX_DataBusA,EX_DataBusB;
	wire [31:0] EX_ALUOut;
	assign ALU_in1 = EX_ALUSrc1? {27'h00000, EX_Shamt}: EX_DataBusA;
	assign ALU_in2 = EX_ALUSrc2? EX_LU_out: EX_DataBusB;
	ALU alu(.ALUFun(EX_ALUFun), .A(ALU_in1), .B(ALU_in2), .Sign(EX_Sign), .Out(EX_ALUOut));
	
	wire [31:0] EX_ConBA;
	assign  EX_ConBA = {EX_PC_plus_4[31],EX_ConBA0[30:0]};
	
	wire [31:0] EX_WriteData;
	wire [31:0] MEM_ALUOut;
	wire MEM_MemRd,MEM_MemWr;
	wire [1:0] MEM_MemToReg;
	wire [31:0] MEM_PC_plus_4;
	wire [31:0] MEM_WriteData;
	EX_MEM EX_MEM(.clk(sysclk),.reset(reset),
			.EX_ALUOut(EX_ALUOut),.EX_RegWr(EX_RegWr),.EX_MemToReg(EX_MemToReg),.EX_MemRd(EX_MemRd),.EX_MemWr(EX_MemWr),.EX_PC_4(EX_PC_plus_4),
			.EX_Write_addr(EX_Write_register),.EX_WriteData(EX_WriteData),
			.MEM_ALUOut(MEM_ALUOut),.MEM_RegWr(MEM_RegWr),.MEM_MemToReg(MEM_MemToReg),.MEM_MemRd(MEM_MemRd),.MEM_MemWr(MEM_MemWr),.MEM_PC_4(MEM_PC_plus_4),
			.MEM_Write_addr(MEM_Write_register),.MEM_WriteData(MEM_WriteData));
	
	wire [31:0] MEM_ReadData;
	wire [31:0] Read_data1;
	wire [31:0] Read_data2;
	wire MemWr1,MemWr2;
	wire [11:0] digi;
	assign MEM_ReadData = MEM_ALUOut[30] ? Read_data2 : Read_data1;
	assign MemWr1 = (MEM_MemWr && (~MEM_ALUOut[30]));
	assign MemWr2 = (MEM_MemWr && (MEM_ALUOut[30]));
 	DataMem data_memory(.reset(reset),.clk(sysclk),.addr(MEM_ALUOut), .rd(MEM_MemRd), .wr(MemWr1),.wdata(MEM_WriteData),.rdata(Read_data1));
 	Peripheral peripheral(.reset(reset),.sysclk(sysclk),.rd(MEM_MemRd),.wr(MemWr2),.addr(MEM_ALUOut),.wdata(MEM_WriteData),.rdata(Read_data2),.led(led),
		.switch(switch),.digi(digi),.UART_RX(UART_RX),.UART_TX(UART_TX),.irqout(IRQ),.PC_31(IF_PC[31]||ID_PC_plus_4[31]));
	digitube_scan   scan(.digi_in(digi),.digi_out1(digi1),.digi_out2(digi2),.digi_out3(digi3),.digi_out4(digi4));
	
	wire [1:0] WB_MemToReg;
	wire [31:0] WB_PC_plus_4;
	wire [31:0] WB_ALUOut;
	wire [31:0] WB_ReadData;
  MEM_WB MEM_WB(.clk(sysclk),.reset(reset),
			.MEM_RegWr(MEM_RegWr),.MEM_MemToReg(MEM_MemToReg),.MEM_Write_addr(MEM_Write_register),.MEM_PC_4(MEM_PC_plus_4),.MEM_ALUOut(MEM_ALUOut),.MEM_ReadData(MEM_ReadData),
			.WB_RegWr(WB_RegWr),.WB_MemToReg(WB_MemToReg),.WB_Write_addr(WB_Write_register),.WB_PC_4(WB_PC_plus_4),.WB_ALUOut(WB_ALUOut),.WB_ReadData(WB_ReadData));
	
	assign WB_WriteReg_Data = 
	         (WB_MemToReg == 2'b00)? WB_ALUOut: 
	         (WB_MemToReg == 2'b01)? WB_ReadData:
	         (WB_MemToReg == 2'b10)? WB_PC_plus_4: WB_PC_plus_4-4;
	         
	assign WB_WriteReg_Data_FOR = 
	         (MEM_MemToReg == 2'b00)? MEM_ALUOut: 
	         (MEM_MemToReg == 2'b01)? MEM_ReadData:
	         (MEM_MemToReg == 2'b10)? MEM_PC_plus_4: MEM_PC_plus_4-4;
	
  wire [31:0] ID_Jump_target;
	assign ID_Jump_target = {ID_PC_plus_4[31:28], ID_Instruction[25:0], 2'b00};

	
	wire [31:0] ILLOP;
	assign ILLOP = 32'h80000004;
	
	wire [2:0] PCSrc;
	assign PCSrc =((EX_PCSrc == 3'b001)&&(EX_ALUOut[0] == 1)) ? 3'b001:
	              (ID_PCSrc == 3'b001) ?3'b000 : ID_PCSrc;
	              
	wire [31:0] EX_ConBA_PC;
	assign EX_ConBA_PC = EX_ALUOut[0] ? EX_ConBA: EX_PC_plus_4;
	
	wire [31:0] DatabusA_JR;
	
	assign PC_next = 
	          (PCSrc == 3'b000)? IF_PC_plus_4 : 
	          (PCSrc == 3'b001)? EX_ConBA_PC :
	          (PCSrc == 3'b010)? ID_Jump_target :
	          (PCSrc == 3'b011)? DatabusA_JR :
		        (PCSrc == 3'b100)? ILLOP : 32'h80000008;
	        
	Hazard Hazard(.EX_Rt(EX_Rt),.EX_MemRd(EX_MemRd),.ID_Rs(ID_Instruction[25:21]),.ID_Rt(ID_Instruction[20:16]),.ID_PCSrc(ID_PCSrc),.EX_PCSrc(EX_PCSrc),.EX_ALUOut0(EX_ALUOut[0]),
			.IF_ID_Flush(IF_ID_Flush),.ID_EX_Flush(ID_EX_Flush),.IF_ID_Write(IF_ID_Write),.IF_PC_Write(IF_PC_Write));
	
	wire [1:0] ForwardA,ForwardB,ForwardM,ForwardJr;
	Forward Forward(.ID_PCSrc(ID_PCSrc),.ID_Rs(ID_Instruction[25:21]),
				.EX_ALUSrc1(EX_ALUSrc1),.EX_ALUSrc2(EX_ALUSrc2),.EX_Rs(EX_Rs),.EX_Rt(EX_Rt),.EX_Write_addr(EX_Write_register),.EX_RegWr(EX_RegWr),
				.MEM_Write_addr(MEM_Write_register),.MEM_RegWr(MEM_RegWr),
				.WB_Write_addr(WB_Write_register),.WB_RegWr(WB_RegWr),
				.ForwardA(ForwardA),.ForwardB(ForwardB),.ForwardM(ForwardM),.ForwardJr(ForwardJr)); 	
				
	 assign EX_DataBusA = 
	               (ForwardA == 2'b00) ? EX_DataBusA0 :
	               (ForwardA == 2'b01) ? WB_WriteReg_Data :
	               (ForwardA == 2'b10) ? MEM_ALUOut : 32'b0;
	               
	 assign EX_DataBusB = 
	               (ForwardB == 2'b00) ? EX_DataBusB0 :
	               (ForwardB == 2'b01) ? WB_WriteReg_Data :
	               (ForwardB == 2'b10) ? MEM_ALUOut : 32'b0;
	  
	 assign EX_WriteData = 
	               (ForwardM == 2'b00) ? EX_DataBusB0 :
	               (ForwardM == 2'b01) ? WB_WriteReg_Data :
	               (ForwardM == 2'b10) ? MEM_ALUOut : 32'b0;
	               
	 assign DatabusA_JR =
	               (ForwardJr == 2'b00) ? ID_DataBusA :
	               (ForwardJr == 2'b01) ? WB_WriteReg_Data :
	               (ForwardJr == 2'b10) ? MEM_ALUOut : EX_ALUOut;
	             
endmodule
