module interrupt(
	input sys_clk,
	input sys_rst_n,
	input [63:0] cnt,
	input [63:0] tcmp,
	input int_en,
	output set,
	input int_clr,
	output tim_int);
reg int_st;
wire int_set = ( cnt == tcmp);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if (! sys_rst_n) begin
		int_st <= 1'b0;
end
	else if ( int_clr) begin
		int_st <= 1'b0;
	end
	else if ( int_set) begin
		int_st <= 1'b1;
	end
end
assign set = int_st;
assign tim_int = ( int_en && int_st);
endmodule
	

