/*
SLICEM at the following:
SLICE_XxY*
Where Y any value
x
    Always even (ie 100, 102, 104, etc)
    In our ROI
    x = 6, 8, 10, 12, 14

SRL16E: LOC + BEL
SRLC32E: LOC + BEL
RAM64X1S: LOCs but doesn't BEL
*/

module top(input clk, stb, di, output do);
	localparam integer DIN_N = 256;
	localparam integer DOUT_N = 256;

	reg [DIN_N-1:0] din;
	wire [DOUT_N-1:0] dout;

	reg [DIN_N-1:0] din_shr;
	reg [DOUT_N-1:0] dout_shr;

	always @(posedge clk) begin
		din_shr <= {din_shr, di};
		dout_shr <= {dout_shr, din_shr[DIN_N-1]};
		if (stb) begin
			din <= din_shr;
			dout_shr <= dout;
		end
	end

	assign do = dout_shr[DOUT_N-1];

	roi roi (
		.clk(clk),
		.din(din),
		.dout(dout)
	);
endmodule

module roi(input clk, input [255:0] din, output [255:0] dout);
    //ok
    my_NDI1MUX_NMC31 #(.LOC("SLICE_X6Y100"))
            my_NDI1MUX_NMC31(.clk(clk), .din(din[  0 +: 8]), .dout(dout[  0 +: 8]));
    /*
    //Can't find a valid solution
    my_NDI1MUX_NDI1 #(.LOC("SLICE_X6Y101"))
            my_NDI1MUX_NDI1(.clk(clk), .din(din[  8 +: 32]), .dout(dout[  8 +: 8]));
    */
    my_NDI1MUX_NI #(.LOC("SLICE_X6Y102"))
            my_NDI1MUX_NI(.clk(clk), .din(din[  40 +: 8]), .dout(dout[  40 +: 8]));
    
    

    /*
    //ok
    my_BDI1MUX_AI #(.LOC("SLICE_X8Y100"), .BEL("A6LUT"))
            my_BDI1MUX_AI(.clk(clk), .din(din[  64 +: 8]), .dout(dout[  64 +: 8]));
    */
    /*
    //bad
    my_BDI1MUX_BDI1 #(.LOC("SLICE_X8Y101"), .BELO("C6LUT"), .BELI("A6LUT"))
            my_BDI1MUX_BDI1(.clk(clk), .din(din[  72 +: 8]), .dout(dout[  72 +: 8]));
    */
    /*
    //ok
    my_BDI1MUX_BMC31 #(.LOC("SLICE_X8Y102"), .BELO("B6LUT"), .BELI("A6LUT"))
            my_BDI1MUX_BMC31(.clk(clk), .din(din[  80 +: 8]), .dout(dout[  80 +: 8]));
    */
endmodule

/****************************************************************************
Tries to set all three muxes at once
****************************************************************************/

module my_NDI1MUX_NMC31 (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "SLICE_X6Y100";
    wire [3:0] q31;

    (* LOC=LOC, BEL="D6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutd (
            .Q(dout[0]),
            .Q31(q31[3]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL="C6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutc (
            .Q(dout[1]),
            .Q31(q31[2]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            //.D(din[7]));
            .D(q31[3]));
    (* LOC=LOC, BEL="B6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutb (
            .Q(dout[2]),
            .Q31(q31[1]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            //.D(din[7]));
            .D(q31[2]));
    (* LOC=LOC, BEL="A6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) luta (
            .Q(dout[3]),
            .Q31(q31[0]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            //.D(din[7]));
            .D(q31[1]));
endmodule

/*
//Cannot loc instance 'roi/my_NDI1MUX_NDI1/lutc' at site SLICE_X6Y100,
//Bel does not match with the valid locations at which this inst can be placed

module my_NDI1MUX_NDI1 (input clk, input [31:0] din, output [7:0] dout);
    parameter LOC = "SLICE_X6Y100";
    wire [3:0] q31;

    (* LOC=LOC, BEL="D6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutd (
            .Q(dout[0]),
            .Q31(q31[3]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL="C6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutc (
            .Q(dout[1]),
            .Q31(q31[2]),
            .A(din[12:8]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[15]));
    (* LOC=LOC, BEL="B6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutb (
            .Q(dout[2]),
            .Q31(q31[1]),
            .A(din[20:16]),
            .CE(din[5]),
            .CLK(din[6]),
            //.D(din[23]));
            .D(q31[2]));
    (* LOC=LOC, BEL="A6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) luta (
            .Q(dout[3]),
            .Q31(q31[0]),
            .A(din[28:24]),
            .CE(din[5]),
            .CLK(din[6]),
            //.D(din[31]));
            .D(q31[2]));
endmodule
*/


module my_NDI1MUX_NI (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "SLICE_X6Y100";

    (* LOC=LOC, BEL="D6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutd (
            .Q(dout[0]),
            .Q31(),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL="C6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutc (
            .Q(dout[1]),
            .Q31(),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL="B6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutb (
            .Q(dout[2]),
            .Q31(),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL="A6LUT" *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) luta (
            .Q(dout[3]),
            .Q31(),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
endmodule

/****************************************************************************
Individual mux tests
****************************************************************************/

module my_BDI1MUX_AI (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BEL="A6LUT";

    wire mc31c;

    (* LOC=LOC, BEL=BEL *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lut (
            .Q(dout[0]),
            .Q31(mc31c),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
endmodule

module my_BDI1MUX_BDI1 (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BELO="C6LUT";
    parameter BELI="A6LUT";

    wire mc31c;
    //wire da = din[6];

    (* LOC=LOC, BEL=BELO *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutb (
            .Q(dout[0]),
            .Q31(mc31c),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL=BELI *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) luta (
            .Q(dout[1]),
            .Q31(dout[2]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(mc31c));
endmodule

//ok
module my_BDI1MUX_BMC31 (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BELO="B6LUT";
    parameter BELI="A6LUT";

    wire mc31b;

    (* LOC=LOC, BEL=BELO *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lutb (
            .Q(dout[0]),
            .Q31(mc31b),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
    (* LOC=LOC, BEL=BELI *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) luta (
            .Q(dout[1]),
            .Q31(dout[2]),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(mc31b));

endmodule









/*
Old stuff
This is original file, move mux test out and restore this
*/










    /*
    //BEL works
    my_SRLC32E #(.LOC("SLICE_X6Y100"), .BEL("A6LUT"))
            c0(.clk(clk), .din(din[  0 +: 8]), .dout(dout[  0 +: 8]));
    my_SRLC32E #(.LOC("SLICE_X6Y101"), .BEL("B6LUT"))
            c1(.clk(clk), .din(din[  8 +: 8]), .dout(dout[  8 +: 8]));
    my_SRLC32E #(.LOC("SLICE_X6Y102"), .BEL("C6LUT"))
            c2(.clk(clk), .din(din[  16 +: 8]), .dout(dout[  16 +: 8]));
    my_SRLC32E #(.LOC("SLICE_X6Y103"), .BEL("D6LUT"))
            c3(.clk(clk), .din(din[  24 +: 8]), .dout(dout[  24 +: 8]));
    */

module my_SRLC32E (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BEL="A6LUT";

    wire mc31c;

    (* LOC=LOC, BEL=BEL *)
    SRLC32E #(
            .INIT(32'h00000000),
            .IS_CLK_INVERTED(1'b0)
        ) lut (
            .Q(dout[0]),
            .Q31(mc31c),
            .A(din[4:0]),
            .CE(din[5]),
            .CLK(din[6]),
            .D(din[7]));
endmodule

    /*
    //BEL works
    //No unknown bits
    my_SRL16E #(.LOC("SLICE_X6Y100"), .BEL("A6LUT"))
            c0(.clk(clk), .din(din[  0 +: 8]), .dout(dout[  0 +: 8]));
    my_SRL16E #(.LOC("SLICE_X6Y101"), .BEL("B6LUT"))
            c1(.clk(clk), .din(din[  8 +: 8]), .dout(dout[  8 +: 8]));
    my_SRL16E #(.LOC("SLICE_X6Y102"), .BEL("C6LUT"))
            c2(.clk(clk), .din(din[  16 +: 8]), .dout(dout[  16 +: 8]));
    my_SRL16E #(.LOC("SLICE_X6Y103"), .BEL("D6LUT"))
            c3(.clk(clk), .din(din[  24 +: 8]), .dout(dout[  24 +: 8]));
    */

module my_SRL16E (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BEL="A6LUT";

    (* LOC=LOC, BEL=BEL *)
    SRL16E #(
        ) SRL16E (
            .Q(dout[0]),
            .A0(din[0]),
            .A1(din[1]),
            .A2(din[2]),
            .A3(din[3]),
            .CE(din[4]),
            .CLK(din[5]),
            .D(din[6]));
endmodule

module my_RAM64M (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BEL="A6LUT";

    (* LOC=LOC, BEL=BEL *)
    RAM64M #(
        ) RAM64M (
            .DOA(dout[0]),
            .DOB(dout[1]),
            .DOC(dout[2]),
            .DOD(dout[3]),
            .ADDRA(din[0]),
            .ADDRB(din[1]),
            .ADDRC(din[2]),
            .ADDRD(din[3]),
            .DIA(din[4]),
            .DIB(din[5]),
            .DIC(din[6]),
            .DID(din[7]),
            .WCLK(clk),
            .WE(din[1]));
endmodule


/*
RAM64M 64-Deep by 4-bit Wide Multi Port Random Access Memory (Select RAM)
RAM64X1D 64-Deep by 1-Wide Dual Port Static Synchronous RAM
RAM64X1S 64-Deep by 1-Wide Static Synchronous RAM
RAM64X1S_1 64-Deep by 1-Wide Static Synchronous RAM with Negative-Edge Clock
*/

    /*
    my_RAM64M #(.LOC("SLICE_X6Y100"))
            my_RAM64M(.clk(clk), .din(din[  0 +: 8]), .dout(dout[  0 +: 8]));
    my_RAM64X1S #(.LOC("SLICE_X6Y101"))
            my_RAM64X1S(.clk(clk), .din(din[  8 +: 8]), .dout(dout[  8 +: 8]));
    my_RAM64X1S_1 #(.LOC("SLICE_X6Y102"))
            my_RAM64X1S_1(.clk(clk), .din(din[  16 +: 8]), .dout(dout[  16 +: 8]));
    my_RAM64X2S #(.LOC("SLICE_X6Y103"))
            my_RAM64X2S(.clk(clk), .din(din[  24 +: 8]), .dout(dout[  24 +: 8]));
    my_RAM64X1D #(.LOC("SLICE_X6Y104"))
            my_RAM64X1D(.clk(clk), .din(din[  32 +: 8]), .dout(dout[  32 +: 8]));
    my_RAM128X1D #(.LOC("SLICE_X6Y105"))
            my_RAM128X1D(.clk(clk), .din(din[  40 +: 8]), .dout(dout[  40 +: 8]));
    */

module my_RAM64X1S (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";
    parameter BEL="A6LUT";

    (* LOC=LOC, BEL=BEL *)
    RAM64X1S #(
        ) RAM64X1S (
            .O(dout[0]),
            .A0(din[0]),
            .A1(din[1]),
            .A2(din[2]),
            .A3(din[3]),
            .A4(din[4]),
            .A5(din[5]),
            .D(din[6]),
            .WCLK(clk),
            .WE(din[0]));
endmodule



module my_RAM64X1S_1 (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";

    (* LOC=LOC *)
    RAM64X1S_1 #(
        ) RAM64X1S_1 (
            .O(dout[0]),
            .A0(din[0]),
            .A1(din[1]),
            .A2(din[2]),
            .A3(din[3]),
            .A4(din[4]),
            .A5(din[5]),
            .D(din[6]),
            .WCLK(clk),
            .WE(din[0]));
endmodule

module my_RAM64X2S (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";

    (* LOC=LOC *)
    RAM64X2S #(
        ) RAM64X2S (
            .O0(dout[0]),
            .O1(dout[1]),
            .A0(din[0]),
            .A1(din[1]),
            .A2(din[2]),
            .A3(din[3]),
            .A4(din[4]),
            .A5(din[5]),
            .D0(din[6]),
            .D1(din[7]),
            .WCLK(clk),
            .WE(din[1]));
endmodule

module my_RAM64X1D (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";

    (* LOC=LOC *)
    RAM64X1D #(
            .INIT(64'h0),
            .IS_WCLK_INVERTED(1'b0)
        ) RAM64X1D (
            .DPO(dout[0]),
            .D(din[0]),
            .WCLK(clk),
            .WE(din[2]),
            .A0(din[3]),
            .A1(din[4]),
            .A2(din[5]),
            .A3(din[6]),
            .A4(din[7]),
            .A5(din[0]),
            .DPRA0(din[1]),
            .DPRA1(din[2]),
            .DPRA2(din[3]),
            .DPRA3(din[4]),
            .DPRA4(din[5]),
            .DPRA5(din[6]));
endmodule

module my_RAM128X1D (input clk, input [7:0] din, output [7:0] dout);
    parameter LOC = "";

    (* LOC=LOC *)
    RAM128X1D #(
            .INIT(128'h0),
            .IS_WCLK_INVERTED(1'b0)
        ) RAM128X1D (
            .DPO(dout[0]),
            .SPO(dout[1]),
            .D(din[0]),
            .WCLK(clk),
            .WE(din[2]));
endmodule

