module data_check #(
    parameter stride = 1
)(
    input clk,
    input [7:0] data_in,
    input prev_pass,

    output pass
);

reg [7:0] prev_data = 8'h00;
reg pass_1 = 0;

always @(posedge clk) begin
    if (data_in == prev_data + stride) begin
        pass_1 <= 1'b1;
    end else begin
        pass_1 <= 1'b0;
    end
    prev_data <= data_in;
end

assign pass = pass_1 & prev_pass;

endmodule
