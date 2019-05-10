module Delay_TX(
	input 				clk,
	input 				rst,
	input 				SW2,
	input 				set,
	
	output				done
);

reg	[12:0]	cntr;
reg [3:0]	bit_num;


always @(posedge clk) begin
	if (rst) begin
		cntr <= 13'b0;
	end
	else if (set) begin
		cntr <= 'b1;
		bit_num <= 0;
	end
	else if (cntr == (SW2 ? 434 : 5208) && bit_num != 11) begin
		cntr <= 13'b0;
		bit_num <= bit_num+1;
	end	
	else if (|cntr)					// keep counting if we already counted
		cntr <= cntr + 'b1;
	
	if (bit_num == 11)
		cntr <= 13'b0;
end
	
assign done = (cntr == (SW2 ? 434 : 5208));		// pulse - stop counting when reaching the value
	
endmodule