module sender(reset, br_clk_16, TX_DATA, TX_EN, TX_STATUS, UART_TX);
input	[7:0]	TX_DATA;
input	TX_EN, reset, br_clk_16;
output	UART_TX, TX_STATUS;

reg	UART_TX, TX_STATUS;
reg status;	//1 for writing
reg	[5:0]	cnt;
reg	[3:0]	data_cnt;
reg	[8:0]	data_cache;

initial begin
	UART_TX = 1;	//1 is stop
	TX_STATUS = 1;
	status = 0;
	cnt = 0;
	data_cnt = 0;
	data_cache = 0;
end

always @(posedge br_clk_16 or negedge reset) begin
	if (~reset) begin
		UART_TX = 1;
		TX_STATUS = 1;
		status = 0;	//1 for writing
		cnt = 0;
		data_cnt = 0;
	end
	else begin
		if (~status) begin
			if (TX_EN) begin
				status <= 1;
				TX_STATUS <= 0;
				data_cache[8:1] <= TX_DATA;
			end
			else
				UART_TX <= 1;
		end
		else begin
			if (cnt >= 15) begin
				cnt <= 0;
				if (data_cnt >= 9) begin
					status <= 0;
					TX_STATUS <= 1;
					data_cnt <= 0;
					UART_TX <= 1;
				end
				else begin
					UART_TX <= data_cache[data_cnt];
					data_cnt <= data_cnt + 1;
				end
			end
			else cnt <= cnt + 1;
		end
	end
end

endmodule