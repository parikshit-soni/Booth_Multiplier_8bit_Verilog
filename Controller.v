`timescale 1ns / 1ps

// Select next operation on register B
module Normalize(
input wire [2:0]In,	// 3 LSBs
output wire [2:0]Out	//	0 : Zero ? 1 : Neg ? 2 : x2 ?
);
assign Out[0] = (~In[0]&~In[1]&~In[2])|(In[0]&In[1]&In[2]);
assign Out[1] = In[2] & ( ~ (In[0] & In[1]) );
assign Out[2] = (~In[0]&~In[1]&In[2])|(In[0]&In[1]&~In[2]);
endmodule


module Controller(
input wire Go,
input wire clk,
input wire rst,//machine reset

output wire data_reset,
output wire Over,

output wire [3:0]TransferSignals,
output wire [2:0]LoadSignals,
output wire [11:0]ALU_Signals,
output ShiftLeftSignal,

input wire [3:0]Flags,
input wire [2:0]A_Val
);

wire [2:0]Op_Status;
Normalize normalize(A_Val,Op_Status);

// State IDs
parameter INIT =		0;
parameter LOAD_A =	1;
parameter CHK_A =		2;
parameter LOAD_B =	3;
parameter CHK_B  =	4;
parameter SHL_A = 	5;
parameter INC_C =		6;
parameter SHL_C =		7;
parameter SHL_C2=		8;
parameter SHR_A =		9;
parameter SHR_A2=		10;
parameter DEC_C =		11;
parameter SHR_A3=		12;
parameter ERR_C =		13;
parameter OVER =		14;
parameter ADD_B =		15;

reg [15:0]State;
reg A_N, B_N;// A / B is negative ?

initial begin
	A_N = 0;B_N = 0;
	State = 0;State[INIT] = 1;
end

always @ (posedge clk) begin
	if(rst) begin
		A_N = 0;B_N = 0;
		State = 0;State[INIT]=1;
	end else if(State[INIT]) begin
		if(Go) begin 
			State[INIT]  = 0;
			State[LOAD_A] = 1;
		end
	end else if(State[LOAD_A]) begin
		if(!Go) begin 
			State[LOAD_A] = 0;
			State[CHK_A] = 1;
			A_N = Flags[1];	// SF
		end
	end else if(State[CHK_A]) begin
		State[CHK_A] = 0;
		State[LOAD_B] = 1;
	end else if(State[LOAD_B]) begin
		if(Go) begin 
			State[LOAD_B] = 0;
			State[CHK_B] = 1;
			B_N = Flags[1];	// SF
		end
	end else if(State[CHK_B]) begin
		State[CHK_B] = 0;
		State[SHL_A] = 1;
	end else if(State[SHL_A]) begin
		State[SHL_A] = 0;
		State[INC_C] = 1;
	end else if(State[INC_C]) begin
		State[INC_C]  = 0;
		State[SHL_C]  = 1;
	end else if(State[SHL_C]) begin
		State[SHL_C]  = 0;
		State[SHL_C2]  = 1;
	end else if(State[SHL_C2]) begin
		State[SHL_C2] = 0;
		if(Op_Status[0]) begin
			State[SHR_A] = 1;
		end else begin
			State[ADD_B] = 1;
		end
	end else if(State[SHR_A]) begin
		State[SHR_A] = 0;
		State[SHR_A2] = 1;
	end else if(State[SHR_A2]) begin
		State[SHR_A2] = 0;
		State[DEC_C] = 1;	
	end else if(State[DEC_C]) begin
		State[DEC_C] = 0;
		if( Flags[0] ) begin // ZF
			State[SHR_A3] = 1;
		end else begin
			if(Op_Status[0]) begin
				State[SHR_A] = 1;
			end else begin
				State[ADD_B] = 1;
			end
		end
	end else if(State[SHR_A3]) begin
		State[SHR_A3] = 0;
		State[ERR_C] = 1;
	end else if(State[ERR_C]) begin
		State[ERR_C] = 0;
		State[OVER] = 1;
	end else if(State[ADD_B]) begin
		State[ADD_B] = 0;
		State[SHR_A] = 1;
	end else if(State[OVER]) begin
		if(!Go) begin
			State[OVER] = 0;
			State[INIT] = 1;
			A_N = 0;B_N = 0;
		end
	end
end

// Data source IDs
parameter idA = 0;
parameter idB = 1;
parameter idC = 2;
parameter idSW= 3;

assign data_reset = State[INIT];
assign TransferSignals[idA] = 
	State[ADD_B] | State[SHR_A] | State[SHR_A2] | State[SHR_A3] | State[SHL_A] | State[OVER] | (A_N & B_N & State[ERR_C]);
assign TransferSignals[idB] = State[ADD_B] ;
assign TransferSignals[idC] = State[INC_C] | State[SHL_C] | State[SHL_C2] | State[DEC_C];
assign TransferSignals[idSW] = State[LOAD_A] | State[LOAD_B];

assign LoadSignals[idA] = 
	State[LOAD_A] | State[SHR_A] | State[SHR_A2] | State[SHR_A3] | State[SHL_A] | State[ADD_B] | (A_N & B_N & State[ERR_C]);
assign LoadSignals[idB] = State[LOAD_B];
assign LoadSignals[idC] = TransferSignals[idC];

assign ShiftLeftSignal = State[ADD_B] & Op_Status[2];

assign ALU_Signals[0] = (State[ADD_B] & ~Op_Status[1]);						//ADD
assign ALU_Signals[1] = (State[ADD_B] & Op_Status[1]) ;						//SUB
assign ALU_Signals[2] = State[INC_C] | (A_N & B_N & State[ERR_C]);		//INX
assign ALU_Signals[3] = State[DEC_C] ;												//DCX
assign ALU_Signals[4] = State[LOAD_A] | State[LOAD_B];						//CPX
assign ALU_Signals[5] = State[SHL_A] | State[SHL_C] | State[SHL_C2] ;	//SHLX
assign ALU_Signals[7] = State[SHR_A] | State[SHR_A2] | State[SHR_A3] ;	//SRAX

assign ALU_Signals[6] = 0;																//Rest of the signals
assign ALU_Signals[11:8] = 0;															//

assign Over = State[OVER];

endmodule
