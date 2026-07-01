module test_bench;
	reg sys_clk;
	reg sys_rst_n;
	reg tim_psel;
	reg tim_penable;
	reg tim_pwrite;
	reg [11:0] tim_paddr;
	reg [31:0] tim_pwdata;
	wire [31:0] tim_prdata;
	reg [3:0] tim_pstrb;
	wire tim_pready;
	wire tim_pslverr;
	wire tim_int;
	reg dbg_mode;
	integer error_count = 0;
	timer_top  dut (
		.sys_clk(sys_clk),
		.sys_rst_n(sys_rst_n),
		.tim_psel(tim_psel),
		.tim_pwrite(tim_pwrite),
		.tim_penable(tim_penable),
		.tim_paddr(tim_paddr),
		.tim_pwdata(tim_pwdata),
		.tim_prdata(tim_prdata),
		.tim_pready(tim_pready),
		.tim_pslverr(tim_pslverr),
		.tim_int(tim_int),
		.tim_pstrb(tim_pstrb),
		.dbg_mode(dbg_mode));

initial begin 
	sys_clk = 0;
end
always #5 sys_clk = ~sys_clk;

task apb_write ( input [11:0] addr, input [31:0] data); 
	begin
	@(posedge sys_clk); #1; 
	tim_psel = 1'b1;
	tim_pwrite = 1'b1;
	tim_penable = 1'b0;
	tim_paddr = addr;
	tim_pwdata = data;

	@(posedge sys_clk); #1;
	tim_penable = 1'b1;

	@(posedge sys_clk); #1;
	tim_psel = 1'b0;
	tim_penable = 1'b0;
end
endtask
reg [31:0] rdata_o;
task apb_read ( input [11:0] addr);
	begin
	@(posedge sys_clk); #1; 
	tim_psel = 1'b1;
	tim_pwrite = 1'b0;
	tim_penable = 1'b0;
	tim_paddr = addr;

	@(posedge sys_clk); #1;
	tim_penable = 1'b1;
	#1;
	rdata_o = tim_prdata;	
	@(posedge sys_clk); #1;
	tim_psel = 1'b0;
	tim_penable =  1'b0;
end
endtask

task checker ( input [255:0] name, input [31:0] actual, input [31:0] expected);
	begin
	if ( actual !== expected) begin
		$display ( "FAIL %0s . Actual = 0x%0h, Expect = 0x%0h, Time = %0t",name , actual,expected, $time);
		error_count = error_count + 1;
	end
	else begin
		$display ( " PASS %0s . Actual = 0x%0h, time = %0t", name , actual, $time);
	end
end
endtask


`include "run_test.v"
initial begin
	sys_rst_n = 1'b0;
	tim_psel = 1'b0;
	tim_pwrite = 1'b0;
	tim_penable = 1'b0;
	tim_paddr = 12'h0;
	tim_pwdata = 32'h0;
	tim_pstrb = 4'hF;
	dbg_mode = 1'b0;
	
	@(posedge sys_clk); 
		sys_rst_n = 1'b1;
	@(posedge sys_clk);
		sys_rst_n = 1'b0;
	 @(posedge sys_clk);
		sys_rst_n = 1'b1;
	 @(posedge sys_clk);
	 @(posedge sys_clk);
	 @(posedge sys_clk);
	 @(posedge sys_clk);
	 @(posedge sys_clk);
	 @(posedge sys_clk);
	run_test;
	if ( error_count == 0) 
		$display("Test_result PASSED");
	else 
		$display("Test_result FAILED");
	$finish;
end
endmodule



