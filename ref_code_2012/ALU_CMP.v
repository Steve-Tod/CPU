module ALU_CMP(Z,V,N,ALUFun,S);
  input  Z,V,N;
  input[5:0] ALUFun;
  output reg[31:0] S;  
  always @(*)
  begin
    case(ALUFun[3:1])
      3'b001: S=Z?32'd1:32'd0;
      3'b000: S=(~Z)?32'd1:32'd0;
      3'b010: S=N?32'd1:32'd0;
      3'b110: S=(Z|N)?32'd1:32'd0;
      3'b100: S=(~N)?32'd1:32'd0;
      3'b111: S=(~(Z|N))?32'd1:32'd0;
      default:S=32'd0;
    endcase
  end
  
endmodule
