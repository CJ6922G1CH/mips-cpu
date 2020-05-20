`include "defines.vh"
module reg_spcl(
    input wire clk,
    input wire rst,

    input wire[`RegDataBus] hi_i,
    input wire[`RegDataBus] lo_i,
    input wire wspreg,

    output reg[`RegDataBus] hi_o,
    output reg[`RegDataBus] lo_o
);

always @ (posedge clk) begin
    if (rst == 1'b1) begin
        hi_o <= `Zero;
        lo_o <= `Zero;
    end else if (wspreg == 1'b1) begin
        hi_o <= hi_i;
        lo_o <= lo_i;
    end
end

endmodule