`timescale 1ns / 1ps

// 4 bit Carry Lookahead Adder
module CLA_4(
input wire [3:0] A,	// A in
input wire [3:0] B,	// B in
output wire [3:0] S,	// S out
input wire Cin,		// Carry in
output wire Cout,		//	Carry out
output wire Overflow,// Overflow signal
output wire GG,		// Group generate
output wire PG			// Group propagate
);

wire [3:0] g;
wire [3:0] p;
wire [3:0] C;

FullAdder adder_0(A[0],B[0],Cin ,S[0],,g[0],p[0]);
FullAdder adder_1(A[1],B[1],C[0],S[1],,g[1],p[1]);
FullAdder adder_2(A[2],B[2],C[1],S[2],,g[2],p[2]);
FullAdder adder_3(A[3],B[3],C[2],S[3],,g[3],p[3]);

LCU_4 lcu(g,p,Cin,C,GG,PG);
assign Cout = C[3];
xor (Overflow , Cout , C[2]);

endmodule

// 16 - bit Carry Lookahead Adder
module CLA_16(
input wire [15:0] A,	// A in
input wire [15:0] B,	// B in
output wire[15:0] S,	// S out
input wire Cin,		// Carry in
output wire Cout,		//	Carry out
output wire Overflow,// Overflow signal
output wire GG,		// Group generate
output wire PG			// Group propagate
);

wire [3:0] g;
wire [3:0] p;
wire [3:0] C;

CLA_4 adder_0(A[3:0]  ,B[3:0]  ,S[3:0]  ,Cin ,,        ,g[0],p[0]);
CLA_4 adder_1(A[7:4]  ,B[7:4]  ,S[7:4]  ,C[0],,        ,g[1],p[1]);
CLA_4 adder_2(A[11:8] ,B[11:8] ,S[11:8] ,C[1],,        ,g[2],p[2]);
CLA_4 adder_3(A[15:12],B[15:12],S[15:12],C[2],,Overflow,g[3],p[3]);

LCU_4 lcu(g,p,Cin,C,GG,PG);
assign Cout = C[3];

endmodule

// 32 - bit Carry Lookahead Adder ...
module CLA_32(
input wire [31:0] A,	// A in
input wire [31:0] B,	// B in
output wire[31:0] S,	// S out
input wire Cin,		// Carry in
output wire Cout,		//	Carry out
output wire Overflow // Overflow signal
);

wire carry;

CLA_16 adder_0(A[15:0] ,B[15:0] ,S[15:0] ,Cin  ,carry,        ,,);
CLA_16 adder_1(A[31:16],B[31:16],S[31:16],carry,Cout ,Overflow,,);

endmodule

/**
// 64 - bit Carry Lookahead Adder ... Synthesis of which exceeds memory limit.
module CLA_64(
input wire [63:0] A,	// A in
input wire [63:0] B,	// B in
output wire[63:0] S,	// S out
input wire Cin,		// Carry in
output wire Cout,		//	Carry out
output wire Overflow,// Overflow signal
output wire GG,		// Group generate
output wire PG			// Group propagate
);

wire [3:0] g;
wire [3:0] p;
wire [3:0] C;

// Recursive substructure property : following code is the same as in CLA_16
CLA_16 adder_0(A[15:0] ,B[15:0] ,S[15:0] ,Cin ,,        ,g[0],p[0]);
CLA_16 adder_1(A[31:16],B[31:16],S[31:16],C[0],,        ,g[1],p[1]);
CLA_16 adder_2(A[47:32],B[47:32],S[47:32],C[1],,        ,g[2],p[2]);
CLA_16 adder_3(A[63:48],B[63:48],S[63:48],C[2],,Overflow,g[3],p[3]);

LCU_4 lcu(g,p,Cin,C,GG,PG);
assign Cout = C[3];

endmodule
*/