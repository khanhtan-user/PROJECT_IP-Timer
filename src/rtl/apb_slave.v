module apb_slave(
	input tim_pwrite,
	input tim_psel,
	input [31:0] rdata,
	input tim_penable,
	input [11:0] tim_paddr,
	output wire [31:0] wdata,
	input [31:0] tim_pwdata,
	output wire [31:0] tim_prdata,
	output wire [11:0] addr,
	output wire wr_en,
	output wire rd_en,
	output wire tim_pslverr,
	output wire  pready);
localparam TCR = 12'h00;
localparam TDR0 = 12'h04;
localparam TDR1 = 12'h08;
localparam TCMP0 = 12'h0C;
localparam TCMP1 = 12'h10;
localparam TIER = 12'h14;
localparam TISR = 12'h18;
localparam THCSR = 12'h1C;
wire valid_access;
wire addr_valid;
assign pready = 1'b1;
assign tim_pslverr = 1'b0;
assign addr = tim_paddr;
assign wdata = tim_pwdata;
assign tim_prdata = rdata;
assign valid_access = tim_psel & tim_penable;
assign addr_valid = ((tim_paddr == TCR) || ( tim_paddr == TDR0) || (tim_paddr == TDR1) || (tim_paddr == TCMP0) || ( tim_paddr == TCMP1) || ( tim_paddr == TIER) || (tim_paddr == TISR ) || ( tim_paddr == THCSR));
assign wr_en = valid_access & addr_valid &  tim_pwrite;
assign rd_en = valid_access & addr_valid &  ~tim_pwrite;
endmodule

