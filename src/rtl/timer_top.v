module timer_top (
	input sys_clk,
	input sys_rst_n,
	input tim_psel,
	input tim_pwrite,
	input tim_penable,
	input[11:0] tim_paddr,
	input[31:0]tim_pwdata,
	output[31:0]tim_prdata,
	input [3:0] tim_pstrb,
	output tim_pready,
	output tim_pslverr,
	output tim_int,
	input dbg_mode);
wire unused_dbg_mode = dbg_mode;
wire [3:0] unused_tim_pstrb = tim_pstrb;
wire wr_en;
wire rd_en;
wire [31:0] rdata;
wire [31:0] wdata;
wire [11:0] addr;
wire [63:0] cnt;
wire div_en;
wire [3:0] div_val;
wire timer_en;
wire int_en;
wire tdr0_wr_sel;
wire tdr1_wr_sel;
wire [63:0] tcmp;
wire clear;
wire set;
wire cnt_en;
apb_slave apb_slave (
	.tim_pwrite(tim_pwrite),
	.tim_psel(tim_psel),
	.rdata(rdata),
	.tim_penable(tim_penable),
	.tim_paddr(tim_paddr),
	.wdata(wdata),
	.tim_pwdata(tim_pwdata),
	.tim_prdata(tim_prdata),
	.addr(addr),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.tim_pslverr(tim_pslverr),
	.pready(tim_pready));

register register (
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.cnt(cnt),
	.addr(addr),
	.wdata(wdata),
	.int_st(set),
	.div_en(div_en),
	.div_val(div_val),
	.timer_en(timer_en),
	.int_en(int_en),
	.tdr0_wr_sel(tdr0_wr_sel),
	.tdr1_wr_sel(tdr1_wr_sel),
	.tcmp(tcmp),
	.clear(clear),
	.rdata(rdata));

counter_control counter_control(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.timer_en(timer_en),
	.div_val(div_val),
	.div_en(div_en),
	.cnt_en(cnt_en));

counter counter(
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.cnt_en(cnt_en),

	.wdata(wdata),
	.tdr0_wr_sel(tdr0_wr_sel),
	.tdr1_wr_sel(tdr1_wr_sel),
	.cnt(cnt));

interrupt interrupt (
	.sys_clk(sys_clk),
	.sys_rst_n(sys_rst_n),
	.cnt(cnt),
	.tcmp(tcmp),
	.int_en(int_en),
	.set(set),
	.int_clr(clear),
	.tim_int(tim_int));
endmodule
