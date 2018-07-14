module Peripheral_tb;

reg		reset, clk, rd, wr, UART_RX, PC31;
reg		[31:0]	addr, wdata;
reg 	[7:0]	switch;
reg		[39:0]	data;
wire	[31:0]	rdata;
wire	[11:0]	digi;
wire	[7:0]	led;
wire	[1:0]	irqout;
wire	UART_TX;

initial begin
	reset = 1;
	clk = 0;
	rd = 1;
	wr = 0;
	UART_RX = 1;
	PC31 = 0;
	addr = 32'h4000001c;
	wdata = 32'h0;
	switch = 0;
	data = 40'hffffa7ff96;
	#10000000 $stop;
end

always #10400 begin
	UART_RX <= data[0];
	data <= {data[0], data[39:1]};
end

always #1 clk = ~clk;

Peripheral Peripheral1(reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,
							  UART_RX, UART_TX, PC31);

endmodule