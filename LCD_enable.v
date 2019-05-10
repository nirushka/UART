module LCD_enable(
	input 			clk,
	input 			rst,
	input 			start,
	
	output			enable
);

reg  [7:0]		cntr = 'd0;
wire [7:0]		cntr_ns;
wire			done;

assign cntr_ns = cntr + 'd1;
assign enable  = (cntr >= 'd2 && cntr <= 'd14);	// enables time slot
assign done    = (cntr == 'd15);				// stop the procedure after 14 clocks


always @(posedge clk)
		if (rst)
			cntr <= 7'd0;
		else if (start)
			cntr <= 7'd1;
		else if (|cntr) begin
			cntr <= cntr_ns;
			
			if(done) begin				// go back to the start when done
				cntr <= 7'd0;
			end
		end

endmodule
