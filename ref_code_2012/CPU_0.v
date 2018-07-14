module CPU_0(system_clk,reset,led,AN,digital,UART_RX,UART_TX);
  input system_clk,reset,UART_RX;
  output UART_TX;
  output[7:0] led,digital;
  output[3:0] AN;
  wire clk,baud_rate_clock;
  CPU_clk clock(system_clk,reset,clk);
  CPU_baud_rate baud_rate(system_clk,reset,baud_rate_clock);
  CPU_single_cycle CPU(clk,reset,led,AN,digital,UART_TX,UART_RX,baud_rate_clock);
endmodule