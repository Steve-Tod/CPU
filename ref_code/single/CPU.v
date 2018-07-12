module CPU(reset, sysclk, led, switch, digi1, digi2, digi3, digi4, UART_RX,
           UART_TX);
input reset, sysclk;
output [7:0] led;
input [7:0] switch;
output [6:0] digi1;
output [6:0] digi2;
output [6:0] digi3;
output [6:0] digi4;
input UART_RX;
output UART_TX;

reg [31:0] PC;
wire [31:0] PC_next;
always @(negedge reset or posedge sysclk) if (~reset) PC <= 32'h80000000;
else PC <= PC_next;

wire [31:0] PC_plus_4;
assign PC_plus_4 = PC + 32'd4;

wire [31:0] Instruction;
ROM ROM(.addr(PC [30:0]), .data(Instruction));

wire IRQ;
wire [2:0] PCSrc;
wire [1:0] RegDst;
wire RegWr;
wire ALUSrc1;
wire ALUSrc2;
wire [5:0] ALUFun;
wire Sign;
wire MemWr;
wire MemRd;
wire [1:0] MemToReg;
wire EXTOp;
wire LUOp;
control control(.OpCode(Instruction [31:26]), .Funct(Instruction [5:0]),
                .IRQ(IRQ), .PCSrc(PCSrc), .RegDst(RegDst), .RegWr(RegWr),
                .ALUSrc1(ALUSrc1), .ALUSrc2(ALUSrc2), .ALUFun(ALUFun),
                .Sign(Sign), .MemWr(MemWr), .MemRd(MemRd), .MemToReg(MemToReg),
                .EXTOp(EXTOp), .LUOp(LUOp));

wire [31:0] Databus1, Databus2, Databus3;
wire [4:0] Write_register;
assign Write_register =
    (RegDst == 2'b00) ? Instruction [15:11]
                      : (RegDst == 2'b01) ? Instruction [20:16]
                                          : (RegDst == 2'b10) ? 5'd31 : 5'd26;
RegFile register_file(.reset(reset), .clk(sysclk), .addr1(Instruction [25:21]),
                      .data1(Databus1), .addr2(Instruction [20:16]),
                      .data2(Databus2), .wr(RegWr), .addr3(Write_register),
                      .data3(Databus3));

wire [31:0] Ext_out;
assign Ext_out = {EXTOp ? {16 {Instruction[15]}} : 16'h0000,
                  Instruction [15:0]};

wire [31:0] LU_out;
assign LU_out = LUOp ? {Instruction [15:0], 16'h0000} : Ext_out;

wire [31:0] ALU_in1;
wire [31:0] ALU_in2;
wire [31:0] ALU_out;
assign ALU_in1 = ALUSrc1 ? {27'h00000, Instruction [10:6]} : Databus1;
assign ALU_in2 = ALUSrc2 ? LU_out : Databus2;
ALU alu(.ALUFun(ALUFun), .A(ALU_in1), .B(ALU_in2), .Sign(Sign), .Out(ALU_out));

wire [31:0] Read_data;
wire [31:0] Read_data1;
wire [31:0] Read_data2;
wire MemWr1, MemWr2;
wire [11:0] digi;
assign Read_data = ALU_out[30] ? Read_data2 : Read_data1;
assign MemWr1 = (MemWr && (~ALU_out[30]));
assign MemWr2 = (MemWr && (ALU_out[30]));
DataMem data_memory(.reset(reset), .clk(sysclk), .addr(ALU_out), .rd(MemRd),
                    .wr(MemWr1), .wdata(Databus2), .rdata(Read_data1));
Peripheral peripheral(.reset(reset), .sysclk(sysclk), .rd(MemRd), .wr(MemWr2),
                      .addr(ALU_out), .wdata(Databus2), .rdata(Read_data2),
                      .led(led), .switch (switch), .digi(digi),
                      .UART_RX(UART_RX), .UART_TX(UART_TX), .irqout(IRQ),
                      .PC_31(PC[31]));
digitube_scan scan(.digi_in(digi), .digi_out1(digi1), .digi_out2(digi2),
                   .digi_out3(digi3), .digi_out4(digi4));
assign Databus3 = (MemToReg == 2'b00)
                      ? ALU_out
                      : (MemToReg == 2'b01)
                            ? Read_data
                            : (MemToReg == 2'b10) ? PC_plus_4 : PC;

wire [31:0] Jump_target;
assign Jump_target = {PC_plus_4 [31:28], Instruction [25:0], 2'b00};

wire [31:0] Branch_target;
assign Branch_target =
    ALU_out ? PC_plus_4 + {Ext_out [29:0], 2'b00} : PC_plus_4;

wire [31:0] ILLOP;
assign ILLOP = 32'h80000004;

assign PC_next =
    (PCSrc == 3'b000)
        ? PC_plus_4
        : (PCSrc == 3'b001)
              ? Branch_target
              : (PCSrc == 3'b010)
                    ? Jump_target
                    : (PCSrc == 3'b011)
                          ? Databus1
                          : (PCSrc == 3'b100) ? ILLOP : 32'h80000008;

endmodule
