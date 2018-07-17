module BrClk(sysclk, brclk16);
input   sysclk;
output  reg brclk16;

parameter   CNT_NUM = 10'd325;
reg [9:0]   cnt;

initial
begin
    brclk16 = 0;
    cnt = 0;
end

always @(posedge sysclk)
begin
    if (cnt >= CNT_NUM)
        cnt <= 10'd0;
    else
        cnt <= cnt + 10'd1;

    if (cnt <= 10'd162)
        brclk16 <= 1;
    else
        brclk16 <= 0;
end

endmodule