module UART(
	input 				clk,
	input 				rst,
	input				Rx_in,
	input				SW0,			// (0 for no parity, 1 for even parity)
	input				SW1,			// (0 for 7 bit length, 1 for 8 bit length)
	input				SW2,			// (0 for 9600b/s, 1 for 115200b/s)
	
	output	[7:0]		LCD_DB,
	output				LCD_RW,
	output				LCD_RS,
	output				LCD_Enable,
	output				Tx_out,
	output				frame_err,		// LED1
	output				parity_err,		// LED2
	output 				overrun_err		// LED3
);

wire Tx_o;
wire frame_err_wire;
wire parity_err_wire;
wire overrun_err_wire;
wire LED1;
wire LED2;
wire LED3;

wire control_RW;
wire control_RS;
wire control_EN;
wire [7:0] control_DB;
wire tx_busy;
wire rx_valid;
wire control_write_en;
wire control_read_en;
wire [7:0] rx_frame_out;
wire [7:0] data_TX;
wire SW0_N;
wire SW1_N;
wire SW2_N;

assign LCD_DB = control_DB;
assign LCD_RW = control_RW;
assign LCD_RS = control_RS;
assign LCD_Enable = control_EN;
assign Tx_out = Tx_o;
assign frame_err = LED1;
assign parity_err = LED2;
assign overrun_err = LED3;


Receiver	Receiver_mod(
	.clk			(clk),
	.rst			(rst),
	.Rx				(Rx_in),
	.read_enable	(control_read_en),
	.SW0			(SW0_N),
	.SW1			(SW1_N),
	.SW2			(SW2_N),
	
	.rx_frame_out	(rx_frame_out),
	.valid			(rx_valid),
	.frame_err		(frame_err_wire),
	.parity_err		(parity_err_wire),
	.overrun_err	(overrun_err_wire)
);

TX			TX(
	.clk			(clk),
	.rst			(rst),
	.real_data_in	(data_TX),
	.write_en		(control_write_en),
	.SW0			(SW0_N),
	.SW1			(SW1_N),
	.SW2			(SW2_N),
	.busy_out		(tx_busy),
	.TX				(Tx_o)
);

Control		Control(
	.clk			(clk),
	.rst			(rst),
	.data_RX		(rx_frame_out),
	.valid_RX		(rx_valid),
	.busy_TX		(tx_busy),
	
	.frame_err		(frame_err_wire),
	.parity_err		(parity_err_wire),
	.overrun_err	(overrun_err_wire),
	
	.LCD_DB			(control_DB),
	.LCD_RW			(control_RW),
	.LCD_RS			(control_RS),
	.LCD_EN			(control_EN),
	.read_en		(control_read_en),
	.write_en		(control_write_en),
	.data_TX		(data_TX),

	.LED1			(LED1), 
	.LED2			(LED2),
	.LED3			(LED3)
);

Bonus		Bonus(
	.clk			(clk),
	.rst			(rst),
	.data_in		(rx_frame_out),
	.data_valid		(rx_valid),
	.SW0			(SW0),			// even-parity (1) or no parity (0)
	.SW1			(SW1),			// 7 (0) or 8 (1)
	.SW2			(SW2),			// Rate

	.SW0out			(SW0_N),
	.SW1out			(SW1_N),
	.SW2out			(SW2_N)
);

endmodule