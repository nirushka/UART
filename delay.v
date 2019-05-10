module delay(
	input 				clk,
	input 				rst,
	input [12:0]		value,
	input 				set,
	
	output				done
);

reg  [12:0]	cntr;


always @(posedge clk) 
	if (rst) begin
		cntr <= 13'b0;
	end
	else begin
		if (set)
			cntr <= 'b1;
		if (cntr == value) 
			cntr <= 13'b0;
		else if (|cntr)				// keep counting if we already counted
			cntr <= cntr + 'b1;		
	end	
	
assign done = (cntr == value);      // pulse - stop counting when reaching the value
	
endmodule