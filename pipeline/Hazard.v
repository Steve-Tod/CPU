module Hazard (ID_rs, ID_rt, ID_PCSrc,
               EX_PCSrc, EX_rt, EX_MemRead, EX_ALUOut0, 
               IF_ID_Flush, IF_ID_Write,
               ID_EX_Flush, IF_PC_Write);

input   EX_MemRead, EX_ALUOut0;
input   [2:0]   ID_PCSrc, EX_PCSrc;
input   [4:0]   ID_rs, ID_rt, EX_rt;

output  IF_ID_Flush, IF_ID_Write, ID_EX_Flush, IF_PC_Write;

reg [2:0]   IF_ID_Write_enable, IF_PC_Write_enable,
            ID_EX_Flush_enable, IF_ID_Flush_enable;

always @(*) begin
    // Load-use
    if (EX_MemRead && ((EX_rt == ID_rs) || (EX_rt == ID_rt))) begin
    //we stall, IF_PC stocked , and the ins in the IF cant transmit to ID, and create a nop ins(do nothing )
        IF_PC_Write_enable[0] <= 0; // stall
        IF_ID_Write_enable[0] <= 0;
        ID_EX_Flush_enable[0] <= 1; //flush, generate bubble
        IF_ID_Flush_enable[0] <= 0;
    end
    else begin
    // if not load-use we go on
        IF_PC_Write_enable[0] <= 1;
        IF_ID_Write_enable[0] <= 1;
        ID_EX_Flush_enable[0] <= 0;
        IF_ID_Flush_enable[0] <= 0;
    end

    // j
    // when we get the ins in ID is a j-type(and jr jalr),the ins in IF is wrong, we flush it
    if ((ID_PCSrc == 3'b010) || (ID_PCSrc == 3'b011) || 
        (ID_PCSrc == 3'b100) || (ID_PCSrc == 3'b101)) begin
    //ID ins was stock and soon ,PC change to JT
        IF_PC_Write_enable[1] <= 1;
        IF_ID_Write_enable[1] <= 1;
        ID_EX_Flush_enable[1] <= 0;
        IF_ID_Flush_enable[1] <= 1; // new PC+4  and  IF_ID_Flush make the ID cant transmit to IF
    end
    else begin
        IF_PC_Write_enable[1] <= 1;
        IF_ID_Write_enable[1] <= 1;
        ID_EX_Flush_enable[1] <= 0;
        IF_ID_Flush_enable[1] <= 0;
    end

    //branch
    if ((EX_PCSrc == 3'b001) && EX_ALUOut0)
    begin
    //make ID IF nop
        IF_PC_Write_enable[2] = 1;
		IF_ID_Write_enable[2] = 1;
		ID_EX_Flush_enable[2] = 1;
		IF_ID_Flush_enable[2] = 1;
    end
    else begin
        IF_PC_Write_enable[2] = 1;
		IF_ID_Write_enable[2] = 1;
		ID_EX_Flush_enable[2] = 0;
		IF_ID_Flush_enable[2] = 0;
    end
end

assign ID_EX_Flush = ID_EX_Flush_enable[0] | ID_EX_Flush_enable[1] | ID_EX_Flush_enable[2];
assign IF_ID_Flush = IF_ID_Flush_enable[0] | IF_ID_Flush_enable[1] | IF_ID_Flush_enable[2];

assign IF_ID_Write = IF_ID_Write_enable[0] & IF_ID_Write_enable[1] & IF_ID_Write_enable[2];
assign IF_PC_Write = IF_PC_Write_enable[0] & IF_PC_Write_enable[1] & IF_PC_Write_enable[2];

endmodule