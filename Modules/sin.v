module sin_generator
(input reset, input enable, input clock, 
input [2:0] vol, input [25:0] delay, output signed [31:0] val);
	reg [25:0] delay_cnt;
	wire [21:0] div;
	
	reg [3:0] count;
	
	wire signed [31:0] val_before_w;
	reg signed [9:0] val_before;
	
	assign val_before_w = val_before;
	assign div = delay / 16;
	
	always @(posedge clock)
	begin 
		if (reset) begin
			delay_cnt <= 26'b0;
			count <= 4'b0;
		end
	
		else begin
			if(delay_cnt == delay) begin
				delay_cnt <= 26'b0;
				count <= 4'b0;
			end 
			else begin
				delay_cnt <= delay_cnt + 1;
				if (delay_cnt % div == 0)
					count <= count + 1;
			end
		end
	end
	
	always@ (*)
	begin
		case (count)
			4'd0: val_before = 0;
			4'd1: val_before = 50;
			4'd2: val_before = 71;
			4'd3: val_before = 87;
			4'd4: val_before = 100;
			4'd5: val_before = 87;
			4'd6: val_before = 71;	
			4'd7: val_before = 50;
			4'd8: val_before = 0;
			4'd9: val_before = -50;
			4'd10: val_before = -71;
			4'd11: val_before = -87;
			4'd12: val_before = -100;
			4'd13: val_before = -87;
			4'd14: val_before = -71;
			4'd15: val_before = -50;
		endcase
	end
	
	assign val = (enable) ? val_before_w * vol * 1000000 : 0;
	
endmodule