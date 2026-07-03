module counter_control(
	input sys_clk,
	input sys_rst_n,
	input timer_en,
	input [3:0] div_val,
	input div_en,
	output cnt_en);
reg [7:0] cnt_int;
wire [7:0] limit = ( 8'h1 << div_val ) - 8'h1;


always @(posedge sys_clk or negedge sys_rst_n) begin
		if ( !sys_rst_n) begin
			cnt_int <= 8'h0;
		end else if ( !timer_en || !div_en) begin
			cnt_int <= 8'h0;
		end
		else if ( cnt_int == limit) begin
			cnt_int <= 8'h0;
		end
		else begin
			cnt_int <= cnt_int + 1'b1;
		end
	end
assign cnt_en = ( timer_en & ~div_en) || (( div_val != 0) & timer_en & div_en & ( cnt_int == limit)) || ((div_val == 0) & timer_en & div_en);

endmodule 

