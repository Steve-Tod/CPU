// IF/ID
module Reg_IF_ID (clk, reset, 
                  IF_Instruct, IF_PC_plus_4,
                  IF_ID_Write, IF_ID_Flush, 
                  ID_Instruct, ID_PC_plus_4);

input   clk, reset, IF_ID_Write, IF_ID_Flush;
input   [31:0]  IF_Instruct, IF_PC_plus_4;

output  reg [31:0]  ID_Instruct, ID_PC_plus_4;

always @(posedge clk or negedge reset) begin
    if (~reset || IF_ID_Flush) begin
        ID_PC_plus_4 <= 32'h80000000;
        ID_Instruct <= 32'h0;
    end
    else if (IF_ID_Write) begin
        ID_PC_plus_4 <= IF_PC_plus_4;
        ID_Instruct <= IF_Instruct;
    end
end

endmodule


// ID/EX
module Reg_ID_EX (clk, reset,
                  ID_EX_Flush, ID_PC_plus_4,
                  ID_PCSrc, ID_RegDst, ID_RegWrite,
                  ID_ALUSrc1, ID_ALUSrc2, ID_ALUFun,
                  ID_Sign, 
                  ID_MemWrite, ID_MemRead, ID_MemtoReg,
                  ID_Imm_Exted, ID_ConBA, ID_Shamt, 
                  ID_DataBus1, ID_DataBus2,
                  ID_rt, ID_rs, ID_rd,,
                  EX_PC_plus_4,
                  EX_PCSrc, EX_RegDst, EX_RegWrite,
                  EX_ALUSrc1, EX_ALUSrc2, EX_ALUFun,
                  EX_Sign,
                  EX_MemWrite, EX_MemRead, EX_MemtoReg,
                  EX_Imm_Exted, EX_ConBA, EX_Shamt,
                  EX_DataBus1, EX_DataBus2,
                  EX_rt, EX_rs, EX_rd);

input   clk, reset, ID_EX_Flush, ID_RegWrite,
        ID_ALUSrc1, ID_ALUSrc2, ID_Sign, ID_MemWrite, ID_MemRead;
input   [1:0]   ID_MemtoReg, ID_RegDst;
input   [2:0]   ID_PCSrc;
input   [4:0]   ID_rs, ID_rt, ID_rd, ID_Shamt;
input   [5:0]   ID_ALUFun;
input   [31:0]  ID_PC_plus_4, ID_Imm_Exted, 
                ID_DataBus1, ID_DataBus2, ID_ConBA;

output  reg EX_RegWrite, EX_ALUSrc1, EX_ALUSrc2, EX_Sign, EX_MemWrite, EX_MemRead;
output  reg [1:0]   EX_MemtoReg, EX_RegDst;
output  reg [2:0]   EX_PCSrc;
output  reg [4:0]   EX_rs, EX_rt, EX_rd, EX_Shamt;
output  reg [5:0]   EX_ALUFun;
output  reg [31:0]  EX_PC_plus_4, EX_Imm_Exted, 
                    EX_DataBus1, EX_DataBus2, EX_ConBA;

always @(posedge clk or negedge reset) begin
    if(~reset || ID_EX_Flush) begin
        EX_RegWrite <= 0;
        EX_ALUSrc1 <= 0;
        EX_ALUSrc2 <= 0;
        EX_Sign <= 0;
        EX_MemWrite <= 0;
        EX_MemRead <= 0;
        EX_MemtoReg <= 0;
        EX_RegDst <= 0;
        EX_PCSrc <= 0;
        EX_rs <= 0;
        EX_rt <= 0;
        EX_rd <= 0;
        EX_Shamt <= 0;
        EX_ALUFun <= 0;
        EX_Imm_Exted <= 0;
        EX_DataBus1 <= 0;
        EX_DataBus2 <= 0;
        EX_ConBA <= 0;
        if(~reset) 
            EX_PC_plus_4 <= 32'h80000000;
    end
    else begin
        EX_RegWrite <= ID_RegWrite;
        EX_ALUSrc1 <= ID_ALUSrc1;
        EX_ALUSrc2 <= ID_ALUSrc2;
        EX_Sign <= ID_Sign;
        EX_MemWrite <= ID_MemWrite;
        EX_MemRead <= ID_MemRead;
        EX_MemtoReg <= ID_MemtoReg;
        EX_RegDst <= ID_RegDst;
        EX_PCSrc <= ID_PCSrc;
        EX_rs <= ID_rs;
        EX_rt <= ID_rt;
        EX_rd <= ID_rd;
        EX_Shamt <= ID_Shamt;
        EX_ALUFun <= ID_ALUFun;
        EX_PC_plus_4 <= ID_PC_plus_4;
        EX_Imm_Exted <= ID_Imm_Exted;
        EX_DataBus1 <= ID_DataBus1;
        EX_DataBus2 <= ID_DataBus2;
        EX_ConBA <= ID_ConBA;
    end
end

endmodule

// EX/MEM
module Reg_EX_MEM (clk, reset,
                   EX_PC_plus_4,
                   EX_ALUOut,
                   EX_RegWrite, 
                   EX_MemWrite, EX_MemRead, EX_MemtoReg,
                   EX_WriteAddress, EX_WriteData,
                   MEM_PC_plus_4, 
                   MEM_ALUOut,
                   MEM_RegWrite,
                   MEM_MemWrite, MEM_MemRead, MEM_MemtoReg,
                   MEM_WriteAddress, MEM_WriteData);

input   clk, reset, EX_RegWrite, EX_MemRead, EX_MemWrite;
input   [1:0]   EX_MemtoReg;
input   [4:0]   EX_WriteAddress;
input   [31:0]  EX_PC_plus_4, EX_ALUOut, EX_WriteData;

output  reg MEM_RegWrite, MEM_MemRead, MEM_MemWrite;
output  reg [1:0]   MEM_MemtoReg;
output  reg [4:0]   MEM_WriteAddress;
output  reg [31:0]  MEM_PC_plus_4, MEM_ALUOut, MEM_WriteData;

always @(negedge reset or posedge clk) begin
    if (~reset) begin
        MEM_PC_plus_4 <= 0;
        MEM_ALUOut <= 0;
        MEM_RegWrite <= 0;
        MEM_MemWrite <= 0;
        MEM_MemRead <= 0;
        MEM_MemtoReg <= 0;
        MEM_WriteAddress <= 0;
        MEM_WriteData <= 0;
    end
    else begin
        MEM_PC_plus_4 <= EX_PC_plus_4;
        MEM_ALUOut <= EX_ALUOut;
        MEM_RegWrite <= EX_RegWrite;
        MEM_MemWrite <= EX_MemWrite;
        MEM_MemRead <= EX_MemRead;
        MEM_MemtoReg <= EX_MemtoReg;
        MEM_WriteAddress <= EX_WriteAddress;
        MEM_WriteData <= EX_WriteData;
    end
end

endmodule

// MEM/WB
module Reg_MEM_WB (clk, reset,
                   MEM_PC_plus_4,
                   MEM_RegWrite, MEM_MemtoReg,
                   MEM_WriteAddress, MEM_ALUOut, MEM_ReadData,
                   WB_PC_plus_4,
                   WB_RegWrite, WB_MemtoReg,
                   WB_WriteAddress, WB_ALUOut, WB_ReadData);

input   clk, reset, MEM_RegWrite;
input   [1:0]   MEM_MemtoReg;
input   [4:0]   MEM_WriteAddress;
input   [31:0]  MEM_PC_plus_4, MEM_ALUOut, MEM_ReadData;

output  reg WB_RegWrite;
output  reg [1:0]   WB_MemtoReg;
output  reg [4:0]   WB_WriteAddress;
output  reg [31:0]  WB_PC_plus_4, WB_ALUOut, WB_ReadData;

always @(posedge clk or negedge reset) begin
    if (~reset) begin
        WB_PC_plus_4 <= 0;
        WB_RegWrite <= 0;
        WB_MemtoReg <= 0;
        WB_WriteAddress <= 0;
        WB_ALUOut <= 0;
        WB_ReadData <= 0;
    end
    else begin
        WB_PC_plus_4 <= MEM_PC_plus_4;
        WB_RegWrite <= MEM_RegWrite;
        WB_MemtoReg <= MEM_MemtoReg;
        WB_WriteAddress <= MEM_WriteAddress;
        WB_ALUOut <= MEM_ALUOut;
        WB_ReadData <= MEM_ReadData;
    end
end

endmodule