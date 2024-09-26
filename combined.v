module combined (
	// Inputs
	CLOCK_50,
	KEY,
	PS2_CLK,PS2_DAT,LEDR, HEX0, HEX1, HEX2,
	
	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW,
	
	VGA_CLK,   						//	VGA Clock
	VGA_HS,							//	VGA H_SYNC
	VGA_VS,							//	VGA V_SYNC
	VGA_BLANK_N,						//	VGA BLANK
	VGA_SYNC_N,						//	VGA SYNC
	VGA_R,   						//	VGA Red[9:0]
	VGA_G,	 						//	VGA Green[9:0]
	VGA_B
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
parameter clockSpeed = 50000000;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[3:0]	KEY;
input		[9:0]	SW;

input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

inout				PS2_CLK;
inout				PS2_DAT;
// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;
output		[6:0]	HEX0;
output		[6:0]	HEX1;
output 		[6:0]   HEX2;
output      [9:0]   LEDR;

output			VGA_CLK;   				//	VGA Clock
output			VGA_HS;					//	VGA H_SYNC
output			VGA_VS;					//	VGA V_SYNC
output			VGA_BLANK_N;				//	VGA BLANK
output			VGA_SYNC_N;				//	VGA SYNC
output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
output	[7:0]	VGA_B; 
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

wire [6:0] keyEnable;

wire [25:0] delay1;
wire [25:0] delay2;
wire [25:0] delay3;
wire [25:0] delay4;
wire [25:0] delay5;
wire [25:0] delay6;
wire [25:0] delay7;

wire [31:0] outs1;
wire [31:0] outs2;
wire [31:0] outs3;
wire [31:0] outs4;
wire [31:0] outs5;
wire [31:0] outs6;
wire [31:0] outs7;
wire [31:0] outs;

wire [31:0] outq1;
wire [31:0] outq2;
wire [31:0] outq3;
wire [31:0] outq4;
wire [31:0] outq5;
wire [31:0] outq6;
wire [31:0] outq7;
wire [31:0] outq;

wire [31:0] outr;
wire [31:0] outl;

wire reset;
wire [2:0] vol;

wire [2:0]key;
wire chng;
wire writeEn;
wire [2:0] colour;
wire [7:0] x;
wire [6:0] y;
reg  [7:0]q;

// Internal Registers

//Assignmets
assign reset = ~KEY[0];

assign  delay1 = clockSpeed/261;
assign  delay2 = clockSpeed/293;
assign  delay3 = clockSpeed/329;
assign  delay4 = clockSpeed/349;
assign  delay5 = clockSpeed/392;
assign  delay6 = clockSpeed/440;
assign  delay7 = clockSpeed/493;

assign outs = outs1 + outs2 + outs3 + outs4 + outs5 + outs6 + outs7;
assign outq = outq1 + outq2 + outq3 + outq4 + outq5 + outq6 + outq7;

assign LEDR[9] = SW[9];
assign LEDR[8] = SW[8];

assign outr = SW[8] ? outq : SW[9] ? outq : outs;
assign outl = SW[8] ? outs : SW[9] ? outq : outs;
//Modules
key_decoder(
	// Inputs
	.clock (CLOCK_50),
	.resetn (KEY[0]),

	// Bidirectionals
	.ps2_clk (PS2_CLK),
 	.ps2_dat (PS2_DAT),

	// Outputs
	.key	(key),
	.change	(chng),
);

Key_Output ko (key, keyEnable);
assign LEDR[6:0] = keyEnable; 

volumeControl volControl(reset, CLOCK_50, ~KEY[1], ~KEY[2], vol);
Hexadecimal_To_Seven_Segment hx (vol, HEX2);
//assign vol = 2'b01;
square_generator sq1 (reset, keyEnable[0], CLOCK_50, vol, delay1, outq1);
square_generator sq2 (reset, keyEnable[1], CLOCK_50, vol, delay2, outq2);
square_generator sq3 (reset, keyEnable[2], CLOCK_50, vol, delay3, outq3);
square_generator sq4 (reset, keyEnable[3], CLOCK_50, vol, delay4, outq4);
square_generator sq5 (reset, keyEnable[4], CLOCK_50, vol, delay5, outq5);
square_generator sq6 (reset, keyEnable[5], CLOCK_50, vol, delay6, outq6);
square_generator sq7 (reset, keyEnable[6], CLOCK_50, vol, delay7, outq7);

sin_generator sn1 (reset, keyEnable[0], CLOCK_50, vol, delay1, outs1);
sin_generator sn2 (reset, keyEnable[1], CLOCK_50, vol, delay2, outs2);
sin_generator sn3 (reset, keyEnable[2], CLOCK_50, vol, delay3, outs3);
sin_generator sn4 (reset, keyEnable[3], CLOCK_50, vol, delay4, outs4);
sin_generator sn5 (reset, keyEnable[4], CLOCK_50, vol, delay5, outs5);
sin_generator sn6 (reset, keyEnable[5], CLOCK_50, vol, delay6, outs6);
sin_generator sn7 (reset, keyEnable[6], CLOCK_50, vol, delay7, outs7);

assign read_audio_in			= audio_in_available & audio_out_allowed;
assign left_channel_audio_out	= left_channel_audio_in +   outl;
assign right_channel_audio_out	= right_channel_audio_in +  outr;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0]),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),

	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

VGA vga_instance(
			.iResetn(KEY[0]),
			.iClock(CLOCK_50),
			.switches(SW[2:0]),
			.key(key),
			.plot_in(chng),
			.oX(x),
			.oY(y),
			.oColour(colour),
			.oPlot(writeEn),
			.oDone(LEDR[7]),
	);
	
vga_adapter adapter(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam adapter.RESOLUTION = "160x120";
		defparam adapter.MONOCHROME = "FALSE";
		defparam adapter.BITS_PER_COLOUR_CHANNEL = 1;
		defparam adapter.BACKGROUND_IMAGE = "black.mif";
		
always@(posedge CLOCK_50) begin
	if (~KEY[0]) 
		q <= 8'b00000000;
	else if (chng)
		q <= q + 1'b1;
end

Hexadecimal_To_Seven_Segment Segment1(
	// Inputs
	.number			(q[3:0]),
	.seven	(HEX0)
);

Hexadecimal_To_Seven_Segment Segment(
	// Inputs
	.number			(q[7:4]),
	.seven	(HEX1)
);
endmodule






