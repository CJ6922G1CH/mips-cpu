`include "defines.vh"
module regs(
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] waddr,
    input wire[`RegDataBus] wdata,
    input wire we,
    input wire re1,
    input wire[`RegAddrBus] raddr1,
    input wire re2,
    input wire[`RegAddrBus] raddr2,

    output reg[`RegDataBus] reg1_o,
    output reg[`RegDataBus] reg2_o
);

reg[`RegDataBus] regfile[`RegNum-1:0];

always @(posedge clk) begin
    if(rst == 1'b0) begin
        if((we == 1'b1) && (waddr != 5'h0)) begin
            regfile[waddr] <= wdata;
        end
    end
end

always @(*) begin
    if(rst == 1'b1) begin
        reg1_o <= `Zero;
    end else if (raddr1 == 5'h0) begin
        reg1_o <= `Zero;
    end else if ((raddr1 == waddr) && (we == 1'b1) && (re1 == 1'b1)) begin
        reg1_o <= wdata;
    end else if (re1 == 1'b1) begin
        reg1_o <= regfile[raddr1];
    end else begin
        reg1_o <= `Zero;
    end
end
always @(*) begin
    if(rst == 1'b1) begin
        reg2_o <= `Zero;
    end else if (raddr2 == 5'h0) begin
        reg2_o <= `Zero;
    end else if ((raddr2 == waddr) && (we == 1'b1) && (re2 == 1'b1)) begin
        reg2_o <= wdata;
    end else if (re2 == 1'b1) begin
        reg2_o <= regfile[raddr2];
    end else begin
        reg2_o <= `Zero;
    end
end 
endmodule