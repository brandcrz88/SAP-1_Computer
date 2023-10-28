`default_nettype none
`timescale 1ns/1ns
module sap_1(
	input clk,  // Change it to clk
	input rst, // Declare rst as an input instead of wire
	output [7:0] bus_out
);


reg[7:0] bus;
reg[7:0] bus_reg; // Pipelined bus

always @(*) begin
	if (ir_en) begin
		bus = ir_out;
	end else if (adder_en) begin
		bus = adder_out;
	end else if (a_en) begin
		bus = a_out;
	end else if (mem_en) begin
		bus = mem_out;
	end else if (pc_en) begin
		bus = pc_out;
	end else begin
		bus = 8'b0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		bus_reg <= 8'b0; 
	end else begin 
		bus_reg <= bus; // Pipelining the bus
	end	
end

// Used to be wire rst; here
wire hlt;
wire int_clk;  // Change it to internal clk, int_clk
clock clock(
	.hlt(hlt),
	.clk_in(clk),  // In the testbench, CLK is being generated by clk_in
	.clk_out(int_clk)
);

wire pc_inc;
wire pc_en;
wire[7:0] pc_out;
pc pc(
	.clk(int_clk),
	.rst(rst),
	.inc(pc_inc),
	.out(pc_out)
);


wire mar_load;
wire mem_en;
wire[7:0] mem_out;
memory mem(
	.clk(int_clk),
	.rst(rst),
	.load(mar_load),
	.bus(bus_reg),
	.out(mem_out)
);


wire a_load;
wire a_en;
wire[7:0] a_out;
reg_a reg_a(
	.clk(int_clk),
	.rst(rst),
	.load(a_load),
	.bus(bus_reg),
	.out(a_out)
);


wire b_load;
wire[7:0] b_out;
reg_b reg_b(
	.clk(int_clk),
	.rst(rst),
	.load(b_load),
	.bus(bus_reg),
	.out(b_out)
);


wire adder_sub;
wire adder_en;
wire[7:0] adder_out;
adder adder(
	.a(a_out),
	.b(b_out),
	.sub(adder_sub),
	.out(adder_out)
);


wire ir_load;
wire ir_en;
wire[7:0] ir_out;
ir ir(
	.clk(int_clk),
	.rst(rst),
	.load(ir_load),
	.bus(bus_reg),
	.out(ir_out)
);

controller controller(
	.clk(int_clk),
	.rst(rst),
	.opcode(ir_out[7:4]),
	.out(
	{
		hlt,
		pc_inc,
		pc_en,
		mar_load,
		mem_en,
		ir_load,
		ir_en,
		a_load,
		a_en,
		b_load,
		adder_sub,
		adder_en
	})
);

assign bus_out = bus_reg;

endmodule