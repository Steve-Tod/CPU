module CPU_UARTre(reset,baud_rate_clock,UART_RX,RX_STATUS,RX_DATA,clk);
input baud_rate_clock,UART_RX,reset,clk;
output reg RX_STATUS; 
output reg[7:0] RX_DATA;
reg record,enable;
reg [9:0] count;
wire start;

initial 
 begin
  RX_STATUS=0; RX_DATA=8'b0;
  record=0; enable=0; count=10'd0;
 end 
 
always @(posedge clk or posedge reset)
 begin 
  if(reset) record<=0;
  else record<=UART_RX;
 end
assign start=(record==1&&UART_RX==0&&count==0)?1'b1:1'b0; //find the start
always @(posedge clk or posedge reset)
  begin
   if(reset) enable<=1'b0;
   else if(start==1'b1) enable<=1'b1;
   else if(count==10'd608) enable<=1'b0; //find the end
  end
 
always @(posedge baud_rate_clock or posedge reset)
 begin
  if(reset) count<=10'd0;
  else if(enable) count<=count+1'b1;
  else count<=10'd0;
 end

always @(posedge baud_rate_clock or posedge reset)
 begin
  if(reset) RX_DATA<=8'b0;
  else if(enable)
   begin
    case(count)
     10'd96: RX_DATA[0]<=UART_RX; 
     10'd160: RX_DATA[1]<=UART_RX;
     10'd224: RX_DATA[2]<=UART_RX;
     10'd288: RX_DATA[3]<=UART_RX;
     10'd352: RX_DATA[4]<=UART_RX;
     10'd416: RX_DATA[5]<=UART_RX;
     10'd480: RX_DATA[6]<=UART_RX;
     10'd544: RX_DATA[7]<=UART_RX;
    endcase
   end
end

always @(posedge clk or posedge reset)
 begin
  if(reset) RX_STATUS<=1'b0;
  else if(count==10'd608 && enable) RX_STATUS<=1'b1;  
  else RX_STATUS<=1'b0;
 end
endmodule