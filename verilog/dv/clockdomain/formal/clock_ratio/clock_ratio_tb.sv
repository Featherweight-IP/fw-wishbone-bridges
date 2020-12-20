/****************************************************************************
 * clock_ratio_tb.sv
 ****************************************************************************/
 
`include "wishbone_macros.svh"

/**
 * Module: clock_ratio_tb
 * 
 * TODO: Add module documentation
 */
module clock_ratio_tb;

	(* gclk *) wire clock;	

	localparam ADR_WIDTH = 32;
	localparam DAT_WIDTH = 32;
	
	`WB_WIRES(i2dut_,ADR_WIDTH,DAT_WIDTH);
	`WB_WIRES(dut2t_,ADR_WIDTH,DAT_WIDTH);
	wire[3:0]              i_clock_div_v;
	reg[3:0]               i_clock_div;
	wire[3:0]              t_clock_div_v;
	reg[3:0]               t_clock_div;
	
	reg[3:0] reset_cnt = 0;
	wire reset;
	initial assume (reset == 1);
	/*
	always @(posedge clock) begin
		if (reset_cnt == 15) begin
			reset <= 0;
			i_clock_div <= i_clock_div_v;
			t_clock_div <= t_clock_div_v;
			cover(1);
		end else begin
			reset_cnt <= reset_cnt + 1;
		end
	end
	 */
	
	wire[7:0] i_clock_step;
	reg[7:0] 		i_clock_cnt;

	always @* assume ((i_clock_step > 0) && (i_clock_step[7] == 1'b0));

	wire[7:0] t_clock_step;
	reg[7:0] t_clock_cnt;
	always @* assume ((t_clock_step > 0) && (t_clock_step[7] == 1'b0));

	wire i_clock;
	wire t_clock;
	
	always @(posedge clock) begin
		i_clock_cnt <= i_clock_cnt + i_clock_step;
		assume (i_clock == i_clock_cnt[7]);
		t_clock_cnt <= t_clock_cnt + t_clock_step;
		assume (t_clock == t_clock_cnt[7]);
	end
	
	// Initiator
	reg[2:0]				i_state;
	reg[ADR_WIDTH-1:0]		i_adr_r;
	reg[ADR_WIDTH-1:0]		i_adr_v;
	reg[DAT_WIDTH-1:0]		i_dat_w_r;
	reg[DAT_WIDTH-1:0]		i_dat_w_v;
	reg[DAT_WIDTH/8-1:0]		i_sel_r;
	reg[DAT_WIDTH/8-1:0]		i_sel_v;
	reg				i_we_v;
	reg				i_we_r;
	reg[7:0]			i_access_cnt;

	reg[DAT_WIDTH-1:0]		t_dat_r_r;
	wire[DAT_WIDTH-1:0]		t_dat_r_v;
	
	always @(posedge i_clock or posedge reset) begin
		if (reset) begin
			i_state <= 0;
			i_adr_r <= 0;
			i_dat_w_r <= 0;
			i_we_r <= 0;
			i_access_cnt <= 0;
		end else begin
			case (i_state) 
				2'b00: begin
					i_adr_r <= i_adr_v;
					i_dat_w_r <= i_dat_w_v;
					i_sel_r <= i_sel_v;
					i_we_r <= i_we_v;
					i_state <= 2'b01;
				end
				2'b01: begin
					if (i2dut_ack) begin
						i_state <= 2'b00;
						i_access_cnt <= i_access_cnt + 1;

						assert(t_dat_r_r == i2dut_dat_r);
						
						cover(i_access_cnt == 2);
					end
				end
				default:
					i_state <= 2'b00;
			endcase
		end
	end
	assign i2dut_adr   = i_adr_r;
	assign i2dut_dat_w = i_dat_w_r;
	assign i2dut_cyc   = (i_state == 2'b01 && !i2dut_ack);
	assign i2dut_stb   = i2dut_cyc;
	assign i2dut_sel   = i_sel_r;
	assign i2dut_we    = i_we_r;
	
	wb_clockdomain_bridge #(
			.ADR_WIDTH(ADR_WIDTH),
			.DAT_WIDTH(DAT_WIDTH)
		) u_dut(
			.reset(reset),
			.i_clock(i_clock),
			`WB_CONNECT(i_,i2dut_),
			.t_clock(t_clock),
			`WB_CONNECT(t_,dut2t_)
		);
	
	// Target state machine
	reg[1:0]			t_state;
	
	always @(posedge t_clock or posedge reset) begin
		if (reset) begin
			t_state <= 0;
		end else begin
			case (t_state)
				2'b00: begin
					if (dut2t_cyc && dut2t_stb) begin
						t_state <= 1;
						assert(dut2t_adr == i_adr_r);
						assert(dut2t_dat_w == i_dat_w_r);
						assert(dut2t_sel == i_sel_r);
						assert(dut2t_we == i_we_r);
						t_dat_r_r <= t_dat_r_v;
					end
				end
				2'b01: begin
					t_state <= 0;
				end
			endcase
		end
	end
	
	assign dut2t_ack = (t_state == 1);
	assign dut2t_dat_r = t_dat_r_r;

endmodule


