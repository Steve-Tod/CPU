module Pipe_MEM_MEMWB(clk,reset,led,AN,digital,IRQ,EXMEM,MEMWB,UART_TXD,RX_DATA,TX_EN,TX_STATUS,RX_STATUS);
  input clk,reset,TX_STATUS,RX_STATUS;
  input[72:0] EXMEM;
  input[7:0] RX_DATA;
  output[7:0] digital,led,UART_TXD;
  output[3:0] AN;
  output IRQ,TX_EN;
  output[70:0] MEMWB;
  wire[31:0] ReadData;
CPU_RAM MEM(.clk(clk),.reset(reset),.Addr(EXMEM[31:0]),.WriteData(EXMEM[63:32]),.MemRd(EXMEM[71]),.MemWr(EXMEM[72]),
            .ReadData(ReadData),.led(led),.AN(AN),.digital(digital),.inter(IRQ),.UART_TXD(UART_TXD),
            .RX_DATA(RX_DATA),.TX_EN(TX_EN),.TX_STATUS(TX_STATUS),.RX_STATUS(RX_STATUS));
Pipe_MEMWB pipememwb(.clk(clk),.reset(reset),.ReadData(ReadData),
                     .EXMEM({EXMEM[70:64],EXMEM[31:0]}),.MEMWB(MEMWB));
endmodule