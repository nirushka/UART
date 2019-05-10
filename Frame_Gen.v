module Frame_Gen(
	input 				clk,
	input 				rst,
	input [7:0]			data_in,
	input 				enable,		// write_en
	input 				SW0,		// even-parity (1) or no parity (0)
	input 				SW1,		// 7 (0) or 8 (1)
	input				delay_done, 
	
	output				done,		// set to the delay
	output 				data_out,
	output				busy
);

reg[10:0]	data_edit;
reg			flag,flag_finish;
reg[3:0]	i;
reg			en_flag;


always @(posedge clk) begin
	data_edit[0] <= 1;
	data_edit[10] <= 0;
	
	if (enable) begin
		en_flag <= 1;
	end
	else if (!enable) begin
		en_flag <= 0;
	end
	
	if (rst) begin
		en_flag <= 0;
		i <= 'd11;
		flag_finish <= 1;
		flag <= 1;
	end
	else if (!flag && delay_done) begin
		if (i == 10) begin
			i <= 11;
			flag <= 1;
			flag_finish <= 1;
		end
		else
			i <= i+1;
	end
	else if (SW0 && flag && en_flag) begin	
		flag <= 0;
		flag_finish <= 0;
		data_edit[1] <= SW1 ? ^data_in : 1;
		data_edit[2] <= SW1 ? data_in[0] : ^data_in;
		data_edit[9:3] <= SW1 ? data_in[7:1] : data_in[6:0];
		i <= 0;
	end
	else if (!SW0 && flag && en_flag)begin
		flag <= 0;
		flag_finish <= 0;
		data_edit[1] <= 1 ;
		data_edit[2] <= SW1 ? data_in[0] : 1 ;
		data_edit[9:3] <= SW1 ? data_in[7:1] : data_in[6:0];
		i <= 0;
	end
end

assign data_out = (i == 11) ? 1 : data_edit[10-i];  	 			// level   
assign done = ((i == 0 || i == 11) && flag_finish) || delay_done;	// pulse
assign busy = !flag_finish;											// pulse

endmodule