`timescale 1ns / 1ps

// 4 bit flag register
module Flag_Reg(
input wire [3:0] In,
input wire reset,
input wire clk,
output wire [3:0] Out
);
reg [3:0] Mem;
assign Out = Mem;
always @ (posedge clk) begin
	if(reset) begin
		Mem = 0;
	end else begin
		Mem = In;
	end
end
endmodule

// Generic 32 Parallel-In-Parallel-Out register with active high enable load
module PIPO_Reg_32(
input wire [31:0] In,
input wire reset,
input wire load,
input wire clk,
output wire[31:0] Out
);
reg [31:0] Mem;
assign Out = Mem;
always @ (posedge clk) begin
	if(reset) begin
		Mem = 0;
	end else if(load) begin
		Mem = In;
	end
end
endmodule

// 32-bit Tris Buffer Array
module TransferSwitch(
input wire TransferSignal,
input wire [31:0]Input,
output wire[31:0]Output);
assign Output = TransferSignal ? Input : 32'bzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz;
endmodule
