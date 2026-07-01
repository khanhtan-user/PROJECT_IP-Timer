task run_test;
	begin

	$display("----- Part1: Interrup_check-------");


	apb_write(12'h04,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h0C, 32'h0000_0003);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h10, 32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h14,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h00,32'h0000_0101);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h00,32'h0000_0100);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	
	checker("masked_tim_int_0", {31'h0,tim_int},32'h0);

	apb_read(12'h18);
	checker("masked_int_st_set", rdata_o, 32'h0000_0001);

	apb_write(12'h18, 32'h0000_0001);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h04,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);






	apb_write(12'h04,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	
	apb_write(12'h0C, 32'h0000_0003);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h10, 32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h14,32'h0000_0001);
	@(posedge sys_clk);
	@(posedge sys_clk);
	
	apb_write(12'h00,32'h0000_0101);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);


	apb_write(12'h00,32'h0000_0100);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	checker("assert_tim_int_1", {31'h0,tim_int}, 32'h1);
	apb_read(12'h18);
	checker("assert_int_st_1", rdata_o, 32'h0000_0001);

	apb_write(12'h18,32'h0000_0001);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h18);
	checker("clear_TISR0", rdata_o,32'h0000_0000);
	checker("clear_tim_int_0", {31'h0,tim_int},32'h0);


end
endtask
