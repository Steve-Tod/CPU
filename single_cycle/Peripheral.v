`timescale 1ns/1ps

module Peripheral (reset,clk,rd,wr,addr,wdata,rdata,led,switch,digi,irqout,
                   UART_RX, UART_TX, PC31);
input reset,clk,PC31;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output irqout;

// UART
input UART_RX;
output UART_TX;

wire    brclk16;
reg     [7:0]   UART_TXD;
reg     [7:0]   UART_RXD;
wire    TX_STATUS;
wire    RX_STATUS;
wire    [7:0]   TX_DATA;
wire    [7:0]   RX_DATA;
reg     TX_EN;
reg     [4:0]   UART_CON;
reg     reading, writing;
reg     [9:0]   TX_cnt;
parameter   CNT_NUM = 10'd325;

BrClk BrClk1(clk, brclk16);
Receiver Receiver1(reset, UART_RX, brclk16, RX_DATA, RX_STATUS);
Sender Sender1(reset, brclk16, TX_DATA, TX_EN, TX_STATUS, UART_TX);

reg [31:0] TH,TL;
reg [2:0] TCON;

initial begin
	TX_EN = 0;
	TX_cnt = 0;
	TCON = 3'b0;
	UART_CON[4] = 0;
end

assign irqout = (~PC31) & TCON[2];

always@(*) begin
    if(rd) begin
        case(addr)
            32'h40000000: rdata <= TH;          
            32'h40000004: rdata <= TL;          
            32'h40000008: rdata <= {29'b0,TCON};                
            32'h4000000C: rdata <= {24'b0,led};         
            32'h40000010: rdata <= {24'b0,switch};
            32'h40000014: rdata <= {20'b0,digi};
            32'h40000018 : rdata <= {24'b0, UART_TXD};
            32'h4000001c : rdata <= {24'b0, UART_RXD};
            32'h40000020 : rdata <= {27'b0, UART_CON};
            default: rdata <= 32'b0;
        endcase
    end
    else
        rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
    if(~reset) begin
        TH <= 32'b0;
        TL <= 32'b0;
        TCON <= 3'b0; 
        UART_CON <= 0;
        TX_EN <= 0;
        reading <= 0;
        TX_cnt <= 0;
		UART_CON[1:0] <= 2'b11;
    end
    else begin
		UART_CON[4] <= ~TX_STATUS;
        if(TCON[0]) begin   //timer is enabled
            if(TL==32'hffffffff) begin
                TL <= TH;
                if(TCON[1]) TCON[2] <= 1'b1;        //irq is enabled
            end
            else TL <= TL + 1;
        end
        //read
        //set 0
        if (rd && (addr == 32'h4000_0020)) begin
            UART_CON[3:2] <= 2'b0;
        end
        //use reading to avoid setting repeatedly
        if (~RX_STATUS) reading <= 0;
        if (RX_STATUS && ~reading && UART_CON[1]) begin
            UART_CON[3] <= 1;
            UART_RXD <= RX_DATA;
            reading <= 1;
        end

        // lengthen the TX_EN pulse
        if (TX_EN) begin
            if (TX_cnt < CNT_NUM) TX_cnt <= TX_DATA + 1;
            else begin
                TX_cnt <= 0;
                TX_EN <= 0;
            end
        end
        
        if(wr) begin
            case(addr)
                32'h40000000: TH <= wdata;
                32'h40000004: TL <= wdata;
                32'h40000008: TCON <= wdata[2:0];       
                32'h4000000C: led <= wdata[7:0];            
                32'h40000014: digi <= wdata[11:0];
                32'h40000018: begin
                    //since  has cache, we don't need to worry if new TXD will affect the sending one
                    UART_TXD <= wdata[7:0];
                    if (TX_STATUS && ~TX_EN && UART_CON[0]) begin
                        TX_EN <= 1;
                    end
				end
				//UART_RXD should not be written
				32'h4000001c : UART_RXD <= wdata [7:0];
				32'h40000020 : UART_CON <= wdata [4:0];
                default: ;
            endcase
        end
    end
end
endmodule




