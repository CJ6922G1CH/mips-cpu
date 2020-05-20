`include "defines.vh"
module ex_mem(
    input wire clk,
    input wire rst,

    input wire[`OpCodeBus] ex_opcode,
    input wire[`RegDataBus] ex_ram_addr,
    input wire[`RegDataBus] ex_reg2,
    input wire ex_wreg,
    input wire[`RegDataBus] ex_wdata,
    input wire[`RegAddrBus] ex_waddr,
    input wire ex_wspreg,
    input wire[`RegDataBus] ex_hi,
    input wire[`RegDataBus] ex_lo,
    input wire[1:0] madd_stat_i,
    input wire[`RegDataBus_DBL] tmp_hilo_i,
    input wire[5:0] stall_i,
    input wire[1:0] div_stat_i,
    input wire[`RegDataBus] tmp_rem_i,
    input wire[`RegDataBus] tmp_quo_i,
    input wire[5:0] shift_cnt_i,
    input wire ex_wcp0,
    input wire[`RegAddrBus] ex_cp0_waddr,
    input wire[`RegDataBus] ex_cp0_wdata,

    output reg[`OpCodeBus] mem_opcode,
    output reg[`RegDataBus] mem_reg2,
    output reg[`RegDataBus] mem_ram_addr,
    output reg wreg_o,
    output reg[`RegDataBus] wdata_o,
    output reg[`RegAddrBus] waddr_o,
    output reg mem_wspreg,
    output reg[`RegDataBus] mem_hi,
    output reg[`RegDataBus] mem_lo,
    output reg[`RegDataBus_DBL] tmp_hilo_o,
    output reg[1:0] madd_stat_o,
    
    output reg[1:0] div_stat_o,
    output reg[`RegDataBus] tmp_rem_o,
    output reg[`RegDataBus] tmp_quo_o,
    output reg[5:0] shift_cnt_o,

    output reg mem_wcp0,
    output reg[`RegAddrBus] mem_cp0_waddr,
    output reg[`RegDataBus] mem_cp0_wdata
);
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            mem_opcode <= `Ins_NOP_OP;
            wdata_o <= `Zero;
            waddr_o <= `ZeroRegAddr;
            wreg_o <= 1'b0;
            mem_hi <= `Zero;
            mem_lo <= `Zero;
            mem_wspreg <= 1'b0;
            
            tmp_hilo_o <= {`Zero,`Zero};
            madd_stat_o <= 2'b00;

            div_stat_o <= 2'b00;
            tmp_rem_o <= `Zero;
            tmp_quo_o <= `Zero;
            shift_cnt_o <= 6'b000000;

            mem_ram_addr <= `Zero;
            mem_reg2 <= `Zero;

            mem_wcp0 <= 1'b0;
            mem_cp0_waddr <= 5'b00000;
            mem_cp0_wdata <= `Zero;
        end else if ((stall_i[3] == 1'b1) && (stall_i[4] == 1'b0)) begin    //EX stall， MEM continue
            mem_opcode <= `Ins_NOP_OP;
            wdata_o <= `Zero;
            waddr_o <= `ZeroRegAddr;
            wreg_o <= 1'b0;
            mem_hi <= `Zero;
            mem_lo <= `Zero;
            mem_wspreg <= 1'b0;
            
            tmp_hilo_o <= tmp_hilo_i;
            madd_stat_o <= madd_stat_i;

            div_stat_o <= div_stat_i;
            tmp_rem_o <= tmp_rem_i;
            tmp_quo_o <= tmp_quo_i;
            shift_cnt_o <= shift_cnt_i;

            mem_ram_addr <= `Zero;
            mem_reg2 <= `Zero;

            mem_wcp0 <= 1'b0;
            mem_cp0_waddr <= 5'b00000;
            mem_cp0_wdata <= `Zero;
        end else if (stall_i[3] == 1'b0) begin
            mem_opcode <= ex_opcode;
            wdata_o <= ex_wdata;
            waddr_o <= ex_waddr;
            wreg_o <= ex_wreg;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_wspreg <= ex_wspreg;
            
            tmp_hilo_o <= {`Zero,`Zero};
            madd_stat_o <= 2'b00;

            div_stat_o <= 2'b00;
            tmp_rem_o <= `Zero;
            tmp_quo_o <= `Zero;
            shift_cnt_o <= 6'b000000;
            mem_ram_addr <= ex_ram_addr;
            mem_reg2 <= ex_reg2;

            mem_wcp0 <= ex_wcp0;
            mem_cp0_waddr <= ex_cp0_waddr;
            mem_cp0_wdata <= ex_cp0_wdata;
        end else begin
            tmp_hilo_o <= tmp_hilo_i;
            madd_stat_o <= madd_stat_i;
        end
    end
endmodule