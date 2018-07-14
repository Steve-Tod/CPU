module Test_Pipeline;
reg reset,sysclk;
reg UART_RX;
wire [6:0] digi1, digi2, digi3, digi4;
wire [7:0] led;
wire UART_TX;
initial 
begin    
	reset <= 0;
	#1 reset <= 1;
	sysclk <=0;
	UART_RX <= 1;
	#100000	
	UART_RX <= 0;   
	#104166 UART_RX <= 0;   
	#104166 UART_RX <= 0;  
	#104166 UART_RX <= 0;    
	#104166 UART_RX <= 1;    
	#104166 UART_RX <= 1;   
	#104166 UART_RX <= 0;    
	#104166 UART_RX <= 0;    
	#104166 UART_RX <= 0;
	#104166 UART_RX<=1;
	//24
	
	#104166 UART_RX <= 0; 
	
	#104166 UART_RX <= 0;   
	#104166 UART_RX <= 0;  
	#104166 UART_RX <= 0;    
	#104166 UART_RX <= 1;    
	#104166 UART_RX <= 1;   
	#104166 UART_RX <= 1;    
	#104166 UART_RX <= 1;    
	#104166 UART_RX <= 0;
	#104166 UART_RX<=1; 
	//120

	
end
always
begin
	#10 sysclk=~sysclk;
end
Pipeline ZY1(reset,sysclk, led, switch, digi1, digi2, digi3, digi4, UART_RX, UART_TX);
endmodule