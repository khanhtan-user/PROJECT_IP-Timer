task run_test;
	begin
		$display("-----TCR_Check-----");
		$display("----- Read Reserved address-----");

	apb_read(12'h20);
	checker("Reserved_addr",rdata_o,32'h0000_0000);

	$display("---- Part1: Check TCR_reset value");
	apb_read(12'h00);
	checker("TCR_reset value", rdata_o,32'h0000_0100);
	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	$display("--- End of Part1--");

	$display("----Part2: TCR_timer_en check");
	apb_write(12'h00,32'h0000_0101);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_timer_en_set",rdata_o,32'h0000_0101);
	apb_read(12'h04);
	@(posedge sys_clk);
	checker("timer_enable_counter_running", rdata_o, 32'h0000_0008);

	apb_write(12'h00,32'h0000_0100);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_timer_en_clear", rdata_o,32'h0000_0100);

	$display("----End of Part 2------");

	$display("----- Part 3: TCR_div_en_check-------");

	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	
	apb_write(12'h00,32'h0000_0002);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_div_en_set", rdata_o,32'h0000_0002);


	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_div_en_clear", rdata_o,32'h0000_0000);

	$display("-----End of Part 3-------");

	$display("------ Part 4 : TCR_div_val_check----");
	
	$display("Check valid div_val");
	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_div_val_0_feed_back", rdata_o,32'h0000_0000);

	apb_write(12'h00, 32'h0000_0100);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_div_val_1_feedback",rdata_o,32'h0000_0100);
	
	apb_write(12'h00,32'h0000_0400);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_div_val_4", rdata_o,32'h0000_0400);

	apb_write(12'h00,32'h0000_0800);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_div_val_8", rdata_o,32'h0000_0800);

	$display("Check in_valid_div_val");
	$display("TCR_before_invalid: 0x%0h",rdata_o);

	apb_write(12'h00,32'h0000_0900);
	@(posedge sys_clk);
	apb_read(12'h00);
	checker("TCR_in_valid_div_val", rdata_o,32'h0000_0800);

	$display("-------End of Part 4-----");

	$display ("------ Part 5 : TDR_check----");
	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_write(12'h04,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_write(12'h08,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);

	$display("TDR0/1_reset_check");
	apb_read(12'h04);
	checker("TDR0_reset_check", rdata_o, 32'h0000_0000);

	apb_read(12'h08);
	checker("TDR1_reset_check", rdata_o, 32'h0000_0000);

	$display ("TDR0/1_check value");

	apb_write(12'h04,32'h0000_0005);
	 @(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h04);
	$display("TDR0 after loead = 0x%0h", rdata_o);
	checker("TDR0_load_value_5", rdata_o,32'h0000_0005);

	$display("Start Counter");
	apb_write(12'h00,32'h0000_0101);
	@(posedge sys_clk);
	apb_read(12'h04);
	checker("TDR0_check_affter_3clk", rdata_o,32'h0000_0008);
	apb_read(12'h08);
	checker("TDR1_check_after_3clk", rdata_o,32'h0000_0000);
	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	$display("------ End of Part 5----");

		$display("-------- Part 6 : TCMP0/1_check------");

	apb_read(12'h0C);
	checker("TCMP0_reset_check", rdata_o, 32'hFFFF_FFFF);

	apb_read(12'h10);
	checker("TCMP1_reset_check", rdata_o, 32'hFFFF_FFFF);
	
	apb_write(12'h0C,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h0C);
	checker("TCMP0_write_0",rdata_o,32'h0000_0000);

	apb_write(12'h10,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h10);
	checker("TCMP1_write_0", rdata_o,32'h0000_0000);
	
	apb_write(12'h0C,32'hFFFF_FFFF);
	 @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         apb_read(12'h0C);
         checker("TCMP0_write_max",rdata_o,32'hFFFF_FFFF);


	   apb_write(12'h10,32'hFFFF_FFFF);
          @(posedge sys_clk);
          @(posedge sys_clk);
          @(posedge sys_clk);
          apb_read(12'h10);
          checker("TCMP1_write_max",rdata_o,32'hFFFF_FFFF);


	apb_write(12'h0C,32'h0000_0010);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h0C);
	checker("TCMP0_load_10", rdata_o, 32'h0000_0010);

	apb_read(12'h10);
	checker("TCMP1_value_after_load_TCMP0", rdata_o,32'hFFFF_FFFF);
	
	apb_write(12'h0C,32'hFFFF_FFFF);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	$display("------ End of Part 6----");

	$display("----- Part 7 : TIER_check------");

	apb_read(12'h14);
	checker("TIER_reset_check", rdata_o, 32'h0000_0000);

	apb_write(12'h14,32'h0000_0001);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h14);
	checker("TIER_int_en_set", rdata_o,32'h0000_0001);



	apb_write(12'h0C,32'h0000_0015);
	@(posedge sys_clk);
	@(posedge sys_clk);
	

	apb_write(12'h10,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h00,32'h0000_0101);
	@(posedge sys_clk);

	
	apb_read(12'h0C);
	$display(" TCMP0 = 0x%0h", rdata_o);
	apb_read(12'h04);
	$display("TDR0 = 0x%0h",rdata_o);

//	checker("tim_int_asserted", {31'h0,tim_int}, 32'h0000_0001);
	$display("---- End of Part 7-----");

	$display("----- Part 8 : TISR_check-----");
	
	apb_read(12'h18);
	checker("TISR_int_check", rdata_o, 32'h0000_0001);
	@(posedge sys_clk);
	apb_write(12'h00,32'h0000_0000);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h00);
//	$display(" TCR = 0x%0h",rdata_o);
	apb_write(12'h18,32'h0000_0001);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	apb_read(12'h18);
	checker("TISR_rs_check", rdata_o, 32'h0000_0000);
	
	$display("------ End of Part 8 -----");
	
	$display("----- Part 9: THCSR_check-----");

	apb_read(12'h1C);
	checker("THCSR_rst_check", rdata_o,32'h0000_0000);

	apb_write(12'h1C, 32'h0000_0001);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);
	
	apb_read(12'h1C);
	checker("THCSR_load_value", rdata_o, 32'h0000_0001);


	// optional to_make_cov_perfect.
	
	apb_write(12'h0C,32'hFFFF_FFFF);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);

	apb_write(12'h10,32'hFFFF_FFFF);
	@(posedge sys_clk);
	@(posedge sys_clk);
	@(posedge sys_clk);


	 apb_write(12'h0C,32'h0000_0000);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);

         apb_write(12'h10,32'h0000_0000);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
	
	  apb_write(12'h14,32'h0000_0001);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);

         apb_write(12'h14,32'h0000_0000);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);

	 
	  apb_write(12'h1C,32'h0000_0001);
          @(posedge sys_clk);
          @(posedge sys_clk);
          @(posedge sys_clk);

          apb_write(12'h1C,32'h0000_0000);
          @(posedge sys_clk);
          @(posedge sys_clk);
          @(posedge sys_clk);
	
	  apb_write(12'h00,32'h0000_0700);
	  @(posedge sys_clk);
	  @(posedge sys_clk);
	  @(posedge sys_clk);
	
	  apb_write(12'h00,32'h0000_0800);
	  @(posedge sys_clk);
	  @(posedge sys_clk);
	  @(posedge sys_clk);

	   apb_write(12'h00,32'h0000_0000);
           @(posedge sys_clk);
           @(posedge sys_clk);
           @(posedge sys_clk);


end
endtask


