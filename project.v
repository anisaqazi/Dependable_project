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
wire dumb;
wire error_tmrX;
wire cin0;
wire [WIDTH-1:0]ain;
wire [WIDTH-1:0]bin;
assign cin0 = C0 ? 1'b0 : 1'b1;
assign ain = {(C2^A2), (C2^A1), (C2^A0)};  
assign bin = {(C1^B2), (C1^B1), (C1^B0)};  

//no tmr rca ripple_carry0(.a	(ain),
//no tmr 	          .b	(bin),
//no tmr 		  .cin	(cin0),
//no tmr 		  .sum	(sum_outX),
//no tmr 		  .cout	(XC)
//no tmr 		  );
//no tmr 


rca_tmr rca_tmrX(	.ain(ain),
			.bin(bin),
			.cin0(cin0),
			.sum(sum_outX),
			.odd_PAR(PAR),
			.error_out(error_tmrX),
			.cout(XC));

 rca ripple_carry_check_adder(.a	(ain),
 		   .b	(bin),
 		   .cin	(cin0),
 		   .sum	(sum_outX_check),
 		   .cout(XC_check),
		   .odd_PAR(PAR),
 		   .error_parity(dumb)
 		   );
 


assign {X2,X1,X0} = sum_outX;

assign XE0 = 1'b0;
	
//assign XE1 = ~error_tmrX;
		
assign XE1 = ~(A0^A1^A2^B0^B1^B2^PAR)     ? XE0 :       // Not odd parity
	     ~( ~(C0&C1&C2) & (C0^C1^C2)) ? XE0 :       // Not one hot
	     ({XC,sum_outX}!={XC_check,sum_outX_check})	  ? XE0 :	// error in TMR
			 		   ~XE0 ;
		
		
//correct assign XE1 = ~(A0^A1^A2^B0^B1^B2^PAR)     ? XE0 :       // Not odd parity
//correct 	     ~( ~(C0&C1&C2) & (C0^C1^C2)) ? XE0 :       // Not one hot
//correct 	     error_tmrX		  	  ? XE0 :	// error in TMR
//correct 			 		   ~XE0 ;
		
			
assign Y0 = 0;
assign Y1 = 0;
assign Y2 = 0;
assign YE0 = 0;
assign YE1 = 0;
assign YC = 0;
endmodule

module rca(a,b,cin,sum,cout,odd_PAR,error_parity);
 	parameter WIDTH = 3;
 	input [WIDTH-1:0]a;
 	input [WIDTH-1:0]b;
 	input cin;
	input odd_PAR;
 	output [WIDTH-1:0]sum;
 	output cout;
	output error_parity;

 	wire cout0;
 	wire cout1;

	wire even_PAR;
	wire parity_int_carry;
	wire parity_check;
	wire parity_final_sum;

 	fulladder fa0(a[0], b[0], cin, sum[0], cout0);
 	fulladder fa1(a[1], b[1], cout0, sum[1], cout1);
 	fulladder fa2(a[2], b[2], cout1, sum[2], cout);
 
 	//parity of inputs
 	assign even_PAR = ~odd_PAR;

 	//parity of internal carries
 	assign parity_int_carry = cin ^ cout0 ^ cout1;

	//even parity of a, b and internal carry
	assign parity_check = even_PAR ^ parity_int_carry;
	
 	//parity of final sum
	assign parity_final_sum = sum[2] ^ sum[1] ^ sum[0];

	assign error_parity = parity_check ^ parity_final_sum;
endmodule

module rca_tmr(	ain,
		bin,
		cin0,
		sum,
		odd_PAR,
		error_out,
		cout);

parameter WIDTH = 3;
input [2:0] ain;
input [2:0] bin;
input cin0;
input odd_PAR;
output [2:0] sum;
output error_out;
output cout;

wire error_out_temp;
wire [WIDTH-1:0]X_rca0;
wire [WIDTH-1:0]X_rca1;
wire [WIDTH-1:0]X_rca2;
wire XC_rca0;
wire XC_rca1;
wire XC_rca2;

wire neq01;
wire neq12;
wire neq02;

 rca ripple_carry0(.a	(ain),
 		   .b	(bin),
 		   .cin	(cin0),
 		   .sum	(X_rca0),
 		   .cout(XC_rca0),
		   .odd_PAR(odd_PAR),
 		   .error_parity(error_parity0)
 		   );
 
 
 rca ripple_carry1(.a	(ain),
 		   .b	(bin),
 		  .cin	(cin0),
 		  .sum	(X_rca1),
 		  .cout	(XC_rca1),
		   .odd_PAR(odd_PAR),
 		   .error_parity(error_parity1)
 		  );
 
 rca ripple_carry2(.a	(ain),
     		   .b	(bin),
 		   .cin	(cin0),
 		   .sum	(X_rca2),
 		   .cout(XC_rca2),
		   .odd_PAR(odd_PAR),
 		   .error_parity(error_parity2)
 		   );
 
 //assign sum = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1}) ? X_rca0 :
 //					  ({XC_rca1,X_rca1} == {XC_rca2,X_rca2}) ? X_rca1 : X_rca2;
 //assign cout = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1}) ? XC_rca0 :
 //					  ({XC_rca1,X_rca1} == {XC_rca2,X_rca2}) ? XC_rca1 : XC_rca2;


 //assign {error_out_temp,cout,sum} = ((error_parity0|error_parity1) | neq01) ? (((error_parity1|error_parity2) | neq12)? (((error_parity0|error_parity2) | neq02)?{1'b1,XC_rca2,X_rca2}:{1'b0,XC_rca2,X_rca2}):{1'b0,XC_rca1,X_rca1}):{1'b0,XC_rca0,X_rca0};
 
assign {error_out_temp,cout,sum} = ((error_parity0|error_parity1) | neq01) ? (((error_parity1|error_parity2) | neq12)? (((error_parity0|error_parity2) | neq02)?{1'b1,XC_rca2,X_rca2}:{1'b0,XC_rca2,X_rca2}):{1'b0,XC_rca1,X_rca1}):{1'b0,XC_rca0,X_rca0};

 assign error_out=(neq01 & neq12 & neq02)|((error_parity0 & error_parity1)|(error_parity1 & error_parity2)|(error_parity0 & error_parity2));

 assign neq01 = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1})?1'b0 : 1'b1;
 assign neq12 = ({XC_rca1,X_rca1} == {XC_rca2,X_rca2})?1'b0 : 1'b1;
 assign neq02 = ({XC_rca0,X_rca0} == {XC_rca2,X_rca2})?1'b0 : 1'b1;




endmodule


module fulladder(a, b, cin, sum, cout);
input a, b, cin;
output sum, cout;
assign sum = a^b^cin;
assign cout = (a&b) | (b&cin) | (cin&a);
endmodule

//module fulladder(a, b, cin, sum, cout);
//input a, b, cin;
//output sum, cout;
//
//wire sum_w,cout_w;
//wire err_s, err_c;
//assign sum_w = a^b^cin;
//assign cout_w = (a&b) | (b&cin) | (cin&a);
//
//assign err_s = ((a^b) ^ (sum_w^cin));
////assign err_c = ((cout_w ^ cin) ^ ((~a & ~b & cin) | (a & b & ~cin)));  //from paper
//assign err_c = (cout_w ^ ((a&b) | (b&cin) | (cin&a)));
//
//
//assign sum  = err_s ? ~sum_w  : sum_w;
////assign sum  =  sum_w;
//assign cout = err_c ? ~cout_w : cout_w;
////assign cout = cout_w;
//
//endmodule
//
