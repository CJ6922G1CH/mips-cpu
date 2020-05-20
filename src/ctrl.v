`include "defines.vh"
module ctrl(
    input wire rst,
    input wire id_stall_i,
    input wire ex_stall_i,
    output reg[5:0] stall_o
);
    //each bit in stall_o represents stall status of one module: PC/IF/ID/EX/MEM/WB
    always @(*) begin
        if (rst == 1'b1) begin
            stall_o <= 6'b000000;
        end else if (id_stall_i == 1'b1) begin
            stall_o <= 6'b000111;
        end else if (ex_stall_i == 1'b1) begin
            stall_o <= 6'b001111;
        end else begin
            stall_o <= 6'b000000;
        end
    end
endmodule