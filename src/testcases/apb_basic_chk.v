task run_test;
	begin 
	$display( " -------APB_BASIC_CHK-------");

	// 1. Valid ADDRESS To ALL 8 Reg.//
	$display(" Part 1: Check Valid_Address of 8 Register");
	 apb_read(12'h00); 
	 checker( "TCR_Valid_Addres", rdata_o, 32'h0000_0100);
	 
	
       	apb_read(12'h04);
       	checker("TDR0_Valid_Address", rdata_o, 32'h0000_0000);
	 


	
       	apb_read(12'h08); 
	checker("TDR1 Valid_Address", rdata_o, 32'h0000_0000);


	
       	apb_read(12'h0C); 
	checker("TCMP0_Valid_Address", rdata_o, 32'hFFFF_FFFF);
	


       	apb_read(12'h10);
       	checker("TCMP1_Valid_Address", rdata_o,32'hFFFF_FFFF);
	


	apb_read(12'h14);
	checker("TIER_Valid_Address", rdata_o, 32'h0000_0000);
	


	apb_read(12'h18);
	checker("TISR_Valid_Address", rdata_o, 32'h0000_0000);


	apb_read(12'h1C);
	checker("THCSR_Valid_Address", rdata_o,32'h0000_0000);
	

	$display(" ------ End of Part 1-----");

	// 2 . Read from Random Address.
		$display ("Part 2: Check value when read from a Reserved Addres");
	apb_read(12'hAB);
	checker("Reserved_Address : 12'hAB", rdata_o, 32'h0000_0000);
	
	apb_read(12'hDA);
	checker("Reserved_Address : 12'hDA", rdata_o, 32'h0000_0000);
		$display("----End of Part 2------");

	//3. check Transfer data no wait state ( pready = 1)
		$display("Part3: Check Transferdata no wait state ( pready = 1)");
	
	apb_write(12'h00, 32'h0000_0001);
	@(posedge sys_clk);
	checker ( " Pready after write", { 31'h0, tim_pready}, 32'h0000_0001);

	apb_read(12'h00);
	checker ( " Pready after read", { 31'h0, tim_pready}, 32'h0000_0001);

		$display("----End of Part 3----");

	//4. Check no error handling ( Pslverr always = 0)
	
		$display("Part4: Check No Error handling ( Pslverr = 0) ");
	
	apb_write(12'h00,32'hDEADBEEF);
	checker("Pslverr with valid_address", { 31'h0000_0000, tim_pslverr}, 32'h0000_0000);

	apb_write(12'hDA, 32'hDEADBEEF);
	checker("Pslverr with reserved_address", { 31'h0000_0000, tim_pslverr}, 32'h0000_0000);

	$display("-----End of Part 4");
	


end
endtask
