`include "defines.vh"
module pc(
    input wire clk,
    input wire rst,
    input wire[5:0] stall_i,
    input wire branch_flg_i,
    input wire[`RegDataBus] branch_addr_i,
    output reg[`AddrBusWidth] pc_o,
    output reg ce
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            ce <= 1'b0;
        end else begin
            ce <= 1'b1;
        end
    end

    always @ (posedge clk) begin
        if (ce == 1'b0) begin
            pc_o <= 32'h00000000;
        end else if (stall_i[0] == 1'b0) begin
            if (branch_flg_i == 1'b1) begin
                pc_o <= branch_addr_i;
            end else begin
                pc_o <= pc_o + 32'h4;
            end
        end
    end
endmodule