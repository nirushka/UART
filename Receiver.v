module Receiver(
	input 				clk,
	input 				rst,
	input 				Rx, 			// level		
	input				read_enable,	
	
	input				SW0,		 	// 0 for no parity, 1 for even parity
	input				SW1,		 	// 0 for 7 bit length, 1 for 8 bit length
	input				SW2,		 	// 0 for 9600b/s, 1 for 115200b/s
	
	output	[7:0]		rx_frame_out,
	output				valid,
	
	output				frame_err,
	output				parity_err,
	output 				overrun_err

);

wire			fifo_valid;
wire 			check_frame_err_out;
wire 			fifo_full;
wire 			check_parity_err_out;
wire	[7:0]	fifo_data_out;
wire 			fifo_empty;

wire	[12:0]	value_to_delay;
wire	[8:0]	frame_out;
wire	[7:0]	check_data_out;


assign	frame_err = check_frame_err_out;
assign	overrun_err = fifo_full;
assign	parity_err = check_parity_err_out;

assign	rx_frame_out = fifo_data_out;
assign	valid = (fifo_valid);


majority		majority_mod(
	.clk				(clk),
	.rst				(rst),
	.set				(delay_done),
	.Rx					(Rx),
	.SW0				(SW0),
	.SW1				(SW1),
	.SW2				(SW2),
	
	.start_delay		(start_delay),			// output
	.frame_err			(mj_frame_err),
	.data_valid			(mj_data_valid),
	.value				(value_to_delay),
	.frame_out			(frame_out)
);

delay			delay_mod(
	.clk				(clk),
	.rst				(rst),
	.set				(start_delay),
	.value				(value_to_delay),
	
	.done				(delay_done)			// output
);

FIFO			FIFO_mod(
	.clk				(clk),
	.rst				(rst),
	.data_in			(check_data_out),
	.push				((!(check_frame_err_out) && valid_data)),
	.pop				(read_enable && (!fifo_empty)),
	
	.full				(fifo_full),			// output
	.empty				(fifo_empty),
	.data_out			(fifo_data_out),
	.fifo_valid			(fifo_valid)
);

Check_Frame		Check_Frame_mod(
	.clk				(clk),
	.rst				(rst),
	.data_in			(frame_out),
	.data_valid			(mj_data_valid),
	.frame_err_i		(mj_frame_err),
	.SW0				(SW0),					// even-parity (1) or no parity (0)
	.SW1				(SW1),					// 7 (0) or 8 (1)
	
	.frame_err_out		(check_frame_err_out),	// output
	.parity_err_out		(check_parity_err_out),
	.data_out			(check_data_out),
	.data_is_valid		(valid_data)
);

endmodule