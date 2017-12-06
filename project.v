/**************************************************************************/
/*  Stub for Project in EE382M - Dependable Computing
*/
/*
*/
/*  Do not change I/O names in main() module
*/
/*
*/
/**************************************************************************/

module main(A0,A1,A2,B0,B1,B2,PAR,C0,C1,C2,X0,X1,X2,XC,XE0,XE1,
            Y0,Y1,Y2,YC,YE0,YE1);
parameter WIDTH = 3;
input A0,A1,A2,B0,B1,B2,PAR,C0,C1,C2;
output X0,X1,X2,XC,XE0,XE1,Y0,Y1,Y2,YC,YE0,YE1;
/* add your design here */
wire [WIDTH-1:0] sum_outX;
wire [WIDTH-1:0] sum_outX_check;
wire XC_check;

wire [5:0]	two_railX_inA;
wire [5:0]	two_railX_inB;
wire errX;
wire errX_b;

wire 		cin0X;
wire [WIDTH-1:0]ainX;
wire [WIDTH-1:0]binX;

wire cin0Y;
wire [WIDTH-1:0]ainY;
wire [WIDTH-1:0]binY;

wire [WIDTH-1:0] sumY;
wire [WIDTH-1:0] sumY1;
wire [WIDTH-1:0] sumY2;
wire [WIDTH-1:0] sum_outY;
wire 		 YC_out;
wire 		 YC0;
wire 		 YC1;
wire 		 YC2;
wire YC_check;
wire cin0Y_checker;

wire error_outY;
wire err0_y;
//wire err1_y;

assign cin0X = ~C0;
assign ainX = {(C2^A2), (C2^A1), (C2^A0)};  
assign binX = {(C1^B2), (C1^B1), (C1^B0)};  

assign cin0Y = ~C0;
assign ainY = {(C2^A2), (C2^A1), (C2^A0)};  
assign binY = {(C1^B2), (C1^B1), (C1^B0)};  
assign cin0Y_checker = ~C0;

// Logic for X path
rca_tmr rca_tmrX(	.ain(ainX),
			.bin(binX),
			.cin0(cin0X),
			.sum(sum_outX),
			.cout(XC));

 rca ripple_carry_check_adderX(	.a	(ainX),
 		   		.b	(binX),
 		   		.cin	(cin0X),
 		   		.sum	(sum_outX_check),
 		   		.cout	(XC_check)
 		   		);

assign two_railX_inA[5] = C0;
assign two_railX_inA[4] = PAR;
assign two_railX_inA[3] = XC;
assign two_railX_inA[2:0] = sum_outX;
 
assign two_railX_inB[5] = (C1^C2) | (C2 & C0);
assign two_railX_inB[4] = A0^A1^A2^B0^B1^B2;
assign two_railX_inB[3] = ~XC_check;
assign two_railX_inB[2:0] = ~sum_outX_check;
 
two_rail_tree_6bit two_rail_check( .A(two_railX_inA),
			 	   .B(two_railX_inB),
			 	   .err(XE0),
			 	   .err_b(XE1)
			 	  );


assign {X2,X1,X0} = sum_outX;

//Logic for Y path			
		
//assign {Y2,Y1,Y0} = sum_outY;
//assign YE0 = err0_y;
//assign YE1 = ~(A0^A1^A2^B0^B1^B2^PAR)     ? YE0 :       // Not odd parity
//	     ~( ~(C0&C1&C2) & (C0^C1^C2)) ? YE0 :       // Not one hot
//			 		   err1_y ;
		
rca rcaY0(	.a	(ainY),
    		.b	(binY),
    		.cin	(cin0Y),
    		.sum	(sum_outY),
    		.cout	(YC_out)
    		);
	
residue_check checkY(	.a	(ainY),
			.b	(binY),
			.cin	(cin0Y_checker),
			.sum_in	(sum_outY),
			.cout_in(YC_out),
			.sum_out(sumY),
			.cout	(YC0),
			.error_flag(err0_y)	//can dual rail be done?
			);

rca rcaY1(	.a	(ainY),
    		.b	(binY),
    		.cin	(cin0Y),
    		.sum	(sumY1),
    		.cout	(YC1)
    		);
	
rca rcaY2(	.a	(ainY),
    		.b	(binY),
    		.cin	(cin0Y),
    		.sum	(sumY2),
    		.cout	(YC2)
    		);
	
assign {Y2,Y1,Y0} = ({err0_y,YC0,sum_outY} == {1'b0,YC1,sumY1}) ? sum_outY :
 					  ({YC1,sumY1} == {YC2,sumY2}) ? sumY1 : sumY2;
assign {error_outY,YC} = ({err0_y,YC0,sum_outY} == {1'b0,YC1,sumY1}) ? {1'b0,YC0} :
 					  ({YC1,sumY1} == {YC2,sumY2}) ? {1'b0,YC1} : 
 					  ({1'b0,YC2,sumY2} == {err0_y,YC0,sum_outY}) ? {1'b0,YC2} : {1'b1,YC2};

//assign {Y2,Y1,Y0} = sumY;
assign YE0 = 1'b1;
assign YE1 = ~(A0^A1^A2^B0^B1^B2^PAR)     ? YE0 :       // Not odd parity
	     ~( ~(C0&C1&C2) & (C0^C1^C2)) ? YE0 :       // Not one hot
	     error_outY			  ? YE0 :
					   ~YE0 ;


//assign X0 = 0;
//assign X1 = 0;
//assign X2 = 0;
//assign XE0 = 0;
//assign XE1 = 0;
//assign XC = 0;

//assign Y0 = 0;
//assign Y1 = 0;
//assign Y2 = 0;
//assign YE0 = 0;
//assign YE1 = 0;
//assign YC = 0;
endmodule

module residue_check(	a,
			b,
			cin,
			sum_in,
			cout_in,
			sum_out,
			cout,
			error_flag	//can dual rail be done?
			);

input [2:0]	a;
input [2:0]	b;
input 		cin;
input [2:0]	sum_in;
input 		cout_in;
output [2:0]	sum_out;
output		cout;
output		error_flag;

wire [2:0] int_sum;
wire [2:0] sum_b;
wire [2:0] int_carry;
wire cout_b;
wire [3:0] error;

    fulladder fa0(a[0], b[0], sum_b[0], int_sum[0], int_carry[0]);
    fulladder fa1(a[1], b[1], sum_b[1], int_sum[1], int_carry[1]);
    fulladder fa2(a[2], b[2], sum_b[2], int_sum[2], int_carry[2]);


assign sum_b = ~sum_in;
assign cout_b = ~cout_in;
assign error[0] = ~(int_sum[0]^cin);
assign error[1] = ~(int_sum[1]^int_carry[0]);
assign error[2] = ~(int_sum[2]^int_carry[1]);
assign error[3] = ~(cout_b^int_carry[2]);

assign sum_out[0] = (~(a[0]^b[0]) & (sum_in[0]^error[0])) | ((a[0]^b[0]) & ((~error[2] & error[1] & error[0])^sum_in[0]));
assign sum_out[1] = (~(a[1]^b[1]) & (sum_in[1]^error[1])) | ((a[1]^b[1]) & ((error[2] & error[1] & ~error[0])^sum_in[1]));
assign sum_out[2] = (error[2] & ~error[1] & ~error[0]) ^ sum_in[2];
assign cout 	= (error[3] ^ cout_in);

assign error_flag = (error[2] & error[0]) | (error[3]&(error[2]|error[1]|error[0]));

endmodule

module csa_dmr( ain,
		bin,
		cin,
		sum,
		cout,
		err0,
		err1
	);
input [2:0]	ain;
input [2:0]	bin;
input		cin;
output [2:0]	sum;
output 		cout;
output 		err0;
output 		err1;

wire [2:0] 	sum_outA;
wire 		coutA;
wire		err0_A;
wire		err1_A;

wire [2:0] 	sum_outB;
wire 		coutB;
wire		err0_B;
wire		err1_B;

csa csaA(	.ain(ain),
		.bin(bin),
		.cin(cin),
		.sum(sum_outA),
		.cout(coutA),
		.err0(err0_A),
		.err1(err1_A)
	);

csa csaB(	.ain(ain),
		.bin(bin),
		.cin(cin),
		.sum(sum_outB),
		.cout(coutB),
		.err0(err0_B),
		.err1(err1_B)
	);

assign {err1, err0,cout,sum} = (err0_A ^ err1_A) ? {err1_A,err0_A,coutA,sum_outA}:
						   {err1_B,err0_B,coutB,sum_outB};	
endmodule


module rca(a,b,cin,sum,cout);
 	parameter WIDTH = 3;
 	input [WIDTH-1:0]a;
 	input [WIDTH-1:0]b;
 	input cin;
 	output [WIDTH-1:0]sum;
 	output cout;

 	wire cout0;
 	wire cout1;

 	fulladder fa0(a[0], b[0], cin, sum[0], cout0);
 	fulladder fa1(a[1], b[1], cout0, sum[1], cout1);
 	fulladder fa2(a[2], b[2], cout1, sum[2], cout);
endmodule

module self_repair_rca(a,b,cin,sum,cout);
 	parameter WIDTH = 3;
 	input [WIDTH-1:0]a;
 	input [WIDTH-1:0]b;
 	input cin;
 	output [WIDTH-1:0]sum;
 	output cout;

 	wire cout0;
 	wire cout1;

 	self_repair_fulladder fa0(a[0], b[0], cin, sum[0], cout0);
 	self_repair_fulladder fa1(a[1], b[1], cout0, sum[1], cout1);
 	self_repair_fulladder fa2(a[2], b[2], cout1, sum[2], cout);
endmodule


module csa(	ain,
		bin,
		cin,
		sum,
		cout,
		err0,
		err1
	);
input [2:0]	ain;
input [2:0]	bin;
input		cin;
output [2:0]	sum;
output 		cout;
output 		err0;
output 		err1;

wire [2:0]	sum0;
wire 		cout0;

wire [2:0]	sum1;
wire 		cout1;

wire 		z;
wire 		z_b;

rca ripple_carry0(.a	(ain),
 		   .b	(bin),
 		   .cin	(1'b0),
 		   .sum	(sum0),
 		   .cout(cout0)
 		   );
 
 
rca ripple_carry1(.a	(ain),
 		   .b	(bin),
 		  .cin	(1'b1),
 		  .sum	(sum1),
 		  .cout	(cout1)
 		  );

two_rail_check rail0(	.x	(sum0[0]),
		      	.x_b	(sum1[0]),
		      	.y	(~(sum0[0]^sum1[1])),
		      	.y_b	(sum0[1]),
		      	.z	(z),
		      	.z_b	(z_b)
);

two_rail_check rail1(	.x	(z),
		      	.x_b	(z_b),
		      	.y	(sum0[2]),
		      	.y_b	(sum1[2]),
		      	.z	(err0),
		      	.z_b	(err1)
);

assign cout = cin ? cout1 : cout0;
assign sum  = cin ? sum1  : sum0;

endmodule

module two_rail_tree_6bit(A,
			  B,
			  err,
			  err_b
			 );
input	[5:0]	A;
input	[5:0]	B;
output		err;
output		err_b;


wire	err01;
wire	err01_b;
wire	err23;
wire	err23_b;
wire	err45;
wire	err45_b;
wire	err02;
wire	err02_b;

two_rail_check rail01(	.x	(A[0]),
		      	.x_b	(B[0]),
		      	.y	(A[1]),
		      	.y_b	(B[1]),
		      	.z	(err01),
		      	.z_b	(err01_b)
);

two_rail_check rail23(	.x	(A[2]),
		      	.x_b	(B[2]),
		      	.y	(A[3]),
		      	.y_b	(B[3]),
		      	.z	(err23),
		      	.z_b	(err23_b)
);

two_rail_check rail45(	.x	(A[4]),
		      	.x_b	(B[4]),
		      	.y	(A[5]),
		      	.y_b	(B[5]),
		      	.z	(err45),
		      	.z_b	(err45_b)
);

two_rail_check rail02(.x	(err01),
		      	.x_b	(err01_b),
		      	.y	(err23),
		      	.y_b	(err23_b),
		      	.z	(err02),
		      	.z_b	(err02_b)
);

two_rail_check rail_out(.x	(err02),
		      	.x_b	(err02_b),
		      	.y	(err45),
		      	.y_b	(err45_b),
		      	.z	(err),
		      	.z_b	(err_b)
);


endmodule

module two_rail_check(x,
		      x_b,
		      y,
		      y_b,
		      z,
		      z_b
);

input 	x;
input 	x_b;
input 	y;
input 	y_b;
output 	z;
output 	z_b;


assign z = (x_b & y_b) | (x & y);
assign z_b = (x_b & y)   | (x & y_b);

endmodule


module rca_tmr(	ain,
		bin,
		cin0,
		sum,
		cout);

parameter WIDTH = 3;
input [2:0] ain;
input [2:0] bin;
input cin0;
output [2:0] sum;
output cout;

wire [WIDTH-1:0]X_rca0;
wire [WIDTH-1:0]X_rca1;
wire [WIDTH-1:0]X_rca2;
wire XC_rca0;
wire XC_rca1;
wire XC_rca2;


 rca ripple_carry0(.a	(ain),
 		   .b	(bin),
 		   .cin	(cin0),
 		   .sum	(X_rca0),
 		   .cout(XC_rca0)
 		   );
 
 
 rca ripple_carry1(.a	(ain),
 		   .b	(bin),
 		  .cin	(cin0),
 		  .sum	(X_rca1),
 		  .cout	(XC_rca1)
 		  );
 
 rca ripple_carry2(.a	(ain),
     		   .b	(bin),
 		   .cin	(cin0),
 		   .sum	(X_rca2),
 		   .cout(XC_rca2)
 		   );
 
 assign sum = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1}) ? X_rca0 :
 					  ({XC_rca1,X_rca1} == {XC_rca2,X_rca2}) ? X_rca1 : X_rca2;
 assign cout = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1}) ? XC_rca0 :
 					  ({XC_rca1,X_rca1} == {XC_rca2,X_rca2}) ? XC_rca1 : XC_rca2;

endmodule

//module fulladder(a, b, cin, sum, cout);
//input a, b, cin;
//output sum, cout;
//
//wire aXORb = a^b;
//
//assign sum = aXORb^cin;
//assign cout = aXORb ? cin:a;
//endmodule

module fulladder(a, b, cin, sum, cout);
input a, b, cin;
output sum, cout;
assign sum = a^b^cin;
assign cout = (a&b) | (b&cin) | (cin&a);
endmodule

module self_repair_fulladder(a, b, cin, sum, cout);
input a, b, cin;
output sum, cout;

wire sum_w,cout_w;
wire err_s, err_c;
assign sum_w = a^b^cin;
assign cout_w = (a&b) | (b&cin) | (cin&a);

assign err_s = ((a^b) ^ (sum_w^cin));
//assign err_c = ((cout_w ^ cin) ^ ((~a & ~b & cin) | (a & b & ~cin)));  //from paper
assign err_c = (cout_w ^ ((a&b) | (b&cin) | (cin&a)));


assign sum  = err_s ? ~sum_w  : sum_w;
//assign sum  =  sum_w;
assign cout = err_c ? ~cout_w : cout_w;
//assign cout = cout_w;

endmodule


