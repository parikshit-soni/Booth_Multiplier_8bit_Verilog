`timescale 1ns / 1ps

// Generic 32 - bit ALU
module ALU_32(
input wire[31:0] x,
input wire[31:0] y,
input wire[11:0] OpCode,
output wire[3:0] Flags,
output wire[31:0]z
);

// Operation codes
parameter ADD = 0;//12'b000000000001;//0
parameter SUB = 1;//12'b000000000010;//1
parameter INX = 2;//12'b000000000100;//2
parameter DCX = 3;//12'b000000001000;//3

parameter CPX = 4;//12'b000000010000;//4
parameter SHL = 5;//12'b000000100000;//5
parameter SHR = 6;//12'b000001000000;//6
parameter SRA = 7;//12'b000010000000;//7

parameter AND = 8;//12'b000100000000;//8
parameter OR  = 9;//12'b001000000000;//9
parameter XOR =10;//12'b010000000000;//10
parameter NOT =11;//12'b100000000000;//11

// Flag codes
parameter ZF = 0;//2'b01 // Zero flag
parameter SF = 1;//2'b10 // Sign flag
parameter OF = 2;//2'b10 // Overflow flag
parameter CF = 3;//2'b10 // Carry flag

/*Arithmetic functions*/
wire Cin,Sub;
wire [31:0]z_Ar;
wire [31:0]yy;
or(Cin , OpCode[INX], OpCode[DCX]);
or(Sub , OpCode[SUB], OpCode[DCX]);
assign yy = Cin ? 0 : y;
Add_Sub_32 add_sub_32(x,yy,Cin,Sub,z_Ar,Flags[OF],Flags[CF]);
/**********************/

/*Logic functions*/
wire [31:0] z_Lg;
assign z_Lg = (OpCode[AND] ? (x&y) : (OpCode[OR] ? (x|y) : (OpCode[XOR] ? (x^y) : ~x ) ) );
/*****************/

/*Shift functions*/
wire [31:0] z_Sh;
assign z_Sh[30:1] = (OpCode[CPX] ? x[30:1] : (OpCode[SHL] ? x[29:0] : x[31:2]) );
assign z_Sh[0] = (OpCode[CPX] ? x[0] : ((OpCode[SHR]|OpCode[SRA]) ? x[1] : 0) );
assign z_Sh[31] = (OpCode[CPX] ? x[31] : (OpCode[SHL] ? x[30] : (OpCode[SRA] ? x[31] : 0) ) );
/*****************/

wire Op_Ar , Op_Lg, Op_Sh;
or(Op_Ar , OpCode[ADD] , OpCode[SUB] , OpCode[INX] , OpCode[DCX]);//arithmetic
or(Op_Lg , OpCode[AND] , OpCode[OR] , OpCode[XOR] , OpCode[NOT]);//logic
or(Op_Sh , OpCode[SHL] , OpCode[SHR] , OpCode[SRA], OpCode[CPX]);//shift

assign z = (Op_Ar ? z_Ar : (Op_Lg ? z_Lg : (Op_Sh ? z_Sh : 0) ) );

assign Flags[ZF] = (z == 0);
assign Flags[SF] = ( (Op_Ar | Op_Sh) & z[31] );

endmodule
