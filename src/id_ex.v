`include "defines.vh"
module id_ex(
    input wire clk,
    input wire rst,

    input wire[`RegDataBus] id_inst,
    input wire[`OpCodeBus] id_opcode,
    input wire[`RegDataBus] id_reg1,
    input wire[`RegDataBus] id_reg2,
    input wire[`RegAddrBus] id_waddr,
    input wire id_wreg,
    input wire[5:0] stall_i,
    input wire[`RegDataBus] id_link_addr,
    input wire id_in_delayslot,
    input wire next_in_delayslot_i,
    input wire id_loadop_flg,
    
    output reg[`RegDataBus] ex_inst,
    output reg[`OpCodeBus] ex_opcode,
    output reg[`RegDataBus] ex_reg1,
    output reg[`RegDataBus] ex_reg2,
    output reg[`RegAddrBus] ex_waddr,
    output reg ex_wreg,
    output reg[`RegDataBus] ex_link_addr,
    output reg ex_in_delayslot,
    output reg in_delayslot_o,
    output reg prev_loadop_flg
);

    always @ (posedge clk) begin
        if (rst == 1'b1) begin
            ex_opcode <= `Ins_NOP_OP;
            ex_reg1 <= `Zero;
            ex_reg2 <= `Zero;
            ex_waddr <= `ZeroRegAddr;
            ex_wreg <= 1'b0;
            ex_link_addr <= `Zero;
            ex_in_delayslot <= 1'b0;
            in_delayslot_o <= 1'b0;
            ex_inst <= `Zero;
            prev_loadop_flg <= 1'b0;
        end else if ((stall_i[2] == 1'b1) && (stall_i[3] == 1'b0)) begin // ID suspend, EX continue
            ex_opcode <= `Ins_NOP_OP;
            ex_reg1 <= `Zero;
            ex_reg2 <= `Zero;
            ex_waddr <= `ZeroRegAddr;
            ex_wreg <= 1'b0;
            ex_link_addr <= `Zero;
            ex_in_delayslot <= 1'b0;
            in_delayslot_o <= 1'b0;
            ex_inst <= `Zero;
            prev_loadop_flg <= 1'b0;
        end else if (stall_i[2] == 1'b0) begin
            ex_opcode <= id_opcode;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_waddr <= id_waddr;
            ex_wreg <= id_wreg;
            ex_link_addr <= id_link_addr;
            ex_in_delayslot <= id_in_delayslot;
            in_delayslot_o <= next_in_delayslot_i;
            ex_inst <= id_inst;
            prev_loadop_flg <= id_loadop_flg;
        end
    end

endmodule