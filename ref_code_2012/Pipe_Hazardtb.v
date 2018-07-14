module Pipe_Hazardtb;
 reg IDEXRead;
 reg[4:0] IDEXRt,IFIDRs,IFIDRt;
 wire Stall;
Pipe_Hazard hazard(IDEXRead,IDEXRt,IFIDRs,IFIDRt,Stall);
initial begin
  IDEXRead=1;
  IDEXRt=5'b11000;
  IFIDRs=5'b10001; IFIDRt=5'b11110;
  #10  IFIDRs=5'b11000; IFIDRt=5'b11110;
 end
endmodule