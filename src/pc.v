`default_nettype none
`timescale 1ns/1ns
module pc(
	input clk,
	input rst,
	input inc,
	output[7:0] out
);

reg[3:0] pc;

always @(posedge clk or posedge rst) begin
	if (rst) begin
		pc <= 4'b0;
	end else if (inc) begin
		pc <= pc + 1;
	end
end

assign out = pc;

endmodule
