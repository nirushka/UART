module delay_control(
	input 				clk,
	input 				rst,
	input [16:0]		value,
	input 				set,
	
	output				done
);

reg  [16:0]	cntr;


always @(posedge clk) 
	if (rst) begin
		cntr <= 17'b1;
	end
	else begin
		if (set)
			cntr <= 'b1;
		else if (cntr == value) 
			cntr <= 'b0;
		else if (|cntr)				// keep counting if we already counted
			cntr <= cntr + 'b1;		
	end	
	
assign done = (cntr == value);      // pulse - stop counting when reaching the value

endmodule