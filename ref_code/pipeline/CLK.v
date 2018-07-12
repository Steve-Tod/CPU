module CLK(sysclk,Clk_16_9600);
  input sysclk;
  output reg Clk_16_9600;
  reg [9:0] count;
  
  initial begin
    count<=1;
    Clk_16_9600<=0;
  end
  always @(posedge sysclk) 
  begin  
  if(count==10'd163)
    begin
        count<=10'b1;
        Clk_16_9600<=~Clk_16_9600;
    end
  else
    count<=count+10'b1;
  end
endmodule

module Test_CLK;
reg sysclk;
initial
begin
  sysclk=0;
end
always
begin
  #1 sysclk=~sysclk;
end
CLK clk1(sysclk,Clk_16_9600);
endmodule

