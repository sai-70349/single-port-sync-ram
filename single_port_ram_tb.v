`include "single_port_ram.v"
module tb;
	parameter DATA_WIDTH = 32;
	parameter DEPTH = 16;
	parameter ADDR_WIDTH = $clog2(DEPTH);
	reg clk,cs,we;
	reg [ADDR_WIDTH-1:0] addr;
	reg [DATA_WIDTH-1:0] data_in;
	wire [DATA_WIDTH-1:0] data_out;

	single_port_ram DUT(.clk(clk),
						.cs(cs),
						.we(we),
						.data_in(data_in),
						.addr(addr),
						.data_out(data_out));

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end

	integer i,error_count;

	task writes;
		input [ADDR_WIDTH-1:0] addr_in;
		input [DATA_WIDTH-1:0] data_i;
		begin
			@(negedge clk);
			cs 		= 1'b1;
			we 		= 1'b1;
			addr 	= addr_in;
			data_in = data_i;

			@(posedge clk);
			#1;
			$display("we=%b cs=%b addr=%b data=%h",we,cs,addr_in,data_i);

			@(posedge clk);
			cs      = 1'b0;
			we      = 1'b0;
			addr    = 0;
			data_in = 0;
		end
	endtask

	// READ OPERATION

	task reads;
		input [ADDR_WIDTH-1:0] addr_in;
		input [DATA_WIDTH-1:0] expected_data;
		begin
			
			@(negedge clk);
			cs = 1'b1;
			we = 1'b0;
			addr = addr_in;

			@(posedge clk);
			#1;
			if(expected_data == data_out)begin
				$display("READ: addr = %b data = %h --> PASS READ",addr_in,expected_data);
			end
			else begin
				$display("READ: addr = %b data = %h -->  FAIL READ",addr_in,expected_data);
				error_count = error_count+1;
			end
			@(posedge clk);
			cs = 1'b0;
			we = 1'b0;
			addr = 1'b0;
		end
	endtask

	initial begin
		error_count = 0;

		cs = 1'b0;
		we = 1'b0;
		addr = 0;
		data_in = 0;

		// SINGLE WRITE TEST CASE

		$display("SINGLE WRITE TEST CASE");

		writes(4'd3,32'habcdef12);
		$display("---------------------------------------------------------");

		// SINGLE READ TEST CASE

		
		$display("SINGLE READ TEST CASE");

		reads(4'd3,32'habcdef12);
		$display("---------------------------------------------------------");

		// 5 WRITES

		$display("5 WRITES");

		for(i=0;i<5;i=i+1)begin
			writes(i,32'h01011001+i);
		end
		$display("---------------------------------------------------------");

		// 5 READS 

		$display("5 READS");

		for(i=0;i<5;i=i+1)begin
			reads(i,32'h01011001+i);
		end
		$display("---------------------------------------------------------");

		// FULL WRITE TEST CASE

		for(i=0;i<DEPTH;i=i+1)begin
			writes(i,32'h10000000+i);
		end
		$display("---------------------------------------------------------");


		// FULL READ TEST CASE

		for(i=0;i<DEPTH;i=i+1)begin
			reads(i,32'h10000000+i);
		end
		$display("---------------------------------------------------------");

		// OVERWRITE

		writes(4'd3,32'habcdabcd);
		reads(4'd3,32'habcdabcd);
		$display("---------------------------------------------------------");

		writes(4'd3,32'hdcbadcba);
		reads(4'd3,32'hdcbadcba);
		$display("---------------------------------------------------------");

		// EN=0 READS

		$display(" ENABLE = 0");

		@(negedge clk);
		cs = 1'b0;
		we = 1'b1;
		addr = 4'd5;
		data_in = 32'h11223344;

		@(posedge clk);

		@(negedge clk);
		cs = 1'b0;
		we = 1'b0;
		addr = 0;
		data_in = 0;

		// now read addr 5
		
		@(negedge clk);
		cs = 1'b1;
		we = 1'b0;
		addr = 4'd5;
		@(posedge clk);
		#1;
		if(data_out == 32'h11223344)begin
			$display("test failed");
			error_count = error_count+1;
		end
		else begin
			$display("test passed");
		end

		$display("---------------------------------------------------------");
		// TEST PATTERNS
		writes(4'd5,32'hAAAA_AAAA);
		reads(4'd5,32'hAAAA_AAAA);

		writes(4'd5,32'hFFFF_FFFF);
		reads(4'd5,32'hFFFF_FFFF);
		$display("---------------------------------------------------------");

		if(error_count ==0)begin
			$display("ALL TEST CASES PASSED");
		end
		else begin
			$display("ALL TEST CASES ARE FAILED");
			$display("error count=%0d",error_count);
		end

		
	end
	initial begin
			#1600;
			$finish;
		end


endmodule
