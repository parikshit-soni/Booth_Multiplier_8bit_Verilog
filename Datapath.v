`timescale 1ns / 1ps

// 8bit to 32-bit signed extender
module SignExtend(
input wire[7:0] SW,
output wire[31:0]xt);
assign xt[31:8] = SW[7] ? 24'b111111111111111111111111 : 24'b000000000000000000000000;
assign xt[7:0] =  SW[7:0];
endmodule

// 32-bit left shifter (M/2M selection)
// Ignores carry out
module Shifter(
input ShL,
input wire [31:0] x,
output wire [31:0] z
);
and (z[0] , ~ShL , x[0]);
assign z[31:1] = ShL ? x[30:0] : x[31:1];
endmodule

module Datapath(
input wire clk,
input wire reset,
input wire[7:0] SW,

input wire [3:0]	TransferSignals,
input wire [2:0]	LoadSignals,
input wire [11:0]	ALU_Signals,
input wire ShiftLeftSignal,

output wire [3:0]Flags,
output wire [2:0]A_Val,

output wire [15:0]Answer
);

// Data source IDs
parameter idA = 0;
parameter idB = 1;
parameter idC = 2;
parameter idSW= 3;

// Internal buses
wire [31:0] x;
wire [31:0] y;
wire [31:0] z;

wire [31:0] A_out;
wire [31:0] B_out;
wire [31:0] B_sh;
wire [31:0] B_2B;
wire [31:0] C_out;

wire [31:0] SW_extended;

PIPO_Reg_32 A(z,reset,LoadSignals[idA],clk,A_out);
PIPO_Reg_32 B(z,reset,LoadSignals[idB],clk,B_out);
PIPO_Reg_32 C(z,reset,LoadSignals[idC],clk,C_out);

assign B_sh[8:0] = 9'b000000000;
assign B_sh[31:9]= B_out[22:0];
//	Shift by (8 + 1) bits

Shifter shifter(ShiftLeftSignal,B_sh,B_2B);

TransferSwitch trA(TransferSignals[idA],A_out,x);
TransferSwitch trB(TransferSignals[idB],B_2B,y);
TransferSwitch trC(TransferSignals[idC],C_out,x);

SignExtend extender(SW,SW_extended);
TransferSwitch trSW(TransferSignals[idSW],SW_extended,x);

wire [3:0]ALU_Flags;
ALU_32 alu_32(x,y,ALU_Signals,ALU_Flags,z);

Flag_Reg flag_reg(ALU_Flags,reset,clk,Flags);

assign A_Val[2:0] = A_out[2:0];

assign Answer = x[15:0];

endmodule
