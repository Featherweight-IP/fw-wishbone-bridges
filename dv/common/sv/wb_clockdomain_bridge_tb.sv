
/****************************************************************************
 * wb_clockdomain_bridge_tb.sv
 ****************************************************************************/
`ifdef NEED_TIMESCALE
`timescale 1ns/1ns
`endif
`include "wishbone_macros.svh"

`ifndef I_CLKDIV
`define I_CLKDIV 0
`endif

`ifndef T_CLKDIV
`define T_CLKDIV 0
`endif
  
/**
 * Module: wb_clockdomain_bridge_tb
 * 
 * TODO: Add module documentation
 */
module wb_clockdomain_bridge_tb(input clock);

`ifdef IVERILOG
`include "iverilog_control.svh"
`endif
	
`ifdef HAVE_HDL_CLOCKGEN
	reg clock_r = 0;
	initial begin
		forever begin
			#10;
			clock_r <= ~clock_r;
		end
	end
	assign clock = clock_r;
`endif
	
	localparam ADR_WIDTH = 32;
	localparam DAT_WIDTH = 32;
	localparam I_CLK_DIV = `I_CLKDIV;
	localparam T_CLK_DIV = `T_CLKDIV;
	
	reg 			reset /* verilator public */ = 0;
	reg[7:0] 		reset_cnt = 0;
	
	always @(posedge clock) begin
		if (reset_cnt == 0) begin
			reset <= 1;
			reset_cnt <= reset_cnt + 1;
		end else if (reset_cnt == 100) begin
			reset <= 0;
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end

	reg[3:0]		i_clock_cnt = 0;
	reg				i_clock_r = 0;
	wire 			i_clock = (I_CLK_DIV == 0)?clock:i_clock_r;

	always @(posedge clock) begin
		if (i_clock_cnt == I_CLK_DIV) begin
			i_clock_r <= ~i_clock_r;
			i_clock_cnt <= 0;
		end else begin
			i_clock_cnt <= i_clock_cnt + 1;
		end
	end

	reg[3:0]		t_clock_cnt = 0;
	reg				t_clock_r = 0;
	wire 			t_clock = (T_CLK_DIV == 0)?clock:t_clock_r;
	
	always @(posedge clock) begin
		if (t_clock_cnt == T_CLK_DIV) begin
			t_clock_r <= ~t_clock_r;
			t_clock_cnt <= 0;
		end else begin
			t_clock_cnt <= t_clock_cnt + 1;
		end
	end
	
	`WB_WIRES(i2b_,ADR_WIDTH,DAT_WIDTH);
	`WB_WIRES(b2t_,ADR_WIDTH,DAT_WIDTH);
	
	wb_initiator_bfm #(
			.ADDR_WIDTH(ADR_WIDTH),
			.DATA_WIDTH(DAT_WIDTH)
		) u_init_bfm (
			.clock(i_clock),
			.reset(reset),
			`WB_CONNECT(,i2b_)
		);

	wb_clockdomain_bridge #(
		.ADR_WIDTH(ADR_WIDTH),
		.DAT_WIDTH(DAT_WIDTH)
		) u_dut (
		.reset(reset),
		.i_clock(i_clock),
		`WB_CONNECT(i_, i2b_),
		.t_clock(t_clock),
		`WB_CONNECT(t_, b2t_)
		);
	
	wb_target_bfm #(
			.ADDR_WIDTH(ADR_WIDTH),
			.DATA_WIDTH(DAT_WIDTH)
		) u_targ_bfm (
			.clock(t_clock),
			.reset(reset),
			`WB_CONNECT(,b2t_)
		);

endmodule


