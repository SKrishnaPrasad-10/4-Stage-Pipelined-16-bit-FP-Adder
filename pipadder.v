module fpadder( input [15:0] A, input [15:0] B, input clk, input rst, output reg [15:0] C);

reg sign_a, sign_b, sign_a1, sign_b1;
reg sign_c,sign_c1,sign_c2,sign_c3;
reg [4:0] exp_a, exp_b, exp_c, exp_c1,exp_c2,exp_c3;
reg [9:0] man_a, man_b;
reg [10:0] nor_man_a, nor_man_b, nor_man_a1, nor_man_b1;
reg [11:0] sum_c,sum_c1,sum_c2;
reg [11:0] nor_sum_c,nor_sum_c1;
reg [4:0] nor_exp_c,nor_exp_c1;
reg [4:0] rshift, lshift;

parameter d0 = 4'b0000,
		    d1 = 4'b0001,
		    d2 = 4'b0010,
		    d3 = 4'b0011,
		    d4 = 4'b0100,
		    d5 = 4'b0101,
		    d6 = 4'b0110,
		    d7 = 4'b0111,
		    d8 = 4'b1000,
		    d9 = 4'b1001;

always @(*)
	begin
	sign_a = A[15];    //extracting signs, mantissas and exponents from inputs A & B
	exp_a = A[14:10];
	man_a = A[9:0];
	sign_b = B[15];
	exp_b = B[14:10];
	man_b = B[9:0];
	end

always @(*) begin
	if (exp_a > exp_b) begin  //Comparing exponents and shifting the smaller mantissa
		exp_c = exp_a;
		nor_man_a = {1'b1, man_a};
		nor_man_b = {1'b1, man_b} >> (exp_a - exp_b);
		end
	else begin
		exp_c = exp_b;
		nor_man_b = {1'b1, man_b};
		nor_man_a = {1'b1, man_a} >> (exp_b - exp_a);
		end
end
always @(posedge clk) begin  //FIRST PIPELINE to store the values after comparing components & shifting mantissa
		nor_man_a1 <= nor_man_a;
		nor_man_b1 <= nor_man_b;
		exp_c1 <= exp_c;
		sign_a1 <= sign_a;
		sign_b1 <= sign_b;
end

always @(*) begin
	if (sign_a1 == sign_b1) begin  //Adding the mantissas if they're both of same sign
		sign_c1 = sign_a1;
		sum_c = nor_man_a1 + nor_man_b1;
	end
	else if(nor_man_a1 > nor_man_b1) begin //Comparing the aligned mantissas and adding them
			sign_c1 = sign_a1;
			sum_c = nor_man_a1 + ((~nor_man_b1) + 1'b1);
		end
	else if(nor_man_b1 > nor_man_a1) begin
			sign_c1 = sign_b1;
			sum_c = nor_man_b1 + ((~nor_man_a1) + 1'b1);
		end
end

always @(posedge clk) begin //SECOND PIPELINE to store the values after adding two mantissas
	exp_c2 <= exp_c1;
	sign_c2 <= sign_c1;
	sum_c1 <= sum_c;
end

always @(*) begin   //Finding the amount of shifts required
	if (sum_c1[11] == 1'b1) begin
		rshift = d1;
		end
	else if (sum_c1[10] == 1'b1) begin
		lshift = d0;
		end
	else if (sum_c1[9] == 1'b1) begin
		lshift = d1;
		end
	else if (sum_c1[8] == 1'b1) begin
		lshift = d2;
		end
	else if (sum_c1[7] == 1'b1) begin
		lshift = d3;
		end
	else if (sum_c1[6] == 1'b1) begin
		lshift = d4;
		end
	else if (sum_c1[5] == 1'b1) begin
		lshift = d5;
		end
	else if (sum_c1[4] == 1'b1) begin
		lshift = d6;
		end
	else if (sum_c1[3] == 1'b1) begin
		lshift = d7;
		end
	else if (sum_c1[2] == 1'b1) begin
		lshift = d8;
		end
	else if (sum_c1[1] == 1'b1) begin
		lshift = d9;
		end
end

always @(posedge clk) begin //THIRD PIPELINE after counting number of shifts
	exp_c3 <= exp_c2;
	sign_c3 <= sign_c2;
	sum_c2 <= sum_c1;
end

always @(*) begin
	if (sum_c2[11] == 1'b1) begin     //Normalizing both the mantissa and exponent
		nor_sum_c1 = sum_c2 >> 1'b1;
		nor_exp_c1 = (exp_c3  + 'b01);
		end
	else if (sum_c2[10] == 1'b1) begin
		nor_sum_c1 = sum_c2 ;
		nor_exp_c1 = exp_c3 ;
		end
	else if (sum_c2[9] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 2'b01;
		nor_exp_c1 = (exp_c3 - 'b01);
		end
	else if (sum_c2[8] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 3'b10;
		nor_exp_c1 = (exp_c3 - 'b10);
		end
	else if (sum_c2[7] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 2'b11;
		nor_exp_c1 = (exp_c3 - 'b11);
		end
	else if (sum_c2[6] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 3'b100;
		nor_exp_c1 = (exp_c3 - 'b100);
		end
	else if (sum_c2[5] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 3'b101;
		nor_exp_c1 = (exp_c3 - 'b101);
		end
	else if (sum_c2[4] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 3'b110;
		nor_exp_c1 = (exp_c3 - 'b110);
		end
	else if (sum_c2[3] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 3'b111;
		nor_exp_c1 = (exp_c3 - 'b111);
		end
	else if (sum_c2[2] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 4'b1000;
		nor_exp_c1 = (exp_c3 - 'b1000);
		end
	else if (sum_c2[1] == 1'b1) begin
		nor_sum_c1 = sum_c2 << 4'b1001;
		nor_exp_c1 = (exp_c3 - 'b1001);
		end
	else begin
		nor_sum_c1 = sum_c2;
		nor_exp_c1 = exp_c3;
	end
end

always @(posedge clk) begin   //FOURTH PIPELINE after normalisation of mantissa and exponents
		nor_sum_c <= nor_sum_c1;
		nor_exp_c <= nor_exp_c1;
		sign_c <= sign_c3;
end

always @(*) begin
		if( (A==0) && (B==0)) begin //Special case if both the inputs are zero
				C = 0; end 
			else begin
		 C = {sign_c,nor_exp_c[4:0], nor_sum_c[9:0]}; // Final adder SUM
		end
end

endmodule
