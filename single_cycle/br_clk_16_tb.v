module CLK_tb;
reg sysclk;
initial
begin
  sysclk=0;
end
always
begin
  #1 sysclk=~sysclk;
end
br_clk_16 clk1(sysclk,Clk_16_9600);
endmodule