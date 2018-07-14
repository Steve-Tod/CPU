module Receiver(reset,UART_RX,Clk_16_9600,RX_DATA,RX_STATUS);
input UART_RX;
input reset;
input Clk_16_9600;
output reg RX_STATUS;
output reg [7:0]RX_DATA;
reg [7:0] DATA;
reg [7:0]cnt_clk;
reg [2:0]cnt_bit;
reg Sample;
reg enable;

initial
begin
	DATA=0;
	cnt_clk=0;
	cnt_bit=0;
	RX_DATA=0;
	Sample=0;//read the data
	enable=0;//if conut
	RX_STATUS=1;
end
always @(posedge Clk_16_9600 or negedge reset) begin
	if (~reset) begin
		RX_DATA=0;
		RX_STATUS=0;
		cnt_clk=0;
		Sample=0;
		enable=0;
	end
	else begin
		if(enable==0&&~UART_RX)
		begin
			enable=1;//begin!
			RX_STATUS=0;
			cnt_clk=0;
		end
		if(enable)
		begin
			case(cnt_clk)
			24,40,56,72,88,104,120,136:
			begin
				Sample=1;
				cnt_clk=cnt_clk+1;
			end
			138:
			begin
				//RX_STATUS=1;
				RX_DATA<=DATA;
				cnt_clk=cnt_clk+1;
			end
			161:
			begin
				RX_STATUS=1;
				cnt_clk=cnt_clk+1;
				enable=0;
			end
			default:
			begin
				cnt_clk=cnt_clk+1;
				Sample=0;
			end
			endcase
		end
	end
end
 always @(posedge Sample)
  begin
    if(enable)
      begin
        case(cnt_bit)
          3'd0:DATA[0]<=UART_RX; 
          3'd1:DATA[1]<=UART_RX; 
          3'd2:DATA[2]<=UART_RX; 
          3'd3:DATA[3]<=UART_RX; 
          3'd4:DATA[4]<=UART_RX; 
          3'd5:DATA[5]<=UART_RX; 
          3'd6:DATA[6]<=UART_RX; 
          3'd7:DATA[7]<=UART_RX;
          default:; 
        endcase
        cnt_bit<=cnt_bit+1;
      end
  end
endmodule

module Test_Receiver;
reg UART_RX;
reg Clk_16_9600;
reg reset;
initial
begin
	reset=0;
	#10 reset=1;
	Clk_16_9600=1;
	UART_RX=0;
end

always
begin
	#1 Clk_16_9600=~Clk_16_9600;
end

initial repeat(39)
begin
	#50 UART_RX=~UART_RX;
end
Receiver ZY(reset,UART_RX,Clk_16_9600,RX_DATA,RX_STATUS);
endmodule