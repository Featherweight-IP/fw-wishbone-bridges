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
	reg[DAT_WIDTH-1:0]		dat_r[2:0];
	reg[DAT_WIDTH-1:0]		dat_w[2:0];
	reg[ADR_WIDTH-1:0]		adr[2:0];
	reg						we[2:0];
	reg[DAT_WIDTH/8-1:0]	sel[2:0];
	reg						req[2:0];
	wire					req_i;
	wire					ack_i;
	reg						ack[2:0];
	reg						ack_ack[2:0];
	
	reg[1:0]				i_state;
	reg[1:0]				t_state;

	
	// Initiator-clocked block
	// - Handles last two stages of dat_r
	`ifdef FW_RESET_ASYNC
		always @(posedge i_clock or posedge reset) begin
		`else
			always @(posedge i_clock) begin
			`endif
			if (reset) begin
				dat_r[0] <= {32{1'b0}};
				dat_r[1] <= {32{1'b0}};
				i_state <= 2'b0;
			end else begin
				dat_r[0] <= dat_r[1];
				dat_r[1] <= dat_r[2];
				adr[2] <= i_adr;
				dat_w[2] <= i_dat_w;
				
				sel[0] <= i_sel;
				we[0] <= i_we;
				
				ack[2] <= ack[1];
				ack[1] <= ack[0];
			
				req[0] <= req_i;
		
				case (i_state) 
					0: begin // Waiting for a i->t request
						if (i_cyc && i_stb) begin
							i_state <= 1;
						end
					end
					1: begin // Waiting for an acknowledge
						if (ack[2]) begin
							i_state <= 2;
						end
					end
					2: begin
						// Wait for the ack to be dropped before 
						// accepting another request
						if (!ack[2]) begin
							i_state <= 0;
						end
					end
					default: i_state <= 0;
				endcase
			end
		end

		assign req_i = ((i_state == 0 && i_cyc && i_stb) | i_state == 1);
		assign i_ack = (i_state == 1 && ack[2]);
		
		// Target-clocked block
		// - Handles last two stages of adr, dat_w
		// - Handles first stage of dat_r
`ifdef FW_RESET_ASYNC
			always @(posedge t_clock or posedge reset) begin
`else
			always @(posedge t_clock) begin
`endif
	
				if (reset) begin
					dat_w[0] <= {32{1'b0}};
					dat_w[1] <= {32{1'b0}};
					adr[0] <= {32{1'b0}};
					adr[1] <= {32{1'b0}};
					t_state <= 2'b00;
				end else begin
					dat_w[0] <= dat_w[1];
					dat_w[1] <= dat_w[2];
					adr[0] <= adr[1];
					adr[1] <= adr[2];
					
					sel[2] <= sel[1];
					sel[1] <= sel[0];
					we[2] <= we[1];
					we[1] <= we[0];
			
					req[2] <= req[1];
					req[1] <= req[0];
			
					ack[0] <= ack_i;
			
					case (t_state) 
						0: begin // Waiting for a request
							if (req[2]) begin
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
							if (!req[2]) begin
								t_state <= 0;
							end
						end
						default: t_state <= 0;
					endcase
			
				end
			end
			
			assign ack_i = ((t_ack && t_state == 1) || t_state == 2);
			assign t_cyc = (req[2] && (t_state == 0 || t_state == 1));
			assign t_stb = (req[2] && (t_state == 0 || t_state == 1));
			assign t_sel = sel[2];
			assign t_we  = we[2];

			endmodule


