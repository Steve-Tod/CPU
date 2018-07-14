module Pipe_IF(clk,reset,PCWrite,enable,Stall,PCSrc,ConBA,ALUOut,JT,DatabusA);
  input clk,reset,ALUOut,PCWrite,enable,Stall;
  input[2:0] PCSrc;
  input[31:0] ConBA,DatabusA;
  input[25:0] JT;
  output[31:0] Instruct,PC;
Pipe_PC pipepc(clk,PCSrc,ALUOut,JT,ConBA,DatabusA,reset,PCWrite,PC);
Pipe_Instruction_Memorg pipeins(.reset(reset),.PC({PC[31],PC[8:2]}),.enable(enable),.Instruct_o(Instruct));
  
