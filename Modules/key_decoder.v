
module key_decoder (
	// Inputs
	clock,
	resetn,

	// Bidirectionals
	ps2_clk,
	ps2_dat,
	
	// Outputs
	key,
	change,
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
// Key presses
	localparam KEYA = 8'b00011100; 
	localparam KEYS = 8'b00011011; 
	localparam KEYD = 8'b00100011; 
	localparam KEYF = 8'b00101011; 
	localparam KEYG = 8'b00110100; 
	localparam KEYH = 8'b00110011; 
	localparam KEYJ = 8'b00111011; 

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				clock;
input 	resetn;

// Bidirectionals
inout				ps2_clk;
inout				ps2_dat;

// Outputs
output wire [2:0] key;
output reg change;
/*output		[6:0]	HEX0;
output		[6:0]	HEX1;
output		[6:0]	HEX2;
output		[6:0]	HEX3;
output		[6:0]	HEX4;
output		[6:0]	HEX5;
output		[6:0]	HEX6;
output		[6:0]	HEX7;*/

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/


// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;
wire 				store_data;			

// Internal Registers
reg			[7:0]	last_data_received;
reg  		[2:0] 	key_prev;
reg         [2:0] 	key_curr;


reg current_state;
reg next_state;
localparam   NRML = 1'b0,
			 RLES = 1'b1;

assign key = key_curr;
assign store_data = (current_state == NRML) & ps2_key_pressed;

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge clock)
begin
	if (~resetn)
		last_data_received <= 8'h00;
	else if(store_data)
		last_data_received <= ps2_key_data;
end

always @(*) 
begin
	case(last_data_received)
		KEYA:begin
			key_curr = 3'b001;		
		end
		KEYS:begin
			key_curr = 3'b010;		
		end
		KEYD:begin
			key_curr = 3'b011;		
		end
		KEYF:begin
			key_curr = 3'b100;		
		end
		KEYG:begin
			key_curr = 3'b101;		
		end
		KEYH:begin
			key_curr = 3'b110;		
		end
		KEYJ:begin
			key_curr = 3'b111;		
		end
		default: begin
			key_curr = 3'b000;
		end
	endcase
end



//FSM
always@(*)
begin: state_table
	case(current_state)
		NRML:begin
			if(ps2_key_pressed == 1'b1 && ps2_key_data == 8'b11110000)
				next_state = RLES;
			else 
				next_state = NRML;
		end
		RLES:begin
			if(ps2_key_pressed == 1'b1)
				next_state = NRML;
			else
				next_state = RLES;
		end
		default: next_state = NRML;
	endcase
end

always @(posedge clock)
begin 
	if(~resetn)
		current_state <= NRML;
	else
	begin
		current_state <= next_state;		
	end
end

always @(posedge clock)
begin 
	if(~resetn)
		begin
			change <= 1'b0;
			key_prev <= 3'b0;
		end
	else
	begin
		key_prev<=key_curr;
		if(key_prev != key_curr)
			change<= 1'b1;
		else
		begin
			change <= 1'b0;
		end		
	end
end


PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(clock),
	.reset					(~resetn),

	// Bidirectionals
	.PS2_CLK			(ps2_clk),
 	.PS2_DAT			(ps2_dat),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);



endmodule
