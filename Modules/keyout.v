module Key_Output(input [2:0] key, output reg [6:0] val);
	
	always@ (*) 
	begin
		case (key)
         3'b000: val = 7'b0000000;
         3'b001: val = 7'b0000001;
         3'b010: val = 7'b0000010;
         3'b011: val = 7'b0000100;
         3'b100: val = 7'b0001000;
         3'b101: val = 7'b0010000;
         3'b110: val = 7'b0100000;
         3'b111: val = 7'b1000000;
         default: val = 7'b0000000;
      endcase
	end 
	
endmodule