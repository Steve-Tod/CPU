module CPU_UARTse(baud_rate_clock,reset,TX_EN,TX_DATA,TX_STATUS,UART_TX,clk);
input baud_rate_clock,TX_EN,reset,clk;
input[7:0] TX_DATA; 
output reg TX_STATUS,UART_TX;
reg enable,record;
reg [9:0] count; 
wire start;

initial
begin
TX_STATUS=1'b1; UART_TX=1'b1;
enable=1'b0; count=10'd0;
end

always @(posedge clk or posedge reset)
 begin 
  if(reset) record<=0;
  else record<=TX_EN;
 end
 assign start=record&~TX_EN; //find the start

always @(posedge clk or posedge reset)
 begin
  if(reset)
   begin 
	 enable=1'b0;
	 TX_STATUS=1'b1;
	end
  else if(TX_EN) enable<=1'b1;
  else if(start) TX_STATUS<=1'b0;
  else if(count==10'd640)
   begin
    enable<=1'b0;
    TX_STATUS<=1'b1;
   end
 end

always @(posedge baud_rate_clock or posedge reset)
 begin
  if(reset) count<=10'd0;
  else if(enable) count<=count+1'b1;
  else count<=10'd0;
 end

always @(posedge baud_rate_clock or posedge reset)
 begin
  if(reset) UART_TX<=1'b1;
  else if(enable)
   case(count)
    10'd0: UART_TX<=1'b0;
    10'd64: UART_TX<=TX_DATA[0];
    10'd128: UART_TX<=TX_DATA[1];
    10'd192: UART_TX<=TX_DATA[2];
    10'd256: UART_TX<=TX_DATA[3];
    10'd320: UART_TX<=TX_DATA[4];
    10'd384: UART_TX<=TX_DATA[5];
    10'd448: UART_TX<=TX_DATA[6];
    10'd512: UART_TX<=TX_DATA[7];
    10'd576: UART_TX<=1'b1;
   endcase
  else UART_TX<=1'b1;
 end
endmodule
