`timescale 1ns / 1ns

    module Peripheral(reset, sysclk, rd, wr, addr, wdata, rdata, led, switch,
                      digi, UART_RX, UART_TX, irqout, PC_31);
// addr means address
input reset, PC_31; // clk is clk of CPU
input rd, wr;       // enable to read or write
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;
input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output wire irqout;

input UART_RX, sysclk;
output UART_TX;
reg [7:0] UART_TXD;
reg [7:0] UART_RXD;
reg [4:0] UART_CON;
wire [7:0] RX_DATA;
wire [7:0] TX_DATA;
wire RX_STATUS;
reg TX_EN;
wire TX_STATUS;
reg [10:0] cnt_EN;

reg [31:0] TH, TL; // TL increases as CLK changes
reg [2:0] TCON;
wire Clk_16_9600;

initial begin TX_EN = 0;
cnt_EN = 0;
end

    assign TX_DATA = UART_TXD;
CLK clk1(sysclk, Clk_16_9600);
Receiver receiver(reset, UART_RX, Clk_16_9600, RX_DATA, RX_STATUS);
Sender sender(TX_EN, sysclk, Clk_16_9600, TX_DATA, TX_STATUS, UART_TX);

assign irqout = (~PC_31) & TCON[2];

always @(*) begin if (rd) begin case (addr)32'h40000000 : rdata <= TH;
32'h40000004 : rdata <= TL;
32'h40000008 : rdata <= {29'b0, TCON};
32'h4000000C : rdata <= {24'b0, led};
32'h40000010 : rdata <= { 24'b0, switch };
32'h40000014 : rdata <= {20'b0, digi};
32'h40000018 : rdata <= {24'b0, UART_TXD};
32'h4000001c : rdata <= {24'b0, UART_RXD};
32'h40000020 : rdata <= {27'b0, UART_CON};
default:
rdata <= 32'b0;
endcase end else rdata <= 32'b0;
end

    reg Pre_RX_STATUS,
    Pre_TX_STATUS;
always @(negedge reset or posedge sysclk) begin if (~reset) begin TH <= 32'b0;
TL <= 32'b0;
TCON <= 3'b0;
UART_CON <= 5'b0;
UART_RXD <= 0;
UART_TXD <= 0;
TX_EN = 0;
cnt_EN = 0;
end else begin if (TCON[0]) begin // timer is enabled
    if (TL == 32'hffffffff) begin TL <= TH;
if (TCON[1])
  TCON[2] <= 1'b1; // irq is enabled
end else TL <= TL + 1;
end

    // Reading
    if (rd && (addr == 32'h4000_0020)) begin // after reading, change to 0
    if (UART_CON[2]) UART_CON[2] <= 1'b0;
if (UART_CON[3])
  UART_CON[3] <= 1'b0;
end
    // when posedge, let RXD=RX
    if (~RX_STATUS) Pre_RX_STATUS <= 0;
if (RX_STATUS && ~Pre_RX_STATUS)
  begin UART_CON[3] <= 1; // finish update RXD, is OK to read it
UART_RXD <= RX_DATA;
Pre_RX_STATUS <= 1;
end

    // Sending
    if (~TX_STATUS) Pre_TX_STATUS <= 0;
if (TX_STATUS && Pre_TX_STATUS)
  begin UART_CON[4] = 0;
UART_CON[2] <= 1;
Pre_TX_STATUS <= 1;
end

    if (TX_EN) begin if (cnt_EN < 20) cnt_EN <= cnt_EN + 1;
else begin cnt_EN <= 0;
TX_EN <= 0;
end end

    if (wr) begin case (addr)32'h40000000 : TH
                                            <= wdata;
32'h40000004 : TL <= wdata;
32'h40000008 : TCON <= wdata [2:0];
32'h4000000C : led <= wdata [7:0];
32'h40000014 : digi <= wdata [11:0];
32'h40000018 : begin UART_TXD <= wdata [7:0];
if (TX_STATUS && ~TX_EN)
  begin TX_EN <= 1; // let Sender sending
UART_CON[4] = 1;
end

        end 32'h4000001c : UART_RXD <= wdata [7:0];
32'h40000020 : UART_CON <= wdata [4:0];
default:;
endcase end end end endmodule

    module Test_P;
reg reset, rd, wr, UART_RX, sysclk, PC_31;
reg [31:0] wdata, addr;
reg [7:0] switch;
wire [31:0] rdata;
wire [7:0] led;
wire [11:0] digi;
wire [1:0] irqout;
wire UART_TX;
initial begin sysclk <= 1;
switch
  <= 8'd15;
PC_31 <= 1;
UART_RX <= 0;
# 500 UART_RX <= 1;
rd <= 0;
wr <= 0;
// wait till finish read
# 100000 rd <= 1;
addr <= 32'h4000001c;
# 100000
rd <= 0;
wr <= 1;
addr <= 32'h40000018;
wdata <= 32'd15; // 0f
# 100 wr <= 0;
addr <= 0;
end

    always begin
# 1 sysclk <= ~sysclk;
        end

            Peripheral P(reset, sysclk, rd, wr, addr, wdata, rdata, led, switch,
                         digi, UART_RX, UART_TX, irqout, PC_31);
endmodule