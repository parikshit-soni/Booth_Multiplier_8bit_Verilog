`timescale 1ns / 1ps

// 4 - block Lookahead carry unit.
// Reference : https://en.wikipedia.org/wiki/Lookahead_carry_unit
module LCU_4(
input wire [3:0]g,	// "generate carry" signals
input wire [3:0]p,	// "propagate carry" signals
input wire Cin,		// carry in
output wire [3:0]C,	// carry bit ... C[3] is carry out
output wire GG,		// group generate signal
output wire PG			// group propagate signal
);

wire temp0;
and(temp0 , p[0] , Cin );
or(C[0] , g[0] , temp0);

wire temp1 , temp2;
and(temp1 , g[0] , p[1]);
and(temp2 , Cin , p[0] , p[1]);
or(C[1] , g[1] , temp1 , temp2);

wire temp3 , temp4 , temp5;
and(temp3 , g[1] , p[2]);
and(temp4 , g[0] , p[1] , p[2]);
and(temp5 , Cin , p[0] , p[1] , p[2]);
or(C[2] , g[2] , temp3 , temp4 , temp5);

wire temp6 , temp7 , temp8, temp9;
and(temp6 , g[2] , p[3]);
and(temp7 , g[1] , p[2] , p[3]);
and(temp8 , g[0] , p[1] , p[2] , p[3]);
and(temp9 , Cin , p[0] , p[1] , p[2] , p[3]);
or(C[3] , g[3] , temp6 , temp7 , temp8 , temp9);

and(PG , p[0] , p[1] , p[2] , p[3]);

wire temp10 , temp11 , temp12;
and(temp10 , g[2] , p[3]);
and(temp11 , g[1] , p[2] , p[3]);
and(temp12 , g[0] , p[1] , p[2] , p[3]);
or(GG , g[3] , temp10 , temp11 , temp12);

endmodule
