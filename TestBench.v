`timescale 1ns / 1ps


module TestBench;

	// Inputs
	reg clk;
	reg rst;
	reg [7:0] SW;
	reg Go;

	// Outputs
	wire [15:0] Answer;
	wire Over;
	
	// Instantiate the Unit Under Test (UUT)
	Booth_SPM uut (
		clk,
		rst,
		SW,
		Answer,
		Go,
		Over
	);
	
	wire [15:0] Control_State;
	wire A_N;
	wire B_N;
	
	wire [31:0] Reg_A;
	wire [3:0] Flags;
	wire [31:0] Reg_B;
	wire [31:0] Reg_I;
	
	wire [31:0] x;
	wire [31:0] y;
	wire [31:0] z;
	
	assign Control_State = uut.controller.State;
	assign A_N = uut.controller.A_N;
	assign B_N = uut.controller.B_N;
	assign Flags = uut.controller.Flags;
	assign Reg_A = uut.datapath.A_out;
	assign Reg_B = uut.datapath.B_2B;
	assign Reg_I = uut.datapath.C_out;
	
	assign x = uut.datapath.x;
	assign y = uut.datapath.y;
	assign z = uut.datapath.z;
	
	wire [3:0]TransferSignals;
	wire [2:0]LoadSignals;
	
	assign TransferSignals = uut.controller.TransferSignals;
	assign LoadSignals = uut.controller.LoadSignals;
	
	always begin
		clk = !clk;#10;
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		Go = 0;
		
		SW = 0;SW[7:0] = 253;//A
		#40;
		Go = 1;
		#40;
		SW = 0;SW[7:0] = 254;//B
		Go = 0;
		#40;
		Go = 1;
		
		// Wait 1000 ns for global reset to finish
		#1000;
		$finish;
		// Add stimulus here
	end
      
endmodule

