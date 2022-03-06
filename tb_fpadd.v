module fpadder_tb( ); 

	reg [15:0] A, B; 
	reg clk,rst; 
	wire [15:0] C; 
	reg [15:0] expoutput;

fpadder DUT(.A(A),.B(B),.C(C),.clk(clk)); 

initial  
begin 
clk=1'b0; 
forever #20 clk=~clk; 
end  


initial  
	begin 
	rst=1'b0;
	#200
	A=16'h5620;
	B=16'h5948;
	expoutput=16'h5C2C;
	#200
	A=16'h5630;
	B=16'hD590;
	expoutput=16'h4900;
	#200
	A=16'hD1A0;
	B=16'h54F0;
	expoutput=16'h5040;
	#200
	A=16'hDC6C;
	B=16'hD420;
	expoutput=16'hDD74;
	#200
	A=16'h0000;
	B=16'hD750;
	expoutput=16'hD750;
	#200
	A=16'h0000;
	B=16'h0000;
	expoutput=16'h000;
	#200
	A=16'hD6E2;
	B=16'h563E;
	expoutput=16'hC920;
	#200
	A=16'h56EE;
	B=16'h5632;
	expoutput=16'h5A90;
	$finish; 
end  
initial  
begin 
$monitor("A=%h,B=%h, exp=%h, C=%h",A,B,expoutput,C); 
$dumpfile("waves.vcd");
$dumpvars();
end  
endmodule

