module Pipe_Forwardtb;
  reg EXMEMWr,MEMWBWr;
  reg[4:0] EXMEMRd,MEMWBRd,IDEXRs,IDEXRt;
  wire[1:0] forwardA,forwardB;
Pipe_Forward forward(EXMEMWr,MEMWBWr,EXMEMRd,MEMWBRd,IDEXRs,IDEXRt,forwardA,forwardB);
initial begin
  EXMEMWr=1; MEMWBWr=1;
  EXMEMRd=5'b11001; MEMWBRd=5'b10001;
  IDEXRs=5'b10000; IDEXRt=5'b00001;
  #10 IDEXRs=5'b11001; IDEXRt=5'b00001;
  #10 IDEXRs=5'b11101; IDEXRt=5'b10001;
 end
endmodule