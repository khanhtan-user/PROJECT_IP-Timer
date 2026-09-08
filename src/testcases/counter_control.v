task run_test;
	integer i;
	begin

		$display("------Part1: Counter_chk---");

		apb_write(12'h00,32'h0000_0000);
		apb_write(12'h0C,32'hFFFF_FFFF);
		apb_write(12'h10,32'hFFFF_FFFF);
		apb_write(12'h14, 32'h0000_0000);
		@(posedge sys_clk);

		apb_write(12'h00,32'h0000_0101);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_write(12'h00,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_read(12'h04);
		checker("timer_en_1_with_div_val_0_and_stop_afte_6clk",rdata_o, 32'h0000_0006);

		apb_write(12'h04,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);


		$display("-----Check with div_val-------");

		apb_write(12'h04,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);

		// div_val =0
		apb_write(12'h00,32'h0000_0103);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
                 

                  
		apb_write(12'h00,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_read(12'h04);
		checker("counter_div_val_1", rdata_o,32'h0000_000a);


		apb_write(12'h04,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		
		// div_val = 2
		apb_write(12'h00,32'h0000_0203);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_write(12'h00,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_read(12'h04);
		checker("counter_div_val_2", rdata_o,32'h0000_0001);

		apb_write(12'h04,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);


		
		// div_val = 3; 32'h0000_0011_0011)
		apb_write(12'h00, 32'h0000_0303);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
        @(posedge sys_clk);
		
		 apb_write(12'h00,32'h0000_0000);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		
		 apb_read(12'h04);
		 checker("counter_div_val_3", rdata_o,32'h0000_0002);

		 apb_write(12'h04,32'h0000_0000);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		
		// div_val = 4; 32'h0000_0100_0011)
		apb_write(12'h00,32'h0000_0403);
		 @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);
         @(posedge sys_clk);        
		 @(posedge sys_clk);
		 apb_read(12'h04);
                  checker("counter_div_val_4", rdata_o,32'h0000_0001);
		
		// div_val = 8; 32'h0000_0803
		apb_write(12'h00,32'h0000_0803);
		for( i = 0; i <= 300; i = i+1) begin
			@(posedge sys_clk);
		end
		apb_read(12'h04);
		checker("counter_div_val_8", rdata_o,32'h0000_0002);


		  apb_write(12'h00,32'h0000_0000);
		  @(posedge sys_clk);
		  @(posedge sys_clk);
		  @(posedge sys_clk);
             

		 apb_write(12'h04,32'hFFFF_FFFF);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 apb_write(12'h08,32'hFFFF_FFFF);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 @(posedge sys_clk);


		 apb_write(12'h00,32'h0000_0103);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 apb_write(12'h00,32'h0000_0100);
		 @(posedge sys_clk);
		 @(posedge sys_clk);
		 @(posedge sys_clk);


		 apb_read(12'h04);
		 checker("TDR0_Run_at_overflow_after__2clk", rdata_o, 32'h0000_0002);

		 apb_read(12'h08);
		 checker("TDR1_run_at_overflow_after_2clk", rdata_o, 32'h0000_0000);
		
		apb_write(12'h00,32'h0000_0003);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);


		apb_write(12'h04, 32'hFFFF_FFFF);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);
		apb_write(12'h08,32'hFFFF_FFFF);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_write(12'h04,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);


		apb_write(12'h08,32'h0000_0000);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);


		apb_write(12'h04, 32'hAAAA_AAAA);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);

		apb_write(12'h08,32'hAAAA_AAA9);
		@(posedge sys_clk);
		@(posedge sys_clk);
		@(posedge sys_clk);





end
endtask
