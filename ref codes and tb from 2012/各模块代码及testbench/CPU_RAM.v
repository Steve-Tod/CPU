module CPU_RAM(clk,reset,Addr,WriteData,MemRd,MemWr,ReadData,led,AN,
              digital,inter,UART_TXD,RX_DATA,TX_EN,TX_STATUS,RX_STATUS);
  input clk,reset,MemRd,MemWr,RX_STATUS,TX_STATUS;
  input[7:0] RX_DATA;
  input[31:0] Addr,WriteData;
  output reg[31:0] ReadData;
  output reg[3:0] AN;
  output reg[7:0] digital,led,UART_TXD;
  output inter;
  output reg TX_EN;
  
	reg[31:0] RAMDATA[255:0];
	reg[31:0] TH,TL;
	reg[15:0] shift;
	reg[7:0] UART_RXD,send,get;
	reg[4:0] UART_CON;
	reg[2:0] TCON;
	reg[1:0] mark;
	reg flag,read,count;
	
	initial 
	 begin
	  TH<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
    TL<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
    TCON<=3'b000;
	  led<=8'b0;
	  AN<=4'b1111;
	  digital<=8'b11111111;
	  ReadData<=32'b0;
	  shift<=16'b0;
	  UART_RXD<=8'b0;
	  send<=8'b0;
	  flag<=1'b1;
	  read<=1'b1;
	  mark<=2'b0;
	  count<=1'b0;
	  UART_CON<=5'b0;
	 end
	assign inter=TCON[2]; 
   
  always @(posedge clk,posedge reset) 
   begin
		if(reset)
		 begin 
		  TH<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
      TL<=32'b1111_1111_1111_1111_1111_1000_0000_0000;
      TCON<=3'b000;
      UART_CON<=5'b00000;
      TX_EN<=1'b0;
      shift<=16'b0;
      UART_RXD<=8'b0;
      count<=1'b0;
		 end
		else
		 begin
		  if(RX_STATUS)
		   begin 
		    if(flag) begin shift<=16'b0; get<=RX_DATA; flag<=1'b0; end
        else begin shift<={RX_DATA,get}; flag<=1'b1; mark<=2'b01; end
       end
		  if((Addr[31:2]<256)&&MemWr) RAMDATA[Addr[31:2]]<=WriteData;
		  if((Addr==32'b0100_0000_0000_0000_0000_0000_0000_1100)&&MemWr) led<=WriteData[7:0];                                                                 
		  if((Addr==32'b0100_0000_0000_0000_0000_0000_0001_0100)&&MemWr) begin AN<=~WriteData[11:8];
		                                                                       digital<=WriteData[7:0]; end                                                        
		  if((Addr==32'b0100_0000_0000_0000_0000_0000_0000_0000)&&MemWr) TH<=WriteData;
		  if((Addr==32'b0100_0000_0000_0000_0000_0000_0000_0100)&&MemWr) TL<=WriteData;
		  else if(TCON[0])
		    begin
		     if(TL==32'b1111_1111_1111_1111_1111_1111_1111_1111) TL<=TH;
			   else TL<=TL+32'b1;
		    end
		  if((Addr==32'b0100_0000_0000_0000_0000_0000_0000_1000)&&MemWr) TCON<=WriteData[2:0];
		  else if(TCON[1]&&TCON[0]&&(TL==32'b1111_1111_1111_1111_1111_1111_1111_1111)) TCON<=3'b111;
		  if((Addr==32'b0100_0000_0000_0000_0000_0000_0001_1000)&&MemWr) 
		   begin 
		    UART_TXD<=WriteData[7:0];
		    if(TX_STATUS&&(mark==2'b11)) 
		     begin 
		      if(count) begin TX_EN<=1'b1; mark<=2'b00; end
		      count<=~count;
		     end
		   end
		 if((Addr==32'b0100_0000_0000_0000_0000_0000_0001_1000)&&MemWr) UART_CON<=WriteData[4:0];
		 if(MemRd&&(Addr==32'b0100_0000_0000_0000_0000_0000_0001_1100))
		  begin 
	     if(read) 
	      begin
	       UART_RXD<=shift[7:0]; read<=1'b0;
	       if(mark==2'b01) mark<=2'b10; 
	      end
		   else 
		   begin 
		    UART_RXD<=shift[15:8]; read<=1'b1; 
	      if(mark==2'b10) mark<=2'b11;  
		   end
	    end
		 if(~(TX_STATUS&&(mark==2'b11))) TX_EN<=1'b0;
	   end
	 end
  
  always @(*)
   begin
    if(~MemRd) ReadData=32'b0;
    else
     begin
      casez(Addr)
       32'b0000_0000_0000_0000_0000_00??_????_??00: ReadData<=RAMDATA[Addr[31:2]];
       32'b0100_0000_0000_0000_0000_0000_0000_0000: ReadData<=TH;
       32'b0100_0000_0000_0000_0000_0000_0000_0100: ReadData<=TL;
       32'b0100_0000_0000_0000_0000_0000_0000_1000: ReadData<={29'b0,TCON};
       32'b0100_0000_0000_0000_0000_0000_0000_1100: ReadData<={24'b0,led};
       32'b0100_0000_0000_0000_0000_0000_0001_0100: ReadData<={20'b0,~AN,digital};
       32'b0100_0000_0000_0000_0000_0000_0001_1000: ReadData<={24'b0,UART_TXD};
       32'b0100_0000_0000_0000_0000_0000_0001_1100: ReadData<={24'b0,UART_RXD};
       32'b0100_0000_0000_0000_0000_0000_0010_0000: ReadData<={27'b0,UART_CON}; 
       default: ReadData<=32'b0;
      endcase
     end
   end
endmodule