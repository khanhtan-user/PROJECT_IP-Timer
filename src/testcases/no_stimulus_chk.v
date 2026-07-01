task run_test;
	begin
		$display("-------- no_stimulus_chk-----");
		repeat(20) @(posedge sys_clk);
		$display("No stimulus . DUT instance success");
	end
endtask
