module mem(
	input 				clk,
	input 				rst,
	input 				set,		// delay_done
	input [7:0]			dataIn,
	input				rx_valid,
	
	output [9:0]		data_out,
	output				init_done,
	output	[16:0]		value,
	output				start_delay
);

reg				hold;
reg				flag_delay;
reg				start_del;
reg	 [3:0]		state;
reg  [4:0]		counter;
wire [9:0]		instruction [8:0];
wire [4:0]		next_counter;


assign	instruction[0] = 10'h30;			// set the initial LCD instructions reset
assign	instruction[1] = 10'h30;			// set the initial LCD instructions reset
assign	instruction[2] = 10'h30;
assign	instruction[3] = 10'hd;
assign	instruction[4] = 10'h1;
assign	instruction[5] = 10'h6;

assign  instruction[6] = 10'b1000000000 + dataIn;	// data
assign	instruction[7] = 10'h18;					// move the cursor to the left		
assign	instruction[8] = 10'h1;						// clear		


always @(posedge clk) begin
	state <= (dataIn == 'd13) ? 8 : state;		// if ENTER was detected -> switch to state=8 to clear screen
	counter <= (state == 8) ? 0 : counter;		// if we cleared the screen --> start counting from 0
	
	if (rst) begin
		state <= 3'd0;
		hold <= 0;			// mark if we're on more than 15 chars, so we're looping through the last 2 chars, while moving left the chars and adding a new one each time
		start_del <= 0;
		counter <= 0;		// amount of chars on screen
		flag_delay <= 1;	// mark that we're waiting for the DELAY to finish
	end
	else if (set) begin 
		flag_delay <= 0;
		state <= (state < 6) ? state+1 : (state == 8 ? 6 : state);
		if (hold) begin		// looping through the 15-16 chars
			state <= 6;
			hold <= 0;
			counter <= counter+1;
			start_del <= 1;			// give set to delay and enable
			flag_delay <= 1;		// mark that we're waiting for the DELAY to finish
		end
		else if (state == 6) begin
			if (rx_valid) begin
				if (counter != 16)
					counter <= next_counter;
				else if (counter == 16) begin	// we've reached the end of screen. move cursor 1 char back, and mark that we're looping
					state <= 7;
					counter <= 15;
					hold <= 1;
				end
				
				start_del <= 1;				// give set to delay and enable
				flag_delay <= 1;			// mark that we're waiting for the DELAY to finish
			end
			else if (!rx_valid) begin		// if the data isn't valid, don't print it to the screen
				start_del <= 0;
			end
		end
	end	
	else if (!set && (state == 6 || state == 8) && !flag_delay) begin
		state <= (state == 8) ? 6 : state;
		
		if(rx_valid) begin
			if (counter != 16)
				counter <= next_counter;
			else if (counter == 16) begin	// we've reached the end of screen. move cursor 1 char back, and mark that we're looping
				state <= 7;
				counter <= 15;
				hold <= 1;
			end
			
			start_del <= 1;				// give set to delay and enable
			flag_delay <= 1;			// mark that we're waiting for the DELAY to finish
		end	
		else if(!rx_valid) begin		// if the data isn't valid, don't print it to the screen
			start_del <= 0;
		end
	end
	else if(!rx_valid) begin			// if the data isn't valid, don't print it to the screen
		start_del <= 0;
	end
end	


assign init_done = (state >= 6);		
assign next_counter = counter + 'b1;	
assign data_out = instruction[state];
assign value = (state == 3 || state == 8) ? 76000 : 2000;
assign start_delay = (state < 6) ? set : start_del;
	
endmodule