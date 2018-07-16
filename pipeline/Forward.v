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
    if (MEM_RegWrite && (MEM_WriteAddress != 0) && (MEM_WriteAddress == EX_rs)) begin
        ForwardA <= 2'b10;
    end
    else if (WB_RegWrite && (WB_WriteAddress != 0) && (WB_WriteAddress == EX_rs) &&
             ((MEM_WriteAddress != EX_rs) || ~MEM_RegWrite)) begin
        ForwardA <= 2'b01;
    end
    else begin
        ForwardA <= 2'b00;
    end

    // ForwardB and ForwardM
    if (MEM_RegWrite && (MEM_WriteAddress != 0) && (MEM_WriteAddress == EX_rt)) begin
        // ALU_Src == 1时，第二个操作数是扩展的直接数，不需要转发
        ForwardB <= EX_ALUSrc2 ? 2'b00: 2'b10;
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
    if (ID_PCSrc == 3'b011) begin
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
    else begin
        ForwardJr <= 2'b00;
    end
end

endmodule