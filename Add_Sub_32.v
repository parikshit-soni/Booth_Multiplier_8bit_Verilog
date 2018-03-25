`timescale 1ns / 1ps

// 32 bit Adder/Subtracter with carry(borrow) / overflow generation
module Add_Sub_32(
input wire[31:0] x,	// x
input wire[31:0] y,	//	y
input wire Cin,		//	Carry in
input wire Sub,		// Active high subtract
output wire[31:0] z,	//	z
output wire Overflow,//	overflow	flag
output wire Carry		// carry	flag
);

wire [31:0] y_Sub;
wire Cin_Sub;
wire Cout;

assign y_Sub = Sub ? ~y : y;		//invert y
assign Cin_Sub = Sub ? ~Cin : Cin;	//invert Cin

CLA_32 adder_(x,y_Sub,z,Cin_Sub,Cout,Overflow);

assign Carry = Sub ? ~Cout : Cout;

endmodule
