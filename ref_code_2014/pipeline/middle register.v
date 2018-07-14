

//Register between IF AND ID
module IF_ID(clk,reset,//clock and reset
	         IF_ID_Write,//write register
	         IF_ID_Flush,//interrupt erro control
	         IF_PC_4,//PC+4
	         IF_Instruct,ID_PC_4,
	         ID_Instruct);//ID instruction
input [31:0] IF_Instruct,IF_PC_4;
input IF_ID_Write,IF_ID_Flush,clk,reset;
output reg [31:0] ID_Instruct,ID_PC_4;

always@(posedge clk or negedge reset) begin
	if(~reset) //reset
	begin
		ID_PC_4 <= 32'h80000000;
		ID_Instruct <= 32'b0;
	end
	else if(IF_ID_Flush) //interrupt error
	begin
		ID_PC_4 <= 32'h80000000;
		ID_Instruct <= 32'b0;
	end
	else if(IF_ID_Write) //normal
	begin
		ID_PC_4 <= IF_PC_4;
		ID_Instruct <= IF_Instruct;
	end
end
endmodule





//Register between ID AND EX
module ID_EX(clk,reset,//clock and reset
	        ID_EX_Flush,//interrupt  error
			ID_PCSrc,ID_RegDst,ID_RegWr,ID_ALUSrc1,ID_ALUSrc2,//ID control_info
			ID_ALUFun,ID_Sign,ID_MemWr,ID_MemRd,ID_MemToReg,
			ID_Imm32,ID_ConBA0,ID_Shamt,ID_DataBusA,ID_DataBusB,
			ID_Rt,ID_Rs,ID_Rd,//ID register info
			ID_PC_4,//ID PC info
			EX_PCSrc,EX_RegDst,EX_RegWr,EX_ALUSrc1,EX_ALUSrc2,//EX control_info
			EX_ALUFun,EX_Sign,EX_MemWr,EX_MemRd,EX_MemToReg,
			EX_Imm32,EX_ConBA0,EX_Shamt,EX_DataBusA,EX_DataBusB,
			EX_Rt,EX_Rs,EX_Rd,//EX register info
			EX_PC_4);//EX PC info
 input [31:0]ID_PC_4,ID_Imm32,ID_DataBusA,ID_DataBusB,ID_ConBA0;
 input [5:0]ID_ALUFun;
 input [4:0]ID_Rs,ID_Rt,ID_Rd,ID_Shamt;
 input [2:0]ID_PCSrc;
 input [1:0]ID_MemToReg,ID_RegDst;
 input ID_RegWr,ID_ALUSrc1,ID_ALUSrc2,ID_Sign,ID_MemWr,ID_MemRd;
 input ID_EX_Flush,clk,reset;
 output reg [31:0]EX_PC_4,EX_Imm32,EX_DataBusA,EX_DataBusB,EX_ConBA0;
 output reg [5:0]EX_ALUFun;
 output reg [4:0]EX_Rs,EX_Rt,EX_Rd,EX_Shamt;
 output reg [2:0]EX_PCSrc;
 output reg [1:0]EX_MemToReg,EX_RegDst;
 output reg EX_RegWr,EX_ALUSrc1,EX_ALUSrc2,EX_Sign,EX_MemWr,EX_MemRd;

 always @(posedge clk or negedge reset) begin
	if(~reset) //reset
	begin
		EX_PC_4 <= 32'h80000000;
		EX_Imm32 <= 32'b0;
		EX_DataBusA <= 32'b0;
		EX_DataBusB <= 32'b0;
		EX_Shamt <= 5'b0;
		EX_ConBA0 <= 32'b0;
		EX_ALUFun <= 6'b0;
		EX_Rd <= 5'b0;
		EX_Rs <= 5'b0;
		EX_Rt <= 5'b0;
		EX_PCSrc <= 3'b0;
		EX_RegDst <= 2'b0;
		EX_MemToReg <= 2'b0;
		EX_RegWr <= 0;
		EX_ALUSrc1 <= 0;
		EX_ALUSrc2 <= 0;
		EX_Sign <= 0;
		EX_MemWr <= 0;
		EX_MemRd <= 0;
	end
	else if(ID_EX_Flush) //interrupt error
	begin
		EX_Imm32 <= 32'b0;
		EX_DataBusA <= 32'b0;
		EX_DataBusB <= 32'b0;
		EX_Shamt <= 5'b0;
		EX_ConBA0 <= 32'b0;
		EX_ALUFun <= 6'b0;
		EX_Rd <= 5'b0;
		EX_Rs <= 5'b0;
		EX_Rt <= 5'b0;
		EX_PCSrc <= 3'b0;
		EX_RegDst <= 2'b0;
		EX_MemToReg <= 2'b0;
		EX_RegWr <= 0;
		EX_ALUSrc1 <= 0;
		EX_ALUSrc2 <= 0;
		EX_Sign <= 0;
		EX_MemWr <= 0;
		EX_MemRd <= 0;
	end
	else 
	begin //normal
		EX_PC_4 <= ID_PC_4;
		EX_Imm32 <= ID_Imm32;
		EX_DataBusA <= ID_DataBusA;
		EX_DataBusB <= ID_DataBusB;
		EX_Shamt <= ID_Shamt;
		EX_ConBA0 <= ID_ConBA0;
		EX_ALUFun <= ID_ALUFun;
		EX_Rd <= ID_Rd;
		EX_Rs <= ID_Rs;
		EX_Rt <= ID_Rt;
		EX_PCSrc <= ID_PCSrc;
		EX_RegDst <= ID_RegDst;
		EX_MemToReg <= ID_MemToReg;
		EX_RegWr <= ID_RegWr;
		EX_ALUSrc1 <= ID_ALUSrc1;
		EX_ALUSrc2 <= ID_ALUSrc2;
		EX_Sign <= ID_Sign;
		EX_MemWr <= ID_MemWr;
		EX_MemRd <= ID_MemRd;
	end
 end
endmodule





//Register between Ex AND MEM
module EX_MEM(clk,reset,//clock reset
			EX_ALUOut,EX_RegWr,EX_MemToReg,EX_MemRd,EX_MemWr,EX_PC_4,//EX control info
			EX_Write_addr,EX_WriteData,
			MEM_ALUOut,MEM_RegWr,MEM_MemToReg,MEM_MemRd,MEM_MemWr,MEM_PC_4,//MEM control info
			MEM_Write_addr,MEM_WriteData);
input [31:0] EX_PC_4,EX_ALUOut,EX_WriteData;
input [4:0] EX_Write_addr;
input [1:0] EX_MemToReg;
input EX_RegWr,EX_MemRd,EX_MemWr;
input clk,reset;
output reg [31:0] MEM_PC_4,MEM_ALUOut,MEM_WriteData;
output reg [4:0] MEM_Write_addr;
output reg [1:0] MEM_MemToReg;
output reg MEM_RegWr,MEM_MemRd,MEM_MemWr;
always@(negedge reset or posedge clk) begin
	if(~reset) begin
		MEM_PC_4 <= 32'h80000000;
		MEM_ALUOut <= 32'b0;
		MEM_WriteData <= 32'b0;
		MEM_Write_addr <= 5'b0;
		MEM_MemToReg <= 2'b0;
		MEM_RegWr <= 0;
		MEM_MemRd <= 0;
		MEM_MemWr <= 0;
	end
	else begin
		MEM_PC_4 <= EX_PC_4;
		MEM_ALUOut <= EX_ALUOut;
		MEM_WriteData <= EX_WriteData;
		MEM_Write_addr <= EX_Write_addr;
		MEM_MemToReg <= EX_MemToReg;
		MEM_RegWr <= EX_RegWr;
		MEM_MemRd <= EX_MemRd;
		MEM_MemWr <= EX_MemWr;
	end
end
endmodule

module MEM_WB(clk,reset,
			MEM_RegWr,MEM_MemToReg,MEM_Write_addr,MEM_PC_4,MEM_ALUOut,MEM_ReadData,
			WB_RegWr,WB_MemToReg,WB_Write_addr,WB_PC_4,WB_ALUOut,WB_ReadData);
input [31:0] MEM_PC_4,MEM_ALUOut,MEM_ReadData;
input [4:0] MEM_Write_addr;
input [1:0] MEM_MemToReg;
input MEM_RegWr;
input clk,reset;
output reg [31:0] WB_PC_4,WB_ALUOut,WB_ReadData;
output reg [4:0] WB_Write_addr;
output reg [1:0] WB_MemToReg;
output reg WB_RegWr;
always@(posedge clk or negedge reset) begin
	if(~reset) begin 
		WB_PC_4 <= 32'h80000000;
		WB_ALUOut <= 32'b0;
		WB_ReadData <= 32'b0;
		WB_Write_addr <= 5'b0;
		WB_MemToReg <= 2'b0;
		WB_RegWr <= 0;
	end
	else begin
		WB_PC_4 <= MEM_PC_4;
		WB_ALUOut <= MEM_ALUOut;
		WB_ReadData <= MEM_ReadData;
		WB_Write_addr <= MEM_Write_addr;
		WB_MemToReg <= MEM_MemToReg;
		WB_RegWr <= MEM_RegWr;
	end
 end
 endmodule

