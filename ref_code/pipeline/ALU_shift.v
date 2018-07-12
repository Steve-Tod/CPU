module ALU_shift(A,B,op,S);
	input[31:0] A;
	input[31:0] B; 
	input[1:0] op;   //ALUFun[1:0]
	output reg [31:0] S;
	reg [31:0]SRA_B;
	reg [5:0]j;
	wire [4:0] i;
	assign i = A[4:0];
	always @ (*)
	begin
	  case(op)
	    2'b00:S=(B<<i);//SLL
	    2'b01:S=(B>>i);//SRL
	    2'b11://SRA
	    begin
			S={{32{B[31]}},B}>>i;
	    end
	    default:S=0;
	    endcase
	 end
endmodule

module Test_shift;
reg [31:0]A,B;
reg [1:0] op;
initial 
begin
	A=32'd99;
	B=-32'd19077;
	op=2'b11;
end
ALU_shift ZY(A,B,op,S);
endmodule

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	