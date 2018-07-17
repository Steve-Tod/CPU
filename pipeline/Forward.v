module Forward (ID_PCSrc, ID_rs, 
                EX_ALUSrc1, EX_ALUSrc2,
                EX_rs, EX_rt, EX_WriteAddress, EX_RegWrite,
                MEM_WriteAddress, MEM_RegWrite,
                WB_WriteAddress, WB_RegWrite,
                ForwardA, ForwardB, ForwardM, ForwardJr);

input   EX_ALUSrc1, EX_ALUSrc2, EX_RegWrite, MEM_RegWrite, WB_RegWrite;
input   [2:0]   ID_PCSrc;
input   [4:0]   ID_rs, EX_rs, EX_rt, EX_WriteAddress,
                MEM_WriteAddress, WB_WriteAddress;

output  reg [1:0]   ForwardA, ForwardB, ForwardM, ForwardJr;

always @(*) begin
    // ForwardA
    if (MEM_RegWrite && (MEM_WriteAddress != 0) && (MEM_WriteAddress == EX_rs)) begin   //when we use a reg before it hasnt been written back
        ForwardA <= 2'b10;                                                          // the MEM Forward 
    end
    else if (WB_RegWrite && (WB_WriteAddress != 0) && (WB_WriteAddress == EX_rs) &&    // The WB Forward
             ((MEM_WriteAddress != EX_rs) || ~MEM_RegWrite)) begin
        ForwardA <= 2'b01;
    end
    else begin
        ForwardA <= 2'b00;
    end

    // ForwardB and ForwardM
    if (MEM_RegWrite && (MEM_WriteAddress != 0) && (MEM_WriteAddress == EX_rt)) begin
        // when ALU_Src == 1，DataBusB is imm，no need of the forward
        ForwardB <= EX_ALUSrc2 ? 2'b00: 2'b10;
        //writedata is special for the sw , we use the rt as the data,and rs and imm as addr
        ForwardM <= 2'b10;
    end
    else if (WB_RegWrite && (WB_WriteAddress != 0) && (WB_WriteAddress == EX_rt) &&
             ((MEM_WriteAddress != EX_rt) || ~MEM_RegWrite)) begin
        ForwardB <= EX_ALUSrc2 ? 2'b00: 2'b01;
        ForwardM <= 2'b10;     
    end
    else begin
        ForwardB <= 2'b00;
        ForwardM <= 2'b00;
    end

    // ForwardJr
    //if jr or jalr
    if (ID_PCSrc == 3'b011) begin
    //we find we are cal. the rs(like $31)
        if (WB_RegWrite && (WB_WriteAddress != 0) && 
                 (ID_rs != EX_WriteAddress) && (ID_rs == WB_WriteAddress)) begin
            ForwardJr <= 2'b01;
        end
        else if (MEM_RegWrite && (MEM_WriteAddress) != 0 && 
                 (ID_rs != EX_WriteAddress) && (MEM_WriteAddress == ID_rs)) begin
            // EX/MEM
            ForwardJr <= 2'b10;
        end
        else if (EX_RegWrite && (EX_WriteAddress != 0) && (ID_rs == EX_WriteAddress)) begin
            // ID/EX
            ForwardJr <= 2'b11;
        end
        else begin
            ForwardJr <= 2'b00;
        end
    end
    // make no sense
    else begin
        ForwardJr <= 2'b00;
    end
end

endmodule