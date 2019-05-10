module Check_Frame(
	input 				clk,
	input 				rst,
	input [8:0]			data_in,
	input				data_valid,
	input 				frame_err_i,
	input				SW0,				// even-parity (1) or no parity (0)
	input				SW1,				// 7 (0) or 8 (1)
	
	output				data_is_valid,
	output				frame_err_out,
	output				parity_err_out,
	output [7:0]		data_out			// ASCII is up to 7 bits
);

reg[7:0]	data_no_parity;
reg 		d_valid;
reg			check;
reg			error_detected;


always @(posedge clk) 
	if (rst) begin
		check <= 'd0;
		error_detected <= 'd0;
	end
	else if (data_valid) begin
		d_valid <= 'd1;
		
		if (SW0) begin
			data_no_parity <= SW1 ? data_in[7:0] : data_in[6:0];
			check <= 'd1;
		end
		else begin
			data_no_parity <= SW1 ? data_in[7:0] : data_in[6:0];
		end
		
		error_detected <= (SW1 ? (^data_in[7:0] != data_in[8]) : (^data_in[6:0] != data_in[7])) ? 'd1 : 'd0;
	end
	else if (!data_valid) begin
		d_valid <= 'd0;
	end

assign parity_err_out = check ? error_detected : 0;	// level
assign frame_err_out = frame_err_i;					// level
assign data_out = data_no_parity;					// level
assign data_is_valid = d_valid;

endmodule
