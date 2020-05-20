`include "defines.vh"
module if_id(
    input wire clk,
    input wire rst,
    
    input wire[`AddrBusWidth] if_pc,
    input wire[`DataBusWidth] if_inst,
    input wire[5:0] stall_i,
    
    output reg[`AddrBusWidth] id_pc,
    output reg[`DataBusWidth] id_inst
);

always @ (posedge clk) begin
    if (rst == 1'b1) begin
        id_pc <= `Zero;
        id_inst <= `Zero;
    end else if ((stall_i[1] == 1'b1) && (stall_i[2] == 1'b0)) begin //IF suspend and ID continue
        id_pc <= `Zero;
        id_inst <= `Zero;
    end else if (stall_i[1] == 1'b0) begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end

endmodule