module Receiver(reset, UART_RX, br_clk_16, RX_DATA, RX_STATUS);
input	UART_RX, br_clk_16, reset;
output	RX_STATUS;
output	[7:0]	RX_DATA;

reg RX_STATUS;
reg [7:0]	RX_DATA;
reg [1:0]	status;		//0: not receving, 1:start detecting, 2:receiving
reg	[4:0]	cnt;
reg [3:0]	data_cnt;
reg [7:0]	data_cache;

initial 
begin
	status = 0;
	RX_STATUS = 0;
	RX_DATA = 0;
	cnt = 0;
	data_cnt = 0;
	data_cache = 0;
end

always @(posedge br_clk_16 or negedge reset) begin
	if (~reset) begin
		status <= 0;
		RX_STATUS <= 0;
		RX_DATA <= 0;
		cnt <= 0;
		data_cnt <= 0;
	end
	else begin
		case (status)
			2'b00: begin
				RX_STATUS <= 0;
				if (~RX_STATUS && ~UART_RX) begin
					status <= 1;
				end
				else;
			end
		
			2'b01: begin
				if (cnt >= 23) begin
					status <= 2;
					cnt <= 0;
					data_cache[data_cnt] <= UART_RX;
					data_cnt <= data_cnt + 1;
				end
				else
					cnt <= cnt + 1;
			end
		
			2'b10: begin
				if (cnt >= 15) begin
					if (data_cnt >= 8 && UART_RX) begin	//detect end
						status <= 0;
						RX_STATUS <= 1;
						RX_DATA <= data_cache;
						data_cnt <= 0;
					end
					else if (data_cnt < 8) begin
						data_cache[data_cnt] <= UART_RX;
						data_cnt <= data_cnt + 1;
					end
					else;
					cnt <= 0;
				end
				else
					cnt <= cnt +1;
			end
		
			default: status <= 0;
		endcase
	end
end


endmodule