`define SIZE 16
module FIFO(
	input 				clk,
	input 				rst,
	input [7:0]			data_in,
	input 				push,
	input 				pop,
	
	output				full,
	output				empty,
	output [7:0]		data_out,
	output				fifo_valid
);

reg  [7:0]			array[7:0];
reg  [7:0]			poped = 7'd0;
reg  [2:0]			count;
reg  [2:0]			head;


always @(posedge clk) begin
	if (rst) begin
		head <= 0;
		count <= 0;
	end
	else if (push && count != 7) begin		// push if there is a place
		array[(head+count) % 8] <= data_in;
		count <= count+1;
	end
	else if (pop && |count) begin			// pop if not empty
		poped <= array[head % 8];	
		count <= count-1;		
		head <= (head+1) % 8;
	end
end

assign full = (count == 7);      
assign empty = (count == 0);
assign data_out = poped;
assign fifo_valid = !empty && pop; 

endmodule