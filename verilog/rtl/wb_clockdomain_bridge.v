/****************************************************************************
 * wb_clockdomain_bridge.v
 * 
 * 
 ****************************************************************************/
`include "wishbone_macros.svh"
  
/**
 * Module: wb_clockdomain_bridge
 * 
 * TODO: Add module documentation
 */
module wb_clockdomain_bridge #(
		parameter ADR_WIDTH = 32,
		parameter DAT_WIDTH = 32
		) (
		input			reset,
		input			i_clock,
		`WB_TARGET_PORT(i_, ADR_WIDTH, DAT_WIDTH),
		input			t_clock,
		`WB_INITIATOR_PORT(t_, ADR_WIDTH, DAT_WIDTH)
		);

	// request path
	
	// response path
	reg[DAT_WIDTH-1:0]		dat_r0, dat_r1, dat_r2;
	reg[DAT_WIDTH-1:0]		dat_w0, dat_w1, dat_w2;
	reg[ADR_WIDTH-1:0]		adr0, adr1, adr2;
	reg				we0, we1, we2;
	reg[DAT_WIDTH/8-1:0]		sel0, sel1, sel2;
	reg				req0, req1, req2;
	wire				req_i;
	wire				ack_i;
	reg				ack0, ack1, ack2;
	
	reg[1:0]			i_state;
	reg[1:0]			t_state;

	
	// Initiator-clocked block
	// - Handles last two stages of dat_r
`ifdef FW_RESET_ASYNC
	always @(posedge i_clock or posedge reset) begin
`else
	always @(posedge i_clock) begin
`endif
			if (reset) begin
				dat_r0 <= {32{1'b0}};
				dat_r1 <= {32{1'b0}};
				adr0 <= {ADR_WIDTH{1'b0}};
				dat_w0 <= {DAT_WIDTH{1'b0}};
				sel0 <= {DAT_WIDTH/8{1'b0}};
				we0 <= 1'b0;
				ack2 <= 1'b0;
				ack1 <= 1'b0;
				req0 <= 1'b0;
				i_state <= 2'b0;
			end else begin
				dat_r0 <= dat_r1;
				dat_r1 <= dat_r2;
				adr0 <= i_adr;
				dat_w0 <= i_dat_w;
				
				sel0 <= i_sel;
				we0 <= i_we;
				
				ack2 <= ack1;
				ack1 <= ack0;
			
				req0 <= req_i;
		
				case (i_state) 
					0: begin // Waiting for a i->t request
						if (i_cyc && i_stb) begin
							i_state <= 1;
						end
					end
					1: begin // Waiting for an acknowledge
						if (ack2) begin
							i_state <= 2;
						end
					end
					2: begin
						// Wait for the ack to be dropped before 
						// accepting another request
						if (!ack2) begin
							i_state <= 0;
						end
					end
					default: i_state <= 0;
				endcase
			end
		end

		assign req_i = ((i_state == 0 && i_cyc && i_stb) | i_state == 1);
		assign i_ack = (i_state == 1 && ack2);
		assign i_dat_r = dat_r0;
		
		// Target-clocked block
		// - Handles last two stages of adr, dat_w
		// - Handles first stage of dat_r
`ifdef FW_RESET_ASYNC
			always @(posedge t_clock or posedge reset) begin
`else
			always @(posedge t_clock) begin
`endif
	
				if (reset) begin
					dat_w1 <= {32{1'b0}};
					dat_w2 <= {32{1'b0}};
					dat_r2 <= {32{1'b0}};
					adr1 <= {32{1'b0}};
					adr2 <= {32{1'b0}};
					ack0 <= 1'b0;
					sel1 <= {DAT_WIDTH/8{1'b0}};
					sel2 <= {DAT_WIDTH/8{1'b0}};
					we1 <= 1'b0;
					we2 <= 1'b0;
					req1 <= 1'b0;
					req2 <= 1'b0;
					t_state <= 2'b00;
				end else begin
					dat_w1 <= dat_w0;
					dat_w2 <= dat_w1;
					dat_r2 <= t_dat_r;
					adr1 <= adr0;
					adr2 <= adr1;
					
					sel1 <= sel0;
					sel2 <= sel1;
					we1 <= we0;
					we2 <= we1;
			
					req1 <= req0;
					req2 <= req1;
			
					ack0 <= ack_i;
			
					case (t_state) 
						0: begin // Waiting for a request
							if (req2) begin
								t_state <= 1;
							end
						end
						1: begin // Waiting for an acknowledge
							if (t_ack) begin
								t_state <= 2;
							end
						end
						2: begin
							// Ensure that req is dropped before proceeding
							if (!req2) begin
								t_state <= 0;
							end
						end
						default: t_state <= 0;
					endcase
			
				end
			end
			
			assign ack_i = ((t_ack && t_state == 1) || t_state == 2);
			assign t_adr = adr2;
			assign t_dat_w = dat_w2;
			assign t_cyc = (req2 && (t_state == 0 || t_state == 1));
			assign t_stb = (req2 && (t_state == 0 || t_state == 1));
			assign t_sel = sel2;
			assign t_we  = we2;

			endmodule


