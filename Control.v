module Control(
	input 				clk,
	input 				rst,
	input [7:0]			data_RX,
	input 				valid_RX,
	input 				busy_TX,
	input 				frame_err,
	input 				parity_err,
	input 				overrun_err,
	
	output [7:0]		LCD_DB,
	output				LCD_RW,
	output				LCD_RS,
	output				LCD_EN,
	output				read_en,
	output				write_en,
	output [7:0]		data_TX,
	output				LED1,		// frame_error
	output				LED2,		// parity_err
	output				LED3		// overrun_err
);


wire init_done;
wire delay_done;
wire lcd_ena;
wire [9:0] mem_data;
wire [16:0] val;

assign read_en = !busy_TX && init_done;
assign write_en = valid_RX; 
assign data_TX = data_RX;
assign LCD_DB = mem_data[7:0];
assign LCD_RW = mem_data[8];
assign LCD_RS = mem_data[9];
assign LCD_EN = lcd_ena;

assign LED1 = frame_err;
assign LED2 = parity_err;
assign LED3 = overrun_err;


delay_control	delay(
	.clk			(clk),
	.rst			(rst),
	.set			(start_delay),
	.value			(val),
	.done			(delay_done)
);

LCD_enable		enable(
	.clk			(clk),
	.rst			(rst),
	.start			(start_delay),
	.enable			(lcd_ena)
);

mem				mem(
	.clk			(clk),
	.rst			(rst),
	.rx_valid		(valid_RX),
	.set			(delay_done),
	.dataIn			(data_RX),
	.init_done		(init_done),
	.data_out		(mem_data),
	.start_delay	(start_delay),
	.value			(val)
);

endmodule