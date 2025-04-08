module chip(
	    input wire 	clk,
	    input wire 	reset,
	    input wire 	x0,
	    input wire 	x1,
	    input wire 	x2,
	    input wire 	x3,
	    output wire y0,
	    output wire y1,
	    output wire y2,
	    output wire y3);
   
   wire 		die_clk;
   wire 		die_reset;
   wire [3:0]		die_x;
   wire [3:0]		die_y;

   pads thepads(.clk(clk),
		.reset(reset),
		.x0(x0),
		.x1(x1),
		.x2(x2),
		.x3(x3),
		.y0(y0),
		.y1(y1),
		.y2(y2),
		.y3(y3),
		.die_clk(die_clk),
		.die_reset(die_reset),
		.die_x(die_x),
		.die_y(die_y));

   mavg thecore(.x(die_x),
		.y(die_y),
		.reset(die_reset),
		.clk(die_clk));
   
endmodule
   
