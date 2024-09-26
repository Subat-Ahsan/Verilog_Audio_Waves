
module Hexadecimal_To_Seven_Segment (
	// Inputs
	number,
	// Outputs
	seven
);

// Inputs
input		[3:0]	number;

// Outputs
output reg		[6:0]	seven;


always @(*) begin
	case(number)
		4'h0 : begin
			seven = 7'b1000000;
		end
		4'h1 : begin
			seven = 7'b1111001;
		end
		4'h2 : begin
			seven = 7'b0100100;
		end
		4'h3 : begin
			seven = 7'b0110000;
		end
		4'h4 : begin
			seven= 7'b0011001;
		end
		4'h5 : begin
			seven = 7'b0010010;
		end
		4'h6 : begin
			seven = 7'b0000010;
		end
		4'h7 : begin
			seven = 7'b1111000;
		end
		4'h8 : begin
			seven = 7'b0000000;
		end
		4'h9 : begin
			seven = 7'b0010000;
		end
		4'hA : begin
			seven = 7'b0001000;
		end
		4'hB : begin
			seven = 7'b0000011;
		end
		4'hC : begin
			seven = 7'b1000110;
		end
		4'hD : begin
			seven = 7'b0100001;
		end
		4'hE : begin
			seven = 7'b0000110;
		end
		4'hF : begin
			seven = 7'b0001110;
		end

	endcase
end

endmodule

