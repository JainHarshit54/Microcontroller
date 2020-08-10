`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2019 02:32:41 PM
// Design Name: 
// Module Name: alupipe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alupipe(zout, rs1, rs2, rd, func, addr, clk1, clk2);
input [3:0] rs1,rs2,rd,func;
input [7:0] addr;
input clk1, clk2;
output [15:0] zout;

reg [15:0] L12_A, L12_B, L23_Z, L34_Z;
reg [3:0] L12_rd, L12_func, L23_rd;
reg [7:0] L12_addr, L23_addr, L34_addr;

reg [15:0] regbank [0:15];
reg [15:0] mem [0:255];

assign zout= L34_Z;

always@(posedge clk1)
begin
L12_A <= #2 regbank[rs1];
L12_B <= #2 regbank[rs2];
L12_rd <= #2 rd;
L12_func <= #2 func;
L12_addr <= # 2addr;
end 

always@(negedge clk2)
begin
case(func)
0: L23_Z <= #2 L12_A + L12_B; 
1: L23_Z <= #2 L12_A - L12_B;
2: L23_Z <= #2 L12_A * L12_B;
3: L23_Z <= #2 L12_A;
4: L23_Z <= #2 L12_B ;
5: L23_Z <= #2 L12_A & L12_B;
6: L23_Z <= #2 L12_A | L12_B;
7: L23_Z <= #2 L12_A ^ L12_B;
8: L23_Z <= #2 ~L12_A;
9: L23_Z <= #2 ~L12_B;
10: L23_Z <= #2 L12_A >> 1;
11: L23_Z <= #2 L12_A << 1;
default: L23_Z <= #2 16'hxxxx;
endcase
L23_rd <= #2 L12_rd;
L23_addr <= #2 L12_addr;
end

always@(posedge clk1)
begin
regbank[L23_rd] <= #2 L23_Z;
L34_Z <= #2 L23_Z;
L34_addr <= #2 L23_addr;
end

always@(negedge clk2)
begin
mem[L34_addr] <= #2 L34_Z;
end

endmodule


module testbench;

wire [15:0] z;
reg [3:0] rs1, rs2, rd, func;
reg [7:0] addr;
reg clk1,clk2;
integer k;
reg [7:0] A [0:15]; //memory declaration for storing the contents of file.
reg [3:0] instr [0:15];
reg [3:0] addrin1 [0:15];
reg [3:0] addrin2 [0:15];
integer outfile1;

alupipe DUT(z,rs1,rs2,rd,func,addr,clk1,clk2);

initial 
begin
clk1=0; clk2=0;
repeat(20)
begin
#5 clk1=1; #5 clk2=0;
#5 clk2=1; #5 clk1=0;
end
end

initial
begin 
$readmemb("C:/Users/Srikar/Desktop/A_bin.txt",A);
for(k=0;k<16;k=k+1)
DUT.regbank[k]=A[k];
end

initial
begin
$readmemb("C:/Users/Srikar/Desktop/instruction.txt",instr,0,3);
$readmemb("C:/Users/Srikar/Desktop/instruction.txt",addrin1,0,3);
$readmemb("C:/Users/Srikar/Desktop/instruction.txt",addrin2,0,3);
end

initial
begin
#5 rs1=3; rs2=5; rd=10; func=0; addr=125;
#20 rs1=addrin1[1]; rs2=addrin2[2]; rd=12; func=instr[0]; addr=126;
 
#60; 
end

initial
begin
$dumpfile("pipe.vcd");
$dumpvars(0,testbench);
#300 $finish;
end
endmodule