module CPU_Registers(clk,reset,AddrA,AddrB,AddrC,WrC,WriteDataC,PC,IRQ,ReadDataA,ReadDataB);
  input clk,reset,WrC,IRQ;
  input[4:0] AddrA,AddrB,AddrC;
  input[31:0] WriteDataC,PC;
  output[31:0] ReadDataA,ReadDataB;
  wire enable=~PC[31]&IRQ;
  wire[31:0] PC_plus;
  reg[31:0] Regis[31:1];
  
  
  assign PC_plus={PC[31],{PC[30:0]+31'b000_0000_0000_0000_0000_0000_0000_0100}};
  assign ReadDataA=(AddrA==5'b0)? 32'b0:Regis[AddrA];  //$0==0
  assign ReadDataB=(AddrB==5'b0)? 32'b0:Regis[AddrB];  
  initial
   begin
      Regis[1]=32'b0;Regis[2]=32'b0;Regis[3]=32'b0;Regis[4]=32'b0;
      Regis[5]=32'b0;Regis[6]=32'b0;Regis[7]=32'b0;Regis[8]=32'b0;
      Regis[9]=32'b0;Regis[10]=32'b0;Regis[11]=32'b0;Regis[12]=32'b0;
      Regis[13]=32'b0;Regis[14]=32'b0;Regis[15]=32'b0;Regis[16]=32'b0;
      Regis[17]=32'b0;Regis[18]=32'b0;Regis[19]=32'b0;Regis[20]=32'b0;
      Regis[21]=32'b0;Regis[22]=32'b0;Regis[23]=32'b0;Regis[24]=32'b0;
      Regis[25]=32'b0;Regis[26]=32'b0;Regis[27]=32'b0;Regis[28]=32'b0;
      Regis[29]=32'b0;Regis[30]=32'b0;Regis[31]=32'b0;
    end
  
  always @(posedge clk,posedge reset)
   begin
    if(reset) 
     begin
      Regis[1]=32'b0;Regis[2]=32'b0;Regis[3]=32'b0;Regis[4]=32'b0;
      Regis[5]=32'b0;Regis[6]=32'b0;Regis[7]=32'b0;Regis[8]=32'b0;
      Regis[9]=32'b0;Regis[10]=32'b0;Regis[11]=32'b0;Regis[12]=32'b0;
      Regis[13]=32'b0;Regis[14]=32'b0;Regis[15]=32'b0;Regis[16]=32'b0;
      Regis[17]=32'b0;Regis[18]=32'b0;Regis[19]=32'b0;Regis[20]=32'b0;
      Regis[21]=32'b0;Regis[22]=32'b0;Regis[23]=32'b0;Regis[24]=32'b0;
      Regis[25]=32'b0;Regis[26]=32'b0;Regis[27]=32'b0;Regis[28]=32'b0;
      Regis[29]=32'b0;Regis[30]=32'b0;Regis[31]=32'b0;
     end
    else
     begin 
      if(WrC&&AddrC) Regis[AddrC]<=WriteDataC;
      if(enable&&(~WrC|AddrC!=5'b11111)) Regis[31]<=PC_plus;
     end
   end
endmodule