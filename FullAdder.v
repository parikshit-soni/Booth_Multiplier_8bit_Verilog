`timescale 1ns / 1ps

// 1 - bit full adder with generate and propagate signals
// can be used in a carry - lookahead adder
module FullAdder(
input A,		// A in
input B,		// B in
input Cin,	// Carry / Borrrow in
output S,	// Sum / Difference bit
output Cout,// Carry / Borrow bit
output g,	// Carry / Borrow generate
output p		// Carry / Borrow propagate
);

assign p = A ^ B;
assign g = A & B;
assign S = p ^ Cin;
assign Cout = g|(Cin&p);

endmodule
