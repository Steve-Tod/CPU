module Forward(ID_PCSrc,ID_Rs,
				EX_ALUSrc1,EX_ALUSrc2,EX_Rs,EX_Rt,EX_Write_addr,EX_RegWr,
				MEM_Write_addr,MEM_RegWr,
				WB_Write_addr,WB_RegWr,
				ForwardA,ForwardB,ForwardM,ForwardJr); 
input [4:0]ID_Rs,EX_Rs,EX_Rt,EX_Write_addr,MEM_Write_addr,WB_Write_addr;
input [2:0] ID_PCSrc;
input EX_ALUSrc1,EX_ALUSrc2,EX_RegWr,MEM_RegWr,WB_RegWr;
output reg [1:0] ForwardA,ForwardB,ForwardM,ForwardJr;
always@(*) 
begin
	//A forward BusA
	//B forward BusB
	//M forward the data going to Mem, when sw
	if(MEM_RegWr && (MEM_Write_addr != 0) && (MEM_Write_addr == EX_Rs))
		ForwardA = 2'b10;
	else if(WB_RegWr && (WB_Write_addr != 0) && (WB_Write_addr == EX_Rs) && (MEM_Write_addr != EX_Rs))
		ForwardA = 2'b01;
	else ForwardA = 2'b00;
	if(MEM_RegWr && (MEM_Write_addr != 0) && (MEM_Write_addr == EX_Rt)) begin
		ForwardB = (EX_ALUSrc2 == 1)? 2'b00:2'b10;
		ForwardM = 2'b10;
	end
	else if(WB_RegWr && (WB_Write_addr != 0) && (WB_Write_addr == EX_Rt) &&(MEM_Write_addr != EX_Rt)) 
	begin
		ForwardB = (EX_ALUSrc2 ==1)? 2'b00:2'b01;
		ForwardM = 2'b01;
	end  
	else begin 
		ForwardB = 2'b00;
		ForwardM = 2'b00;
	end  
	//ID_DataBusA,WB_WriteReg_Data,MEM_ALUOut,EX_ALUOut
	//jr
	if((ID_PCSrc == 3'b011) && (ID_Rs == EX_Write_addr) && (EX_Write_addr != 0) && EX_RegWr)
		//EX to Reg
		//doesn't work
		ForwardJr = 2'b11;
	else if((ID_PCSrc == 3'b011) && MEM_RegWr && (MEM_Write_addr != 0) && (MEM_Write_addr == ID_Rs) && (ID_Rs != EX_Write_addr))
		//EX/Mem to Reg
		ForwardJr = 2'b10;
	else if((ID_PCSrc == 3'b011) && WB_RegWr && (WB_Write_addr != 0) && (ID_Rs == WB_Write_addr) && (ID_Rs != EX_Write_addr) && (ID_Rs != MEM_Write_addr))
		//Reg to Reg; write first, read after
		ForwardJr = 2'b01;
	else ForwardJr = 2'b00;
end   
endmodule