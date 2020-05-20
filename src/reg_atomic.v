`include "defines.vh"
module reg_atomic(
    input wire clk,
    input wire rst,

    input wire exc_flg_i,
    input wire atomicbit_i,
    input wire we_i,

    output reg atomicbit_o
);

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            atomicbit_o <= 1'b0;
        end else if (exc_flg_i == 1'b1) begin
            atomicbit_o <= 1'b0;
        end else if (we_i == 1'b1) begin
            atomicbit_o <= atomicbit_i;
        end
    end
endmodule