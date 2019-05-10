module UART_TB;

	reg clk, rst;
	reg sw0,sw1,sw2,en;
	reg [4:0] state;
	reg [31:0] data;
	reg Rx;
	
	initial begin
	clk <= 0;
	rst<= 1;
	data <= 'b11111111111111111111111111111111;
	state <= 32;
	en <= 0;
	sw0 <=1;
	sw1 <=0;
	sw2 <=1;
	Rx <= 1;
	#20	rst <= 0;
	#1680000 data <= 'b111110110001011111000011011011111 ;//N - I 
	end

	always begin
		#10 clk <= ~clk;
	end
	
	always begin
		#8660 state <= state - 1;
	end
	
	always begin 
		#8680 Rx <= data[state];
	end

	UART  UART_mod(
		.clk			(clk),
		.rst			(rst),
		.Rx_in			(Rx),
		.SW0			(sw0),
		.SW1			(sw1),
		.SW2			(sw2),
		
		
		.LCD_DB			(LCD_DB),
		.LCD_RW			(LCD_RW),
		.LCD_RS			(LCD_RS),
		.LCD_Enable		(LCD_Enable),
		
		.Tx_out			(TX),
		.frame_err		(frame_err),
		.parity_err		(parity_err),
		.overrun_err	(overrun_err)
	);

	
endmodule