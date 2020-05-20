`include "defines.vh"
module mem_wb (
    input wire clk,
    input wire rst,

    input wire[`RegAddrBus] mem_waddr,
    input wire[`RegDataBus] mem_wdata,
    input wire mem_wreg,
    input wire[`RegDataBus] mem_hi,
    input wire[`RegDataBus] mem_lo,
    input wire mem_wspreg,
    input wire[5:0] stall_i,
    input wire mem_watomicreg,
    input wire mem_atomicreg_wdata,
    input wire mem_wcp0,
    input wire[`RegAddrBus] mem_cp0_waddr,
    input wire[`RegDataBus] mem_cp0_wdata,

    output reg[`RegAddrBus] wb_waddr,
    output reg[`RegDataBus] wb_wdata,
    output reg wb_wreg,
    output reg[`RegDataBus] wb_hi,
    output reg[`RegDataBus] wb_lo,
    output reg wb_wspreg,
    output reg wb_watomicreg,
    output reg wb_atomicreg_wdata,
    output reg wb_wcp0,
    output reg[`RegAddrBus] wb_cp0_waddr,
    output reg[`RegDataBus] wb_cp0_wdata
);

    always @ (posedge clk) begin
        if(rst == 1'b1) begin
            wb_waddr <= `ZeroRegAddr;
            wb_wdata <= `Zero;
            wb_wreg <= 1'b0;
            wb_hi <= `Zero;
            wb_lo <= `Zero;
            wb_wspreg <= 1'b0;
            wb_watomicreg <= 1'b0;
            wb_atomicreg_wdata <= 1'b0;
            wb_wcp0 <= 1'b0;
            wb_cp0_waddr <= 5'b00000;
            wb_cp0_wdata <= `Zero;
        end else if ((stall_i[4] == 1'b1) && (stall_i[5] == 1'b0)) begin    //MEM stall, WB continue
            wb_waddr <= `ZeroRegAddr;
            wb_wdata <= `Zero;
            wb_wreg <= 1'b0;
            wb_hi <= 1'b0;
            wb_lo <= 1'b0;
            wb_wspreg <= 1'b0;
            wb_watomicreg <= 1'b0;
            wb_atomicreg_wdata <= 1'b0;
            wb_wcp0 <= 1'b0;
            wb_cp0_waddr <= 5'b00000;
            wb_cp0_wdata <= `Zero;
        end else if (stall_i[4] == 1'b0) begin
            wb_waddr <= mem_waddr;
            wb_wdata <= mem_wdata;
            wb_wreg <= mem_wreg;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_wspreg <= mem_wspreg;
            wb_watomicreg <= mem_watomicreg;
            wb_atomicreg_wdata <= mem_atomicreg_wdata;
            wb_wcp0 <= mem_wcp0;
            wb_cp0_waddr <= mem_cp0_waddr;
            wb_cp0_wdata <= mem_cp0_wdata;
        end
    end

endmodule