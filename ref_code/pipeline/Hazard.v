module Hazard(EX_Rt,EX_MemRd,ID_Rs,ID_Rt,ID_PCSrc,EX_PCSrc,EX_ALUOut0,
			IF_ID_Flush,ID_EX_Flush,IF_ID_Write,IF_PC_Write);
input [4:0] EX_Rt,ID_Rs,ID_Rt;
input [2:0] ID_PCSrc,EX_PCSrc;
input EX_ALUOut0,EX_MemRd;
output IF_PC_Write,IF_ID_Write,ID_EX_Flush,IF_ID_Flush;
reg [2:0] IF_PC_Write_enable,IF_ID_Write_enable,ID_EX_Flush_enable,IF_ID_Flush_enable;

always@(*) 
begin
	//[0], judge load-use
	if(EX_MemRd && ((EX_Rt == ID_Rs) || (EX_Rt == ID_Rt)))  begin
	//ID state is using Rs and Rt; load is using Rt
	//read Mem ==> load
		IF_PC_Write_enable[0] = 0;//load-use竞争; doesn't write the next insruction's PC or IFID; still use it
		IF_ID_Write_enable[0] = 0;
		ID_EX_Flush_enable[0] = 1;//清空ID_EX，产生气泡; 之后转发到ID的多路选择器，选择ALU的操作数
		IF_ID_Flush_enable[0] = 0;//don't flush IF_ID, in next T (after nop) it will work again
	end
	else 
	begin
		IF_PC_Write_enable[0] = 1;
		IF_ID_Write_enable[0] = 1;
		ID_EX_Flush_enable[0] = 0;
		IF_ID_Flush_enable[0] = 0;
	end
end

always@(*) 
begin
	//[1], judge J 
	//010 J
	//011 Ra
	//100 stop
	//101 wrong
	if((ID_PCSrc == 3'b010) || (ID_PCSrc == 3'b011) || (ID_PCSrc == 3'b100) || (ID_PCSrc == 3'b101)) begin
		IF_PC_Write_enable[1] = 1;//write the new PC
		IF_ID_Write_enable[1] = 1;//write the new control
		ID_EX_Flush_enable[1] = 0;//don't flush ID_EX, we are not here yet. It happens at ID
		IF_ID_Flush_enable[1] = 1;//flush IF_ID
	end
	else 
	begin
		IF_PC_Write_enable[1] = 1;
		IF_ID_Write_enable[1] = 1;
		ID_EX_Flush_enable[1] = 0;
		IF_ID_Flush_enable[1] = 0;
	end
end

always@(*) begin
	//[2], judge 
	if(EX_PCSrc == 3'b001 && EX_ALUOut0)
	begin
		IF_PC_Write_enable[2] = 1;//write the new PC and control
		IF_ID_Write_enable[2] = 1;
		ID_EX_Flush_enable[2] = 1;//flush both ID_EX and IF_ID
		IF_ID_Flush_enable[2] = 1;//It happen at EX, there are 2 instructions
	end
	else 
	begin
		IF_PC_Write_enable[2] = 1;
		IF_ID_Write_enable[2] = 1;
		ID_EX_Flush_enable[2] = 0;
		IF_ID_Flush_enable[2] = 0;
	end
end
//as long as one needs to flush, then flush
assign ID_EX_Flush = ID_EX_Flush_enable[0] | ID_EX_Flush_enable[1] | ID_EX_Flush_enable[2];
assign IF_ID_Flush = IF_ID_Flush_enable[0] | IF_ID_Flush_enable[1] | IF_ID_Flush_enable[2];

assign IF_ID_Write = IF_ID_Write_enable[0] & IF_ID_Write_enable[1] & IF_ID_Write_enable[2];
assign IF_PC_Write = IF_PC_Write_enable[0] & IF_PC_Write_enable[1] & IF_PC_Write_enable[2];
endmodule