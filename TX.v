module TX(
	input 				clk,
	input 				rst,
	input [7:0]			real_data_in,
	input 				write_en,
	input 				SW0,
	input 				SW1,
	input 				SW2,
	
	output				TX,
	output 				busy_out
);

wire 		FG_Data_Out;
wire 		FG_Done;
wire 		Delay_Done;
wire		busy;
wire [7:0]	data;

assign TX = FG_Data_Out;
assign busy_out = busy;

assign data[0] = SW1 ? real_data_in[7] : real_data_in[6];
assign data[1] = SW1 ? real_data_in[6] : real_data_in[5];
assign data[2] = SW1 ? real_data_in[5] : real_data_in[4];
assign data[3] = SW1 ? real_data_in[4] : real_data_in[3];
assign data[4] = SW1 ? real_data_in[3] : real_data_in[2];
assign data[5] = SW1 ? real_data_in[2] : real_data_in[1];
assign data[6] = SW1 ? real_data_in[1] : real_data_in[0];
assign data[7] = SW1 ? real_data_in[0] : 0;


Frame_Gen  Frame_Gen_mod(
	.clk		(clk),
	.rst		(rst),
	.data_in	(data),
	.enable		(write_en),
	.SW0		(SW0),
	.SW1		(SW1),
	.delay_done (Delay_Done),
	
	.done		(FG_Done),
	.data_out	(FG_Data_Out),
	.busy		(busy)
);

Delay_TX  Delay_TX_mod(
	.clk		(clk),
	.rst		(rst),
	.set		(FG_Done),
	.SW2		(SW2),
	
	.done		(Delay_Done)
);

endmodule