module register (
	input sys_clk,
	input sys_rst_n,
	input rd_en,
	input wr_en,
	input [63:0] cnt,
	input [11:0] addr,
	input  [31:0] wdata,
	input 	     int_st,
	output reg  div_en,
	output reg [3:0] div_val,
	output reg     timer_en,
	output wire    int_en,
	output wire      tdr0_wr_sel,
	output wire      tdr1_wr_sel,
	output wire [63:0] tcmp,
	output wire clear,
	output reg [31:0] rdata);
localparam TCR = 12'h00;
localparam TDR0 = 12'h04;
localparam TDR1 = 12'h08;
localparam TCMP0 = 12'h0C;
localparam TCMP1 = 12'h10;
localparam TIER = 12'h14;
localparam TISR = 12'h18;
localparam THCSR = 12'h1C;
wire tcr_wr_sel;
wire tcmp0_wr_sel;
wire tcmp1_wr_sel;
wire tier_wr_sel;
wire tisr_wr_sel;
wire thcsr_wr_sel;
reg int_en_reg;
assign halt_ack = 1'b0;
assign tcr_wr_sel = wr_en & ( addr == TCR);
assign tdr0_wr_sel = wr_en & ( addr == TDR0);
assign tdr1_wr_sel = wr_en & ( addr == TDR1);
assign tcmp0_wr_sel = wr_en & ( addr == TCMP0);
assign tcmp1_wr_sel = wr_en & ( addr == TCMP1);
assign tier_wr_sel = wr_en & ( addr == TIER);
assign tisr_wr_sel = wr_en & ( addr == TISR);
assign thcsr_wr_sel = wr_en & ( addr == THCSR);
reg halt_req_reg;
always @(*) begin
	if ( rd_en) begin
	case ( addr) 
		TCR: rdata = {20'h0,div_val[3:0],6'b0,div_en,timer_en};
		TDR0: rdata = cnt[31:0];
		TDR1: rdata =  cnt[63:32];
		TCMP0: rdata =  tcmp[31:0];
		TCMP1: rdata =  tcmp[63:32];
		TIER:  rdata = { 31'h0, int_en};
		TISR:  rdata = { 31'h0, int_st};
		THCSR:  rdata = { 30'h0,1'b0,halt_req_reg};
		default: rdata = 32'h0;
	endcase
end
	else
	begin rdata = 32'h0000_0000;
end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
	if ( ! sys_rst_n) begin
		div_val <= 4'b0001;
		div_en <= 1'b0;
		timer_en <= 1'b0;
	end
	else if ( tcr_wr_sel) begin
		timer_en <= wdata[0];
		div_en <= wdata[1];
			
			if ( wdata[11:8] <= 4'b1000) begin
				div_val <= wdata[11:8];
			end
		end
	end

reg [31:0] tcmp_0 ;
reg [31:0] tcmp_1;
always @(posedge sys_clk or negedge sys_rst_n) begin

		if ( !sys_rst_n) begin
		tcmp_0 <= 32'hFFFF_FFFF;
		tcmp_1 <= 32'hFFFF_FFFF;
	end
	else if ( tcmp0_wr_sel ) begin
	       	tcmp_0 <= wdata;
	end
	else if ( tcmp1_wr_sel) begin
		tcmp_1 <= wdata;
	end
end	

assign tcmp = {tcmp_1,tcmp_0};

always @(posedge sys_clk or negedge sys_rst_n) begin
	if ( !sys_rst_n) begin
		int_en_reg <= 1'b0;
	end
	else if ( tier_wr_sel ) begin
		int_en_reg <= wdata[0];
	end
end
assign int_en = int_en_reg;

assign clear = tisr_wr_sel & wdata[0];
always @(posedge sys_clk or negedge sys_rst_n) begin
	if ( ! sys_rst_n) begin
		halt_req_reg <= 1'b0;
	end
	else if ( thcsr_wr_sel) begin
		halt_req_reg <= wdata[0];
	end
end
endmodule
