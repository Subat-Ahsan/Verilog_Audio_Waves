module VGA(iResetn,iClock, switches, key, plot_in,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

	
   input wire iResetn;
   input wire [2:0] key;  //new
   input wire iClock;
   input wire plot_in;
   input wire  [2:0] switches;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;

   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   output reg 	     oPlot;       // Pixel draw enable
   output reg        oDone;       // goes high when finished drawing frame


   //
   	integer i;
   //
   reg [1 : 0] current_state;
   reg [1 : 0] next_state;
   localparam   STRT = 2'b00,
				PLOT = 2'b01,
                IDLE = 2'b11;
				
	 
	reg plot, loadX, loadY, loadC, count, resetcount;

	// local variables
	wire done;
	wire [2:0] GREEN;

	// Counter Parameters
	localparam CNT_MAX = 12'b110_111111_111;

	// Key Colors
	localparam WHITE = 3'b111; 

	// Keyboard Offset
	parameter keyboard_x_offset = 8'd40;
	parameter keyboard_y_offset = 7'd30;

	// Key X Offsets
	wire [7 : 0] key_x_offset[0 : 6];
	wire [6 : 0] key_y_offset[0 : 6];
	assign key_x_offset[0] = 8'd0;
	assign key_x_offset[1] = 8'd10;
	assign key_x_offset[2] = 8'd20;
	assign key_x_offset[3] = 8'd30;
	assign key_x_offset[4] = 8'd40;
	assign key_x_offset[5] = 8'd50;
	assign key_x_offset[6] = 8'd60;
	//
	assign key_y_offset[0] = 7'd0;
	assign key_y_offset[1] = 7'd0;
	assign key_y_offset[2] = 7'd0;
	assign key_y_offset[3] = 7'd0;
	assign key_y_offset[4] = 7'd0;
	assign key_y_offset[5] = 7'd0;
	assign key_y_offset[6] = 7'd0;
	assign GREEN = switches;
	//
	wire [11:0] counter_value;
	wire [2 : 0] x_coordinate;
	wire [5 : 0] y_coordinate;
	wire [2 : 0] key_addr;
	reg [2 : 0] key_color[0 : 6];
	reg [2 : 0] key_color_saved[0 : 6];
	counter_12 counter(resetcount, iClock, count, counter_value);
	assign key_addr = counter_value[11 : 9];
	assign y_coordinate = counter_value[8 : 3];
	assign x_coordinate = counter_value[2 : 0];

	
	reg [6:0] x_value;
	reg [6:0] y_value;
	reg [2:0] c_value;
	
	// state_table

	always@(*)
	begin: state_table
		case(current_state)
			STRT:begin
				next_state = PLOT;
			end
			PLOT:begin
				if(done == 1'b1)
					next_state = IDLE;
				if(done == 1'b0)
					next_state = PLOT;
			end

			IDLE:begin
				if(plot_in == 1'b1)
					next_state = PLOT;
				if(plot_in == 1'b0)
					next_state = IDLE;
			end
			default: next_state = PLOT;
		endcase
	end
	//
	always @(*)
	begin		
		case (current_state)
			STRT:begin
				count = 1'b0;
				oPlot = 1'b0;
				oDone = 1'b0;
				resetcount = 1'b1;
			end
			PLOT: begin
				count = 1'b1;
				oPlot = 1'b1;
				oDone = 1'b0;
				resetcount = 1'b0;
			end
			
			IDLE: begin
				count = 1'b0;
				oPlot = 1'b0;
				oDone = 1'b1;
				resetcount = 1'b1;
			end	
		endcase
	end

	// Color Assignment

	always @(*) 
	begin
		for (i = 0; i < 7; i = i + 1) 
		begin
			key_color[i] = WHITE;
		end
		if (key != 3'd0) 
		begin
			key_color[key - 1] = GREEN;
		end
	end


	//State swap
	always@(posedge iClock) begin
        if(!iResetn) 
            current_state <= STRT; //new
        else
			current_state <= next_state;    
    end
	
	always @ (posedge iClock) begin
		if (!iResetn) begin
			for (i = 0; i < 7; i = i + 1) 
			begin
				key_color_saved[i] <= WHITE;
			end
		end
		if (current_state == IDLE)
		begin
			for (i = 0; i < 7; i = i + 1) 
			begin
				key_color_saved[i] <= key_color[i];
			end
		end
	end


	assign oX = x_coordinate + key_x_offset[key_addr] + keyboard_x_offset;
	assign oY = y_coordinate + key_y_offset[key_addr] + keyboard_y_offset;
	assign oColour = key_color_saved[key_addr];
	assign done = (counter_value == CNT_MAX);

endmodule

module counter_12(input reset, input clock, input enable, output reg [11:0] q);

	always@(posedge clock) begin
        if (reset) 
            q <= 12'b0;
        else if (enable)
			q <= q + 1'b1;		         
    end
endmodule


