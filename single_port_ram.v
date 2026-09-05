module single_port_ram(clk,we,cs,addr,data_in,data_out);
	parameter DATA_WIDTH = 32;
	parameter DEPTH = 16;
	parameter ADDR_WIDTH = $clog2(DEPTH);
	input clk,we,cs;
	input [ADDR_WIDTH-1:0] addr;
	input [DATA_WIDTH-1:0] data_in;
	output reg [DATA_WIDTH-1:0] data_out;

	reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

	always@(posedge clk)begin
		if(cs)begin
			if(we)begin
				mem[addr] <= data_in;
			end
			else begin
				data_out <= mem[addr];
			end
		end
	end

endmodule
