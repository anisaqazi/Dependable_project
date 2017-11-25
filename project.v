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
wire cin0X;
wire [WIDTH-1:0]ainX;
wire [WIDTH-1:0]binX;

wire [WIDTH-1:0] sum_outY;
wire [WIDTH-1:0] sum_outY_check;
wire YC_check;
wire cin0Y;
wire [WIDTH-1:0]ainY;
wire [WIDTH-1:0]binY;

assign cin0X = C0 ? 1'b0 : 1'b1;
assign ainX = {(C2^A2), (C2^A1), (C2^A0)};  
assign binX = {(C1^B2), (C1^B1), (C1^B0)};  

assign cin0Y = C0 ? 1'b0 : 1'b1;
assign ainY = {(C2^A2), (C2^A1), (C2^A0)};  
assign binY = {(C1^B2), (C1^B1), (C1^B0)};  

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
 


assign {X2,X1,X0} = sum_outX;

assign XE0 = 1'b0;
	
assign XE1 = ~(A0^A1^A2^B0^B1^B2^PAR)     ? XE0 :       // Not odd parity
	     ~( ~(C0&C1&C2) & (C0^C1^C2)) ? XE0 :       // Not one hot
	     ({XC,sum_outX}!={XC_check,sum_outX_check})	  ? XE0 :	// error in TMR
			 		   ~XE0 ;
		
//Logic for Y path			
//rca ripple_carry0(.a	(ainY),
//	          .b	(binY),
//		  .cin	(cin0Y),
//		  .sum	(sum_outY),
//		  .cout	(YC)
//		  );
rca_tmr rca_tmrY(	.ain(ainY),
			.bin(binY),
			.cin0(cin0Y),
			.sum(sum_outY),
			.cout(YC));


 rca ripple_carry_check_adderY(	.a	(ainY),
 		   		.b	(binY),
 		   		.cin	(cin0Y),
 		   		.sum	(sum_outY_check),
 		   		.cout	(YC_check)
 		   		);
 

assign {Y2,Y1,Y0} = sum_outY;

assign YE0 = 1'b0;

assign YE1 = ~(A0^A1^A2^B0^B1^B2^PAR)     ? YE0 :       // Not odd parity
	     ~( ~(C0&C1&C2) & (C0^C1^C2)) ? YE0 :       // Not one hot
	     ({YC,sum_outY}!={YC_check,sum_outY_check})	  ? YE0 :	// error in TMR
			 		   ~YE0 ;
		
	


//assign Y0 = 0;
//assign Y1 = 0;
//assign Y2 = 0;
//assign YE0 = 0;
//assign YE1 = 0;
//assign YC = 0;
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


