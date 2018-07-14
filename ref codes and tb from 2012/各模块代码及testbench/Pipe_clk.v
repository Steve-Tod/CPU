module Pipe_clk(system_clk,reset,clk);
input system_clk,reset;
output reg clk;
reg count;
initial 
 begin
  count<=5'b0;
  clk<=1'b1;
 end

always @(posedge system_clk or posedge reset) 
 begin
  if(reset)
   begin
    count<=1'b0;
    clk<=1'b1;
   end
  else clk<=~clk;
 end
endmodule