/////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2013-2019 Efinix Inc. All rights reserved.
//
// lvds_loopback_top.v
//
// *******************************
// Revisions:
// 1.0 Initial rev
// 1.1 Design updated to 2021.1
//
// *******************************
/////////////////////////////////////////////////////////////////////////////
//PORTING VERSION
//
module lvds_loopback_top (
    input tx_slowclk,
    input rstn,
    input rx_slowclk,
    input uart_clk,
    input txpll_locked,
    input rxpll_locked,
    
    input [7:0] rx_data1,
    input [7:0] rx_data2,
    input [7:0] rx_data3,
    input [7:0] rx_data4,
    input [7:0] rx_data5,
    input [7:0] rx_data6,
    input [7:0] rx_data7,
    input [7:0] rx_data8,
    input [7:0] rx_data11,
    input [7:0] rx_data12,
    input [7:0] rx_data13,
    input [7:0] rx_data14,
    input [7:0] rx_data15,
    input [7:0] rx_data16,
    input [7:0] rx_data17,
    input [7:0] rx_data18,
    input [7:0] rx_data19,
    input [7:0] rx_data20,
    input [7:0] rx_data21,
    
    output [7:0] prbs_data0,
    output [7:0] prbs_data1,
    output [7:0] prbs_data2,
    output [7:0] prbs_data3,
    output [7:0] prbs_data4,
    output [7:0] prbs_data5,
    output [7:0] prbs_data6,
    output [7:0] prbs_data7,
    output [7:0] prbs_data8,
    output [7:0] prbs_data10,
    output [7:0] prbs_data11,
    output [7:0] prbs_data12,
    output [7:0] prbs_data13,
    output [7:0] prbs_data14,
    output [7:0] prbs_data15,
    output [7:0] prbs_data16,
    output [7:0] prbs_data17,
    output [7:0] prbs_data18,
    output [7:0] prbs_data19,
    
    output [3:0] led,
    output fa_lock,
    output rxpll_rstn,
    output txpll_rstn
);


parameter LANES = 19;

wire pass;
wire [(LANES * 8) - 1:0] all_prbs_data;
wire [(LANES * 8) - 1:0] all_rx_data;
wire [7:0] fa_out0; 
wire stat_all;
reg start_fa;

reg rstn_filt, rstn_sync;
always @(posedge rx_slowclk or negedge rstn) begin
    if (!rstn) begin
        rstn_filt <= 1'b0;
        rstn_sync <= 1'b0;
    end else begin
        rstn_filt <= 1'b1;
        rstn_sync <= rstn_filt;
    end
end

assign {
    prbs_data4, prbs_data10, prbs_data3, prbs_data5, prbs_data17, 
    prbs_data6, prbs_data18, prbs_data12, prbs_data16, prbs_data19, prbs_data14, 
    prbs_data15, prbs_data11, prbs_data7, prbs_data8, prbs_data1, 
    prbs_data0, prbs_data2, prbs_data13
} = all_prbs_data;

assign all_rx_data = {
                rx_data14, rx_data12, rx_data17, rx_data16, rx_data15, 
                rx_data20, rx_data5, rx_data1, rx_data6, rx_data13, rx_data11, 
                rx_data7, rx_data4, rx_data2, rx_data19, rx_data18, 
                rx_data21, rx_data8, rx_data3
            };

genvar i;
generate
    for (i = 0; i < LANES; i = i + 1) begin : lane
        wire passed; 

        if (i == 0) begin
            data_gen #(.stride(i)) gen(
                .clk(tx_slowclk),
                .prbs_data(all_prbs_data[i * 8 +: 8])
            );

            data_check #(.stride(i)) check(
                .clk(rx_slowclk),
                .data_in(all_rx_data[i * 8 +: 8]),
                .prev_pass(1'b1),
                .pass(passed)
            );
        end else if (i == LANES - 1) begin
            data_gen #(.stride(i)) gen(
                .clk(tx_slowclk),
                .prbs_data(all_prbs_data[i * 8 +: 8])
            );

            data_check #(.stride(i)) check(
                .clk(rx_slowclk),
                .data_in(all_rx_data[i * 8 +: 8]),
                .prev_pass(lane[i - 1].passed),
                .pass(pass)
            );
        end else begin
            data_gen #(.stride(i)) gen(
                .clk(tx_slowclk),
                .prbs_data(all_prbs_data[i * 8 +: 8])
            );

            data_check #(.stride(i)) check(
                .clk(rx_slowclk),
                .data_in(all_rx_data[i * 8 +: 8]),
                .prev_pass(lane[i - 1].passed),
                .pass(passed)
            );
        end
    end
endgenerate

assign rxpll_rstn = rstn;
assign txpll_rstn = rstn;
assign rxpll_lockedo = rxpll_locked;
// assign stat_all = stat0;

//////////////// USER_LEDS //////////////////
assign led [0] = pass;
assign led [1] =  rxpll_locked;
assign led [2] = rx_heartbeat;
assign led [3] = tx_heartbeat;

// /////////////// Pass test ////////////////////
reg [9:0] pass_cnt;
reg [9:0] start_cnt;

////////////////heart beat//////////////////
// tx_slowclk = 62.5MHz ///
// rx_slowclk = 62.5MHz ///
reg [25:0] tx_clk_cnt;
reg tx_heartbeat;
always @(posedge tx_slowclk or negedge rstn) begin
	if (!rstn) begin
		tx_heartbeat <= 1'b1;
		tx_clk_cnt <= 26'b0;
		end 
	else begin
		tx_heartbeat <= tx_clk_cnt[25];
		tx_clk_cnt <= tx_clk_cnt + 1'b1;
		end
end

reg [25:0] rx_clk_cnt;
reg rx_heartbeat;
always @(posedge rx_slowclk or negedge rstn) begin
	if (!rstn) begin
		rx_heartbeat <= 1'b1;
		rx_clk_cnt <= 26'b0;
		end 
	else begin
		rx_heartbeat <= rx_clk_cnt[25];
		rx_clk_cnt <= rx_clk_cnt + 1'b1;
	end
end
		

always @(posedge rx_slowclk or negedge rstn) begin
    if (!rstn) begin
    start_cnt <= 10'b0;
    start_fa <= 1'b0;
    end else begin
        if(rxpll_locked == 1'b1) begin
            start_cnt <= start_cnt + 10'b1;
        end else begin
            start_cnt <= 10'b0;
        end
        if (start_cnt == 10'h3FF) begin
            start_cnt <= 10'h000;
            start_fa <= 1'b1;
        end
    end
end

endmodule