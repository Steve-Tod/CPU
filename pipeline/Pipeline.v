module Pipeline(reset,sysclk,led,switch,
digi1,digi2,digi3,digi4,UART_RX,UART_TX);

input reset,sysclk;
input [7:0]switch;
input UART_RX;
output [7:0]led;
output [6:0]digi1 , digi2, digi3, digi4;
output UART_TX;

//======IF=====//

reg [31:0] IF_PC;
wire [31:0] IF_PC_plus_4;
wire [31:0] IF_PC_next;
wire IF_PC_Write;//prepare for stoll
wire [31:0] IF_Instruction;
//------PC-----//

assign IF_PC_plus_4 = {IF_PC[31],IF_PC[30:0] + 31'd4 };
always@(negedge reset or posedge sysclk)
begin
    if(~reset)
        IF_PC <= 32'h8000_0000;
    else if (IF_PC_Write)
        IF_PC <= IF_PC_next;
end


//----Instruction----//

ROM rom1(.addr(IF_PC[30:0]),.Instruct(IF_Instruction));

//====ID====//
wire IRQ;
wire [2:0]ID_PCSrc;
wire [1:0]ID_RegDst;
wire ID_RegWrite;
wire ID_ALUSrc1;
wire ID_ALUSrc2;
wire [5:0] ID_ALUFun;
wire ID_Sign;
wire ID_MemWrite;
wire ID_MemRead;
wire [1:0] ID_MemtoReg;
wire ID_ExtOp;
wire ID_LuOp;
wire IF_ID_Write,IF_ID_Flush;
wire [31:0] ID_PC_plus_4,ID_Instruction;

Reg_IF_ID IF_ID1(.clk(sysclk), .reset(reset), 
                .IF_Instruct(IF_Instruction), .IF_PC_plus_4(IF_PC_plus_4),
                .IF_ID_Write(IF_ID_Write), 
                .IF_ID_Flush(IF_ID_Flush), 
                .ID_Instruct(ID_Instruction), .ID_PC_plus_4(ID_PC_plus_4));

//ID_PC_plus[31] stands for last IF_PC[31]
Control Ctrl1(.PC(IF_PC[31]||ID_PC_plus_4[31]),
    .OpCode(ID_Instruction[31:26]), 
    .Funct(ID_Instruction[5:0]), .IRQ(IRQ) ,
	.PCSrc(ID_PCSrc), .Sign(ID_Sign), 
    .RegWrite(ID_RegWrite), 
    .RegDst(ID_RegDst),
    .MemRead(ID_MemRead), 
    .MemWrite(ID_MemWrite), .MemtoReg(ID_MemtoReg), 
	.ALUSrc1(ID_ALUSrc1), .ALUSrc2(ID_ALUSrc2),
    .ExtOp(ID_ExtOp),  .LuOp(ID_LuOp), .ALUFun(ID_ALUFun));

wire [31:0]ID_Ext_Out;
assign ID_Ext_Out = 
    {ID_ExtOp?{16{ID_Instruction[15]}}: 16'h0000, ID_Instruction[15:0]};

wire [31:0]ID_Lu_Out;
assign ID_Lu_Out =
    ID_LuOp?{ID_Instruction[15:0], 16'h0000}: ID_Ext_Out;

wire [31:0]ID_ConBA0;
assign ID_ConBA0 = ID_PC_plus_4+(ID_Ext_Out << 2);
//RF we do it later

//=====EX=====//
wire ID_EX_Flush;
wire [31:0] EX_ConBA0;
wire [31:0] ID_DataBusA,ID_DataBusB;
wire [2:0] EX_PCSrc;
wire [1:0] EX_RegDst;
wire EX_RegWrite;
wire EX_ALUSrc1;
wire EX_ALUSrc2;
wire [5:0] EX_ALUFun;
wire EX_Sign;
wire EX_MemWrite;
wire EX_MemRead;
wire [1:0] EX_MemtoReg;
wire [31:0] EX_Lu_Out;
wire [4:0] EX_Shamt,EX_Rd,EX_Rt,EX_Rs;
wire [31:0] EX_PC_plus_4;
wire [31:0] EX_DataBusA0,EX_DataBusB0;
Reg_ID_EX ID_EX1(.clk(sysclk),.reset(reset),
	    	.ID_EX_Flush(ID_EX_Flush),
			.ID_PC_plus_4(ID_PC_plus_4),
			.ID_PCSrc(ID_PCSrc),
			.ID_RegDst(ID_RegDst),
			.ID_RegWrite(ID_RegWrite),
			.ID_ALUSrc1(ID_ALUSrc1),
			.ID_ALUSrc2(ID_ALUSrc2),
			.ID_ALUFun(ID_ALUFun),
			.ID_Sign(ID_Sign),
			.ID_MemWrite(ID_MemWrite),
			.ID_MemRead(ID_MemRead),
			.ID_MemtoReg(ID_MemtoReg),
			.ID_Imm_Exted(ID_Lu_Out),
			.ID_ConBA(ID_ConBA0),
			.ID_Shamt(ID_Instruction[10:6]),
			.ID_DataBus1(ID_DataBusA),
			.ID_DataBus2(ID_DataBusB),
			.ID_rt(ID_Instruction[20:16]),
			.ID_rs(ID_Instruction[25:21]),
			.ID_rd(ID_Instruction[15:11]),
			.EX_PC_plus_4(EX_PC_plus_4),
			.EX_PCSrc(EX_PCSrc),
			.EX_RegDst(EX_RegDst),
			.EX_RegWrite(EX_RegWrite),
			.EX_ALUSrc1(EX_ALUSrc1),
			.EX_ALUSrc2(EX_ALUSrc2),
			.EX_ALUFun(EX_ALUFun),
			.EX_Sign(EX_Sign),
			.EX_MemWrite(EX_MemWrite),
			.EX_MemRead(EX_MemRead),
			.EX_MemtoReg(EX_MemtoReg),
			.EX_Imm_Exted(EX_Lu_Out),
			.EX_ConBA(EX_ConBA0),
			.EX_Shamt(EX_Shamt),
			.EX_DataBus1(EX_DataBusA0),
			.EX_DataBus2(EX_DataBusB0),
			.EX_rt(EX_Rt),
			.EX_rs(EX_Rs),
			.EX_rd(EX_Rd));

wire [31:0] EX_ConBA;
//Branch cant change pc31
assign  EX_ConBA = 
            {EX_PC_plus_4[31],EX_ConBA0[30:0]};

wire [4:0] EX_Write_Register;
assign EX_Write_Register = 
	     (EX_RegDst == 2'b00)? EX_Rd: 
	     (EX_RegDst == 2'b01)? EX_Rt: 
	     (EX_RegDst == 2'b10)? 5'd31 : 5'd26;

//-----RF ----//
wire [31:0] WB_Write_Data_For;
wire MEM_RegWrite;
wire [4:0] MEM_Write_Register;

RegFile register_file1(.reset(reset),.clk(sysclk),.Read_register1(ID_Instruction[25:21]),.Read_data1(ID_DataBusA),.Read_register2(ID_Instruction[20:16]),.Read_data2(ID_DataBusB),.RegWrite(MEM_RegWrite),.Write_register(MEM_Write_Register),.Write_data(WB_Write_Data_For));

wire [31:0] ALU_in1;
wire [31:0] ALU_in2;
//Forwarding
wire [31:0] EX_DataBusA,EX_DataBusB;
wire [31:0] EX_ALUOut;	

assign ALU_in1 = 
        EX_ALUSrc1? {27'h00000, EX_Shamt}: EX_DataBusA;
assign ALU_in2 = 
        EX_ALUSrc2? EX_Lu_Out: EX_DataBusB;

ALU alu1(.ALUFun(EX_ALUFun), .DataA(ALU_in1), .DataB(ALU_in2), .Sign(EX_Sign), .ALUOut(EX_ALUOut));

//=====MEM=====//
wire [31:0] EX_WriteData;//Forwarding determine
wire [31:0] MEM_ALUOut;
wire MEM_MemRead,MEM_MemWrite;
wire [1:0] MEM_MemtoReg;
wire [31:0] MEM_PC_plus_4;
wire [31:0] MEM_WriteData;

Reg_EX_MEM EX_MEM(
            .clk(sysclk),.reset(reset),
			.EX_ALUOut(EX_ALUOut),.EX_RegWrite(EX_RegWrite),.EX_MemtoReg(EX_MemtoReg),.EX_MemRead(EX_MemRead),.EX_MemWrite(EX_MemWrite),.EX_PC_plus_4(EX_PC_plus_4),
			.EX_WriteAddress(EX_Write_Register),.EX_WriteData(EX_WriteData),
			.MEM_ALUOut(MEM_ALUOut),.MEM_RegWrite(MEM_RegWrite),.MEM_MemtoReg(MEM_MemtoReg),.MEM_MemRead(MEM_MemRead),.MEM_MemWrite(MEM_MemWrite),.MEM_PC_plus_4(MEM_PC_plus_4),
			.MEM_WriteAddress(MEM_Write_Register),.MEM_WriteData(MEM_WriteData));

wire [31:0] MEM_ReadData;
wire [31:0] Read_Data1;
wire [31:0] Read_Data2;
wire MemWrite1,MemWrite2;
wire [11:0] digi;
assign MEM_ReadData = 
        MEM_ALUOut[30] ? Read_Data2 : Read_Data1;
assign MemWrite1 = (MEM_MemWrite && (~MEM_ALUOut[30]));
assign MemWrite2 = (MEM_MemWrite && (MEM_ALUOut[30]));
DataMem data_memory1(.reset(reset),.clk(sysclk),.Address(MEM_ALUOut), .MemRead(MEM_MemRead), .MemWrite(MemWrite1),.Write_data(MEM_WriteData), .Read_data(Read_Data1));
Peripheral peripheral1(.reset(reset),.clk(sysclk),.rd(MEM_MemRead), .wr(MemWrite2),.addr(MEM_ALUOut),.wdata(MEM_WriteData),.rdata(Read_Data2), .led(led), .switch(switch),.digi(digi),.UART_RX(UART_RX), .UART_TX(UART_TX),.irqout(IRQ),.PC31(IF_PC[31]||ID_PC_plus_4[31]));
DigitubeScan scan1(.digi_in(digi),.digi_out1(digi1),.digi_out2(digi2),.digi_out3(digi3),.digi_out4(digi4));
	
//===========WB===============//

wire [31:0] WB_Write_Data;
wire [1:0] WB_MemtoReg;
wire [31:0] WB_PC_plus_4;
wire [31:0] WB_ALUOut;
wire [31:0] WB_ReadData;
wire [4:0] WB_Write_Register;
wire WB_RegWrite;

Reg_MEM_WB MEM_WB(.clk(sysclk),.reset(reset),
			.MEM_RegWrite(MEM_RegWrite),.MEM_MemtoReg(MEM_MemtoReg),.MEM_WriteAddress
            (MEM_Write_Register),.MEM_PC_plus_4(MEM_PC_plus_4),.MEM_ALUOut(MEM_ALUOut),.MEM_ReadData(MEM_ReadData),
			.WB_RegWrite(WB_RegWrite),.WB_MemtoReg(WB_MemtoReg),.WB_WriteAddress(WB_Write_Register),.WB_PC_plus_4(WB_PC_plus_4),.WB_ALUOut(WB_ALUOut),.WB_ReadData(WB_ReadData));

assign WB_Write_Data = 
	         (WB_MemtoReg == 2'b00)? WB_ALUOut: 
	         (WB_MemtoReg == 2'b01)? WB_ReadData:
	         (WB_MemtoReg == 2'b10)? WB_PC_plus_4: WB_PC_plus_4 - 4; //PC

assign WB_Write_Data_For =  
	         (MEM_MemtoReg == 2'b00)? MEM_ALUOut: 
	         (MEM_MemtoReg == 2'b01)? MEM_ReadData:
	         (MEM_MemtoReg == 2'b10)? MEM_PC_plus_4: MEM_PC_plus_4 - 4;//PC

//============FORWARDING AND HAZARD============//
wire [31:0] ID_Jump_target;
assign ID_Jump_target = 
    {ID_PC_plus_4[31:28], ID_Instruction[25:0], 2'b00};

wire [31:0] ILLOP,XADR;
assign ILLOP = 32'h80000004;
assign XADR = 32'h80000008;

wire [2:0] PCSrc;
assign PCSrc =   //pc choose
((EX_PCSrc == 3'b001)&&(EX_ALUOut[0] == 1)) ? 3'b001://Branch  we should first consider the pc
(ID_PCSrc == 3'b001) ?3'b000 : 
ID_PCSrc;

wire [31:0] EX_ConBA_PC;//Branch ,pc + 4 or ConBA
assign EX_ConBA_PC = EX_ALUOut[0] ? EX_ConBA: EX_PC_plus_4;


wire [1:0] ForwardA,ForwardB,ForwardM,ForwardJr;

wire [31:0] DatabusA_JR;
assign DatabusA_JR =
	               (ForwardJr == 2'b00) ? ID_DataBusA :
	               (ForwardJr == 2'b01) ? WB_Write_Data :
	               (ForwardJr == 2'b10) ? MEM_ALUOut : EX_ALUOut;

assign IF_PC_next = 
	          (PCSrc == 3'b000)? IF_PC_plus_4 : 
	          (PCSrc == 3'b001)? EX_ConBA_PC :
	          (PCSrc == 3'b010)? ID_Jump_target :
	          (PCSrc == 3'b011)? DatabusA_JR :
		      (PCSrc == 3'b100)? ILLOP : XADR;
//Hazard signal
Hazard Hazard(.ID_rs(ID_Instruction[25:21]),
        .ID_rt(ID_Instruction[20:16]),
        .ID_PCSrc(ID_PCSrc),
        .EX_rt(EX_Rt),
        .EX_PCSrc(EX_PCSrc),
        .EX_MemRead(EX_MemRead),
        .EX_ALUOut0(EX_ALUOut[0]),
        .IF_ID_Flush(IF_ID_Flush),
        .ID_EX_Flush(ID_EX_Flush),
        .IF_ID_Write(IF_ID_Write),
        .IF_PC_Write(IF_PC_Write));

 
Forward Forward(
    .ID_PCSrc(ID_PCSrc),
    .ID_rs(ID_Instruction[25:21]),
	.EX_ALUSrc1(EX_ALUSrc1),
    .EX_ALUSrc2(EX_ALUSrc2),
    .EX_rs(EX_Rs),.EX_rt(EX_Rt),
    .EX_WriteAddress(EX_Write_Register),
    .EX_RegWrite(EX_RegWrite),
	.MEM_WriteAddress(MEM_Write_Register),
    .MEM_RegWrite(MEM_RegWrite),
	.WB_WriteAddress(WB_Write_Register),
    .WB_RegWrite(WB_RegWrite),
	.ForwardA(ForwardA),
    .ForwardB(ForwardB),
    .ForwardM(ForwardM),
    .ForwardJr(ForwardJr)); 	
		
assign EX_DataBusA = 
	               (ForwardA == 2'b00) ? EX_DataBusA0 :
	               (ForwardA == 2'b01) ? WB_Write_Data :
	               (ForwardA == 2'b10) ? MEM_ALUOut : 32'b0;
	               
assign EX_DataBusB = 
	               (ForwardB == 2'b00) ? EX_DataBusB0 :
	               (ForwardB == 2'b01) ? WB_Write_Data :
	               (ForwardB == 2'b10) ? MEM_ALUOut : 32'b0;
                                    
assign EX_WriteData = 
	               (ForwardM == 2'b00) ? EX_DataBusB0 :
	               (ForwardM == 2'b01) ? WB_Write_Data :
	               (ForwardM == 2'b10) ? MEM_ALUOut : 32'b0;
	               
endmodule	
	

	