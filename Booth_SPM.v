`timescale 1ns / 1ps


module Booth_SPM(
input wire clk,
input wire rst,
input wire [7:0]SW,
output wire[15:0]Answer,
input wire Go,
output wire Over
);

wire data_reset;

wire [3:0]	TransferSignals;
wire [2:0]	LoadSignals;
wire [11:0]	ALU_Signals;
wire ShiftLeftSignal;

wire [3:0]Flags;
wire [2:0]A_Val;

Datapath datapath(
~clk,
data_reset,
SW,
TransferSignals,
LoadSignals,
ALU_Signals,
ShiftLeftSignal,
Flags,
A_Val,
Answer
);

Controller controller(
Go,
clk,
rst,
data_reset,
Over,
TransferSignals,
LoadSignals,
ALU_Signals,
ShiftLeftSignal,
Flags,
A_Val
);

endmodule
