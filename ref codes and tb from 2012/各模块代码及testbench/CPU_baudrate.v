module CPU_baud_rate(system_clk,reset,baud_rate_clock);
input system_clk,reset;
output reg baud_rate_clock;
reg [8:0] count;
initial 
 begin
  count<=9'b0;
  baud_rate_clock<=1'b1;
 end
always @(posedge system_clk or posedge reset) 
 begin
  if(reset)
   begin
    count<=9'b0;
    baud_rate_clock<=1'b1;
   end
  else
   begin
    if(count==80)  //100MHZ/(64*9600)=162.76
     begin 
	    baud_rate_clock<=~baud_rate_clock; 
	    count<=9'b0;
	   end
    else
     begin
      count<=count+1; 
     end
   end
 end
endmodule
