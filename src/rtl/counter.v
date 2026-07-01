module counter (
	input cnt_en,
	input tdr0_wr_sel,
	input tdr1_wr_sel,
	input sys_clk,
	input sys_rst_n,
	input [31:0] wdata,
	output [63:0] cnt);
reg [31:0] tdr0;
reg [31:0] tdr1;
wire [63:0] current_next = {tdr1,tdr0};
wire [63:0] cnt_next = current_next + 1'b1;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if ( !sys_rst_n) begin
		tdr0 <= 32'h0;
	end
	else if ( tdr0_wr_sel) begin
		tdr0 <= wdata;
	end
	else if ( cnt_en) begin
		tdr0 <= cnt_next[31:0];
	end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if ( ! sys_rst_n) begin
		tdr1 <= 32'h0;
	end
	else if ( tdr1_wr_sel) begin
		tdr1 <= wdata;
	end
	else if ( cnt_en) begin
		tdr1 <= cnt_next[63:32];
	end
end
	assign cnt = { tdr1, tdr0};
	endmodule 

