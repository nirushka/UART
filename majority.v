module majority(
	input 				clk,
	input 				rst,
	input 				Rx, 	 	// level		
	input 				set, 	 	// pulse
	input				SW0,		// 0 for no parity, 1 for even parity
	input				SW1,		// 0 for 7 bit length, 1 for 8 bit length
	input				SW2,		// 0 for 9600b/s, 1 for 115200b/s
	
	output				start_delay,
	output	[12:0]		value,
	output	[8:0]		frame_out,
	output				data_valid,
	output				frame_err
);

wire	[3:0]	num_of_bits;		// the total amount of bits to be received with the parity
reg		[1:0]	start_rec; 			// state selector (1 = find start bit /// 2 = find data bits /// 3 = wait for the next frame)
reg		[2:0]	cntr;				// real bits counter
reg		[2:0]	start_cntr;			// counter for the start bit
reg		[2:0]	bit_counter;	
reg		[2:0]	reg_value;			// delay value register
reg 	[3:0]	frame_counter;		// counts the number of bits that were read
reg		[8:0]	data;				// register for the data
reg				stop_bit;			// flag for the stop bit
reg				start_counting; 	// flag to start the delay process


assign num_of_bits = (SW0 && SW1) ? 'd10 : ((SW0 || SW1) ? 'd9 : 'd8);


always @(posedge clk) 	
	if (rst || (data_valid && stop_bit)) begin	// start to recognize the start_bit
		data <= 9'b0;
		frame_counter <= 'd0;
		start_rec <= 'd1;
		cntr <= 'd0;
		bit_counter <= 'd0;
		reg_value <= 'd0;
		start_cntr <= 'd0;
		stop_bit <= 'd1;
		start_counting <= 'd0;
	end
	else if (set && stop_bit) begin				// start the real frame bits recognition process
		start_rec <= 'd2;
		cntr <= 'd0;
		bit_counter <= 'd0;
		reg_value <= 'd0;
		start_cntr <= 'd0;
		start_counting <= 'd0;
	end
	
	else if (start_rec == 'd1) begin	// ----[ look for the start bit ]----
		$display("start_rec == 1");
		if (start_cntr < 'd7) begin		// less than 7 samples
			bit_counter <= bit_counter + Rx;	//count the number of ones
			start_cntr <= start_cntr + 'd1;
		end
		else if (start_cntr == 'd7) begin	// we got 7 samples
			reg_value <= (bit_counter < 'd4) ? (SW2 ? 'd3: 'd4) : reg_value;		// assign the delay value to be 650/7812 clocks
			start_counting <= (bit_counter < 'd4) ? 'd1 : start_counting;
			start_rec <= (bit_counter < 'd4) ? 'd3 : start_rec;					// idle state
			bit_counter <= 'd0; 
			start_cntr <= 'd0;
		end	
	end
	
	else if (start_rec == 'd2) begin	// ----[ look for the real data ]----
		$display("start_rec == 2");
		if (cntr < 'd7) begin			// less than 7 samples
			bit_counter <= bit_counter + Rx;
			cntr <= cntr + 'd1;
		end
		else if (cntr == 'd7) begin		// we got 7 samples
			if (bit_counter >= 'd4) begin
				if ((frame_counter < num_of_bits - 1)) begin
					data[frame_counter] <= 1;
					frame_counter <= frame_counter + 'd1;
					reg_value <= SW2 ? 'd1 : 'd2;		// assign the delay value to be 434/5208 clocks
					start_counting <= 'd1;
					start_rec <= 'd3;
				end			
			end
			else if ( bit_counter < 'd4) begin
				if ((frame_counter < num_of_bits - 1)) begin
					data[frame_counter] <= 0;
					frame_counter <= frame_counter + 'd1;
					reg_value <= SW2 ? 'd1 : 'd2;		// assign the delay value to be 434 clocks
					start_counting <= 'd1;
					start_rec <= 'd3;
				end
			end
			if ((frame_counter == num_of_bits - 1)) begin	// detect the stop bit
				if (Rx == 1) begin
					stop_bit <= 'd1;
					frame_counter <= frame_counter + 'd1;
					start_rec <= 'd1;
				end
				else if (Rx == 0) begin		// stop bit didn't recognized
					stop_bit <= 'd0;
					start_rec <= 'd3;	// switch state - we have an error
					$display("Frame error!!!");
				end
			end
		end
	end
	
	else if (start_rec == 'd3) begin	// ----[ idle state ]----
		start_counting <= 'd0;	// do nothing until set again
	end


assign data_valid = (frame_counter == num_of_bits); //pulse
assign frame_out = data_valid ? data : 'b11111111; // level
assign value = (reg_value == 1) ? 'd434 : (reg_value == 2 ? 'd5208 : (reg_value == 3 ? 'd650 : (reg_value == 4 ? 'd7812 : 'd2))) ; // level
assign frame_err = (stop_bit == 'd0); // level
assign start_delay = (reg_value != 0) ? start_counting : 0;

endmodule