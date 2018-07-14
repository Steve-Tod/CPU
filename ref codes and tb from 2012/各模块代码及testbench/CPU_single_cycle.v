module CPU_single_cycle(clk,reset,led,AN,digital,UART_TX,UART_RX,baud_rate_clock);
  input clk,reset,UART_RX,baud_rate_clock;
  output UART_TX;
  output[3:0] AN;
  output[7:0] digital,led;
  wire IRQ,RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp,TX_EN,TX_STATUS,RX_STATUS;
  wire[1:0] RegDst,MemToReg;
  wire[2:0] PCSrc;
  wire[4:0] Shamt,Rd,Rt,Rs,AddrC;
  wire[5:0] ALUFun;
  wire[7:0] TX_DATA,RX_DATA;
  wire[15:0] Imm16;
	wire[25:0] JT;
	wire[31:0] PC_plus,ConBA,DataBusA,DataBusB,DataBusC,Imm32,Imm,A,B,ALUOut,ReadData,Instruct,PC;
  
  CPU_PC cpuPC(clk,PCSrc,ALUOut[0],JT,ConBA,DataBusA,reset,PC);
  CPU_Instruction_Memorg cpuIns(.reset(reset),.PC(PC[8:2]),.Instruct(Instruct));
  CPU_Control Control(Instruct,PC[31],IRQ,JT,Imm16,Shamt,Rd,Rt,Rs,
                      PCSrc,RegDst,RegWr,ALUSrc1,ALUSrc2,ALUFun,
                      Sign,MemWr,MemRd,MemToReg,EXTOp,LUOp);
  mux4_1 m1(.c0(Rd),.c1(Rt),.c2(5'b11111),.c3(5'b11010),.s(RegDst),.y(AddrC));
  CPU_Registers Registers(clk,reset,Rs,Rt,AddrC,RegWr,DataBusC,PC,IRQ,DataBusA,DataBusB);
  CPU_Extender Extender(Imm16,EXTOp,Imm32);
  mux2_1 m2(.a(Imm32),.b({Imm16,16'b0}),.s(LUOp),.y(Imm));
  mux2_1 m3(.a(DataBusA),.b({27'b0,Shamt}),.s(ALUSrc1),.y(A));
  mux2_1 m4(.a(DataBusB),.b(Imm),.s(ALUSrc2),.y(B));
  ALU cpuALU(A,B,ALUFun,Sign,ALUOut); 
  assign PC_plus={PC[31],{PC[30:0]+31'b000_0000_0000_0000_0000_0000_0000_0100}};
  assign ConBA={PC[31],PC_plus[30:0]+{Imm32[28:0],2'b00}};
  CPU_UARTre uartre(reset,baud_rate_clock,UART_RX,RX_STATUS,RX_DATA,clk);
  CPU_UARTse uartse(baud_rate_clock,reset,TX_EN,TX_DATA,TX_STATUS,UART_TX,clk);
  CPU_RAM cpuRAM(clk,reset,ALUOut,DataBusB,MemRd,MemWr,ReadData,led,
                 AN,digital,IRQ,TX_DATA,RX_DATA,TX_EN,TX_STATUS,RX_STATUS);
	mux4_1 m5(.c0(ALUOut),.c1(ReadData),.c2(PC_plus),.c3(32'b0),.s(MemToReg),.y(DataBusC));
endmodule