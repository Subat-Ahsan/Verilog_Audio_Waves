module volumeControl(input reset, input clock, input up, input down, output [2:0] val);
	
	reg [2:0] vol;
	assign val = vol;
	reg [3:0] current_state, next_state;
	
	localparam  Volume1  = 4'd0,
                Volume1Wait = 4'd1,
				Volume2 = 4'd2,
				Volume2Wait = 4'd3,
				Volume3 = 4'd4,
				Volume3Wait = 4'd5,
				Volume0 = 4'd6,
				Volume0Wait = 4'd7,
				Volume4 = 4'd8,
				Volume4Wait = 4'd9,
				Volume5 = 4'd10,
				Volume5Wait = 4'd11;
	
	
	
	always@(*)
    begin: state_table
            case (current_state)
                Volume1: begin
					if (up)
						next_state = Volume2Wait;
					else if (down)
						next_state = Volume0Wait;
					else 
						next_state = Volume1;
				end
			
				Volume1Wait: begin
					if (up || down)
						next_state = Volume1Wait;
					else 
						next_state = Volume1;
				end

				Volume2: begin
					if (up)
						next_state = Volume3Wait;
					else if (down)
						next_state = Volume1Wait;
					else 
						next_state = Volume2;
				end
			
				Volume2Wait: begin
					if (up || down)
						next_state = Volume2Wait;
					else 
						next_state = Volume2;
				end

				Volume3: begin
					if (up) 
						next_state = Volume4Wait;
					else if (down)
						next_state = Volume2Wait;
					else 
						next_state = Volume3;
				end
			
				Volume3Wait: begin
					if (up || down)
						next_state = Volume3Wait;
					else 
						next_state = Volume3;
				end

				Volume4: begin
					if (up) 
						next_state = Volume5Wait;
					else if (down)
						next_state = Volume3Wait;
					else 
						next_state = Volume4;
				end
			
				Volume4Wait: begin
					if (up || down)
						next_state = Volume4Wait;
					else 
						next_state = Volume4;
				end

				Volume5: begin
					if (down)
						next_state = Volume4Wait;
					else 
						next_state = Volume5;
				end
			
				Volume5Wait: begin
					if (up || down)
						next_state = Volume5Wait;
					else 
						next_state = Volume5;
				end

				Volume0: begin
					if (up)
						next_state = Volume1Wait;
					else 
						next_state = Volume0;
				end
			
				Volume0Wait: begin
					if (up || down)
						next_state = Volume0Wait;
					else 
						next_state = Volume0;
				end
				
            default:    next_state = Volume1;
        endcase
    end
	
	
	always @(*)
    begin: enable_signals
		vol = 2'b01;
		case (current_state)
			Volume1:
				vol = 3'd1;
			Volume1Wait:
				vol = 3'd1;
			Volume2:
				vol = 3'd2;
			Volume2Wait:
				vol = 3'd2;
			Volume3:
				vol = 3'd3;
			Volume3Wait:
				vol = 3'd3;

			Volume4:
				vol = 3'd4;
			Volume4Wait:
				vol = 3'd4;
			
			Volume5:
				vol = 3'd5;
			Volume5Wait:
				vol = 3'd5;
			
			Volume0:
				vol = 3'b0;
			Volume0Wait:
				vol = 3'b0;
		endcase
	end
	
	always@ (posedge clock) 
	begin: State_FFS
		begin: state_FFs
			if(reset)
				current_state <= Volume1;
			else
				current_state <= next_state;
		end // state_FFS
	end
	
endmodule