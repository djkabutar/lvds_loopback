module data_gen #(
    parameter stride = 1
)(
    input clk,

    output reg [7:0] prbs_data = 0
);

always @(posedge clk) begin
    prbs_data <= prbs_data + stride;
end

endmodule
