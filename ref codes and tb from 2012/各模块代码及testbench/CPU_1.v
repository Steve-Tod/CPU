module CPU_1(system_clk,reset,led,AN,digital,UART_RX,UART_TX);
  input system_clk,reset,UART_RX;
  output UART_TX;
  output[7:0] led,digital;
  output[3:0] AN;
  wire baud_rate_clock;
  CPU_baud_rate baud_rate(system_clk,reset,baud_rate_clock);
  CPU_Pipeline pipeline(system_clk,reset,led,AN,digital,UART_TX,UART_RX,baud_rate_clock);  
endmodule