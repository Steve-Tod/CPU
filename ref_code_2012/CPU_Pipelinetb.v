module CPU_Pipelinetb;
reg clk,reset,UART_RX;
wire UART_TX;
wire[3:0] AN;
wire[7:0] digital,led;
CPU_Pipeline Pipeline(clk,reset,led,AN,digital,UART_TX,UART_RX);  
always #1 clk=~clk;
initial begin
 clk=0;
 reset=1;
 UART_RX=1;
 #10 reset=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=1;
 #32 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0; //00011000
 #160 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0; //00100100
 #32 UART_RX=1;
 #3200 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=1;
 #32 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0; //00110000
 #160 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=1;
 #32 UART_RX=0;
 #32 UART_RX=0;
 #32 UART_RX=1;
 #32 UART_RX=0; //01001000
 #32 UART_RX=1;
 
 end
endmodule