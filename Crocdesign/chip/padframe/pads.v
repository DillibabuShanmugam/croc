/*
 * Initial design by: Prof. Patrick Schaumont
 * Adopted for TSMC180nm by: Vladimir Vakhter
 * Date: 03/06/2025
 * Info:
 
 * - This file works for any tpz018nv or tpz973gv I/O cell libraries
 * - The cells used: 
 * 	- PDIDGZ	: Input Pad, High-Volt Tolerant
 * 	- PDO04CDG	: Output Pad									# FIXME: maybe, use PDT02DGZ : Tri-State Output Pad, High-Volt Tolerant
 * 	- PVDD1DGZ	: Vdd Pad for Core Power Supply
 * 	- PVDD2DGZ	: Power Pad for I/O Power Supply
 * 	- PVDD2POC	: Power-on Control Power Pad for I/O Power Supply
 * 	- PVSS1DGZ	: Vss Pad for Core Ground Supply
 * 	- PVSS2DGZ	: Ground Pad for I/O Ground Supply
 * 	- PCORNER	: Corner cell
 *  
 * - The above MACRO-s are defined in the corresponding LEF (.lef) library file.
 * - See the accompanying Makefile in the ../layout directory for the path to the LEF.
 * - Read the "TSMC Universal Standard I/O Library General Application Note" (further - Gen.AN) on how to use the cells.
 * - Read TSMC Standard I/O <io_cel_lib_name> Databook for more information on the IO cells.
 *   It is usually contained in one of the IO lib subdirectories
*/

module pads(
		input wire 	      clk,
		input wire 	      reset,
		input wire 	      x0,
		input wire 	      x1,
		input wire 	      x2,
		input wire 	      x3,
		output wire       y0,
		output wire       y1,
		output wire       y2,
		output wire       y3,

		output wire       die_clk,
		output wire       die_reset,
		output wire [3:0] die_x,
		input wire [3:0]  die_y);
	
	// ################################################################################################################
	// # Input/output signals
	// ################################################################################################################
	
	/* ----------- Control inputs ----------- */
	PDIDGZ clkpad(.PAD(clk), .C(die_clk));
	PDIDGZ resetpad(.PAD(reset), .C(die_reset));

	/* ----------- Signal inputs ----------- */
	PDIDGZ x0pad(.PAD(x0), .C(die_x[0]));
	PDIDGZ x1pad(.PAD(x1), .C(die_x[1]));
	PDIDGZ x2pad(.PAD(x2), .C(die_x[2]));
	PDIDGZ x3pad(.PAD(x3), .C(die_x[3]));

	/* ----------- Signal outputs ----------- */
	PDO04CDG y0pad(.I(die_y[0]), .PAD(y0));
	PDO04CDG y1pad(.I(die_y[1]), .PAD(y1));
	PDO04CDG y2pad(.I(die_y[2]), .PAD(y2));
	PDO04CDG y3pad(.I(die_y[3]), .PAD(y3));

	// ################################################################################################################
	// # Power domain
	// ################################################################################################################

	/* 	Gen.AN: To supply enough current, it is suggested that you duplicate the power and ground
		cells on the pad ring and apply double or even triple bonding to the same power or ground
		pins of the package for both core and IO.
		
		Gen.AN: to make the high-volt-tolerant I/O cell correctly function as expected, it is required
		to tie the programmable pins to low level (VSS) or high level (VDD) through a tie-high/tie-low cell
		available from the standard cell library. For ESD robustness, do not directly tie the programmable
		pins (e.g. OEN) to power (VDD) / ground (VSS). Instead, connect a tie-high or tie-low cell between
		the programmable pins and power / ground
		
		MIT suggested: for each 1mm, have at least one set of {VDD_CORE, VSS_CORE, VDD_IO, and VSS_IO}
	 */
	 
	/* ----------- Core power cells ----------- */
	// Gen.AN suggests having at least two PVDD1DGZ/CDG for the I/O domain
	// For small I/O domain, Gen.AN suggests placing two PVDD1DGZ cells together and double bond them.
	PVDD1DGZ vdd1();	// Core VDD
	PVDD1DGZ vdd2();	// Core VDD
	
	/* ----------- Core ground cells ----------- */
	// Gen.AN suggests having at least two PVSS1DGZ/CDG for the I/O domain
	// or two PVSS3DGZ/CDG digital common ground cells in each domain
	// (for pad-limited designs and when ground noise is not critical)
	PVSS1DGZ vss1();    // Core VSS
	PVSS1DGZ vss2();    // Core VSS

	/* ----------- IO power cells ----------- */
	// Gen.AN suggests having at least two PVDD2DGZ/CDG digital
	PVDD2DGZ vdd3();	// IO VDD
	PVDD2POC vdd4();	// IO VDD		// NOTE: Gen.AN says it is mandatory to use ONE and Only One PVDD2POC
										// in each digital domain. Replace one PVDD2DGZ with PVDD2POC.

	/* ----------- IO ground cells ----------- */
	// Gen.AN suggests having at least two PVSS2DGZ/CDG for the I/O domain
	// or two PVSS3DGZ/CDG digital common ground cells in each domain
	// (for pad-limited designs and when ground noise is not critical)
	PVSS2DGZ vss3();	// IO VSS
	PVSS2DGZ vss4();	// IO VSS
   
   	// ################################################################################################################
	// # Physical only (special function) cells
	// ################################################################################################################
	
	/* ----------- Corner cells ----------- */
	
	// FIXME: Innovus has the "add_power_switches" command, the "-corner_cell_list" flag
		
	// Gen.AN says NOT to include  PFILLERx, PRCUT, PCORNERx cells in your netlist for simulation,
	// but instantiate them when doing the physical layout
	
	PCORNER ul();
	PCORNER ur();
	PCORNER ll();
	PCORNER lr();
   
endmodule

/* Input and output names MUST match those defined in the .lef file and
 * the corresponding IO cell library databook (see the schematics there).
 */
module PDIDGZ(input wire PAD, output wire C);
	assign C = PAD;
endmodule 

module PDO04CDG(input wire I, output wire PAD);
	assign PAD = I;
endmodule 

module PVSS1DGZ();
endmodule

module PVSS2DGZ();
endmodule 

module PVDD1DGZ();
endmodule

module PVDD2DGZ();
endmodule 

module PVDD2POC();
endmodule 

module PCORNER();
endmodule
