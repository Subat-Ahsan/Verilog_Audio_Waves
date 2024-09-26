module square_generator
(input reset, input enable, input clock, 
input [2:0] vol, input [25:0] delay, output signed [31:0] val);
	reg snd;
	reg [25:0] delay_cnt;
	wire signed [31:0] val_before;
	
	always @(posedge clock)
	begin 
	if (reset) begin
		snd <= 1'b0;
		delay_cnt <= 26'b0;
	end
	
	else begin
		if(delay_cnt == delay) begin
			delay_cnt <= 26'b0;
			snd <= !snd;
		end else 
			delay_cnt <= delay_cnt + 1;
	end
	end
	
	assign val_before = (enable) ? snd ? 32'd10000000 : -32'd100000000 : 0;
	assign val = val_before * vol;
	
endmodule