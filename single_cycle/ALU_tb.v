module ALU_tb;
reg [5:0]ALUFun;
reg [31:0]A,B;
reg Sign;
reg clk;
reg [5:0]fun[14:0];
integer i;
initial
begin
    clk = 0;
	A=32'd15;
	B=32'd31;
	Sign=1;
    fun[0] = 6'b00_0000;
    fun[1] = 6'b00_0001;
    fun[2] = 6'b01_1000;
    fun[3]  = 6'b01_1110;
    fun[4] = 6'b01_0110;
    fun[5] = 6'b01_0001;
    fun[6] = 6'b10_0000;
    fun[7] = 6'b10_0001;
    fun[8] = 6'b10_0011;
    fun[9] =  6'b11_0011;
    fun[10] = 6'b11_0001;
    fun[11] =  6'b11_0101;
    fun[12] = 6'b11_1101;
    fun[13] = 6'b11_1011;
    fun[14] = 6'b11_1111; 
    i = 0;
end
always@(posedge clk)
begin
    ALUFun <= fun[i];
    i = i+1;
end
wire [31:0]Out;
always #5 clk = ~clk;
ALU ZY(A,B,ALUFun,Sign,Out);
endmodule