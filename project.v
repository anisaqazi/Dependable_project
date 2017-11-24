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
wire [WIDTH-1:0]X_rca0;
wire [WIDTH-1:0]X_rca1;
wire [WIDTH-1:0]X_rca2;
wire XC_rca0;
wire XC_rca1;
wire XC_rca2;
/* add your design here */
wire cin0;
wire [WIDTH-1:0]ain;
wire [WIDTH-1:0]bin;
assign cin0 = C0 ? 1'b0 : 1'b1;
assign ain = {(C2^A2), (C2^A1), (C2^A0)};  
assign bin = {(C1^B2), (C1^B1), (C1^B0)};  

rca ripple_carry0(.a	(ain),
			      .b	(bin),
				  .cin	(cin0),
				  .sum	(X_rca0),
				  .cout	(XC_rca0)
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
				  .cout	(XC_rca2)
				  );

assign {X2, X1, X0} = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1}) ? X_rca0 :
					  ({XC_rca1,X_rca1} == {XC_rca2,X_rca2}) ? X_rca1 : X_rca2;
assign XC = ({XC_rca0,X_rca0} == {XC_rca1,X_rca1}) ? XC_rca0 :
					  ({XC_rca1,X_rca1} == {XC_rca2,X_rca2}) ? XC_rca1 : XC_rca2;

assign XE0 = 1'b0;
assign XE1 = ~(A0^A1^A2^B0^B1^B2^PAR) ? XE0 :              // Not odd parity
			 (~( ~(C0&C1&C2) & (C0^C1^C2))) ? XE0  :       // Not one hot
			 ~XE0 ;
					
assign Y0 = 0;
assign Y1 = 0;
assign Y2 = 0;
assign YE0 = 0;
assign YE1 = 0;
assign YC = 0;
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

module fulladder(a, b, cin, sum, cout);
input a, b, cin;
output sum, cout;
assign sum = a^b^cin;
assign cout = (a&b) | (b&cin) | (cin&a);
endmodule

