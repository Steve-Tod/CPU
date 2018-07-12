module Sender(TX_EN, sysclk, Clk_16_9600, TX_DATA, TX_STATUS, UART_TX);
input [7:0] TX_DATA;
input TX_EN, Clk_16_9600, sysclk;
output reg TX_STATUS = 1;
output reg UART_TX = 1;

reg [10:0] cnt_clk = 0;
reg [7:0] DATA = 0;

always @(posedge sysclk) begin if (TX_EN) TX_STATUS <= 0;
else if (cnt_clk >= 161) TX_STATUS <= 1;
end

        always @(posedge Clk_16_9600) begin if (TX_STATUS == 0) cnt_clk
    <= cnt_clk + 1;
else cnt_clk <= 0;
end

        always @(posedge sysclk) begin case (cnt_clk)1 : UART_TX
                                                         <= 0;
17 : UART_TX <= TX_DATA[0];
33 : UART_TX <= TX_DATA[1];
49 : UART_TX <= TX_DATA[2];
65 : UART_TX <= TX_DATA[3];
81 : UART_TX <= TX_DATA[4];
97 : UART_TX <= TX_DATA[5];
113 : UART_TX <= TX_DATA[6];
129 : UART_TX <= TX_DATA[7];
145 : UART_TX <= 1;
endcase end endmodule