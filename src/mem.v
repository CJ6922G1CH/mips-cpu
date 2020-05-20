`include "defines.vh"
module mem(
    input wire rst,

    input wire[`OpCodeBus] opcode_i,
    input wire[`RegAddrBus] waddr_i,
    input wire[`RegDataBus] wdata_i,
    input wire wreg_i,
    input wire[`RegDataBus] hi_i,
    input wire[`RegDataBus] lo_i,
    input wire wspreg_i,
    input wire[`RegDataBus] ram_addr_i,
    input wire[`RegDataBus] reg2_i,

    input wire[`RegDataBus] ram_i,

    input wire atomicreg_i,
    input wire wb_watomicreg,
    input wire wb_atomicreg_wdata_i,

    input wire wcp0_i,
    input wire[`RegAddrBus] cp0_waddr_i,
    input wire[`RegDataBus] cp0_wdata_i,

    output reg[`RegAddrBus] waddr_o,
    output reg[`RegDataBus] wdata_o,
    output reg wreg_o,
    output reg[`RegDataBus] hi_o,
    output reg[`RegDataBus] lo_o,
    output reg wspreg_o,
    output reg wram_o,
    output reg[`RegDataBus] ram_addr_o,
    output reg[3:0] ram_vldbyte_o,
    output reg[`RegDataBus] ram_data_o,
    output reg ram_ce_o,

    output reg watomicreg_o,
    output reg atomicreg_wdata_o,

    output reg wcp0_o,
    output reg[`RegAddrBus] cp0_waddr_o,
    output reg[`RegDataBus] cp0_wdata_o
);

    reg atomicbit;

    always @(*) begin
        if (rst == 1'b1) begin
            waddr_o <= `ZeroRegAddr;
            wdata_o <= `Zero;
            wreg_o <= 1'b0;
            hi_o <= `Zero;
            lo_o <= `Zero;
            wspreg_o <= 1'b0;
            wram_o <= 1'b0;
            ram_addr_o <= `Zero;
            ram_data_o <= `Zero;
            ram_vldbyte_o <= 4'b0000;
            ram_ce_o <= 1'b0;
            watomicreg_o <= 1'b0;
            atomicreg_wdata_o <= 1'b0;
            wcp0_o <= 1'b0;
            cp0_waddr_o <= 5'b00000;
            cp0_wdata_o <= `Zero;
        end else begin
            waddr_o <= waddr_i;
            wdata_o <= wdata_i;
            wreg_o <= wreg_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            wspreg_o <= wspreg_i;

            wram_o <= 1'b0;
            ram_addr_o <= `Zero;
            ram_data_o <= `Zero;
            ram_vldbyte_o <= 4'b1111;
            ram_ce_o <= 1'b0;
            watomicreg_o <= 1'b0;
            atomicreg_wdata_o <= 1'b0;
            wcp0_o <= wcp0_i;
            cp0_waddr_o <= cp0_waddr_i;
            cp0_wdata_o <= cp0_wdata_i;
            case (opcode_i)
                `Ins_LB_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {{24{ram_i[31]}}, ram_i[31:24]};
                        end
                        2'b01: begin
                            wdata_o <= {{24{ram_i[23]}}, ram_i[23:16]};
                        end
                        2'b10: begin
                            wdata_o <= {{24{ram_i[15]}}, ram_i[15:8]};
                        end
                        2'b11: begin
                            wdata_o <= {{24{ram_i[7]}}, ram_i[7:0]};
                        end
                        default: begin

                        end
                    endcase
                end
                `Ins_LBU_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {{24{1'b0}}, ram_i[31:24]};
                        end
                        2'b01: begin
                            wdata_o <= {{24{1'b0}}, ram_i[23:16]};
                        end
                        2'b10: begin
                            wdata_o <= {{24{1'b0}}, ram_i[15:8]};
                        end
                        2'b11: begin
                            wdata_o <= {{24{1'b0}}, ram_i[7:0]};
                        end
                        default: begin

                        end
                    endcase
                end
                `Ins_LH_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {{16{ram_i[31]}}, ram_i[31:16]};
                        end
                        2'b10: begin
                            wdata_o <= {{16{ram_i[15]}}, ram_i[15:0]};
                        end
                        default: begin
                            wdata_o <= `Zero;
                        end
                    endcase
                end
                `Ins_LHU_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {{16{1'b0}}, ram_i[31:16]};
                        end
                        2'b10: begin
                            wdata_o <= {{16{1'b0}}, ram_i[15:0]};
                        end
                        default: begin
                            wdata_o <= `Zero;
                        end
                    endcase
                end
                `Ins_LW_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    ram_vldbyte_o <= 4'b1111;
                    wdata_o <= ram_i;
                end
                `Ins_LWL_OP: begin
                    ram_addr_o <= {ram_addr_i[31:2], 2'b00};
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    ram_vldbyte_o <= 4'b1111;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= ram_i[31:0];
                        end
                        2'b01: begin
                            wdata_o <= {ram_i[23:0], reg2_i[7:0]};
                        end
                        2'b10: begin
                            wdata_o <= {ram_i[16:0], reg2_i[15:0]};
                        end
                        2'b11: begin
                            wdata_o <= {ram_i[7:0], reg2_i[23:0]};
                        end
                        default: begin

                        end
                    endcase
                end
                `Ins_LWR_OP: begin
                    ram_addr_o <= {ram_addr_i[31:2], 2'b00};
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    ram_vldbyte_o <= 4'b1111;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {reg2_i[31:8], ram_i[31:24]};
                        end
                        2'b01: begin
                            wdata_o <= {reg2_i[31:16], ram_i[31:16]};
                        end
                        2'b10: begin
                            wdata_o <= {reg2_i[31:24], ram_i[31:8]};
                        end
                        2'b11: begin
                            wdata_o <= ram_i;
                        end
                        default: begin
                            wdata_o <= `Zero;
                        end
                    endcase
                end
                `Ins_SB_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b1;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            ram_vldbyte_o <= 4'b1000;
                            ram_data_o <= {reg2_i[7:0], {24{1'b0}}};
                        end
                        2'b01: begin
                            ram_vldbyte_o <= 4'b0100;
                            ram_data_o <= {{8{1'b0}}, reg2_i[7:0], {16{1'b0}}};
                        end
                        2'b10: begin
                            ram_vldbyte_o <= 4'b0010;
                            ram_data_o <= {{16{1'b0}}, reg2_i[7:0], {8{1'b0}}};
                        end
                        2'b11: begin
                            ram_vldbyte_o <= 4'b0001;
                            ram_data_o <= {{24{1'b0}}, reg2_i[7:0]};
                        end
                        default: begin
                            ram_vldbyte_o <= 4'b0000;
                            ram_data_o <= `Zero;
                        end
                    endcase

                end
                `Ins_SH_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b1;
                    ram_ce_o <= 1'b1;

                    case (ram_addr_i[1:0])
                        2'b00: begin
                            ram_vldbyte_o <= 4'b1100;
                            ram_data_o <= {reg2_i[15:0], {16{1'b0}}};
                        end
                        2'b10: begin
                            ram_vldbyte_o <= 4'b0011;
                            ram_data_o <= {{16{1'b0}}, reg2_i[15:0]};
                        end
                        default: begin
                            ram_vldbyte_o <= 4'b0000;
                            ram_data_o <= `Zero;
                        end
                    endcase
                end
                `Ins_SW_OP: begin
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b1;
                    ram_ce_o <= 1'b1;
                    ram_vldbyte_o <= 4'b1111;
                    ram_data_o <= reg2_i;
                end
                `Ins_SWL_OP: begin
                    ram_addr_o <= {ram_addr_i[31:2], 2'b00};
                    wram_o <= 1'b1;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            ram_vldbyte_o <= 4'b1111;
                            ram_data_o <= reg2_i;
                        end
                        2'b01: begin
                            ram_vldbyte_o <= 4'b0111;
                            ram_data_o <= {{8{1'b0}}, reg2_i[31:8]};
                        end
                        2'b10: begin
                            ram_vldbyte_o <= 4'b0011;
                            ram_data_o <= {{16{1'b0}}, reg2_i[31:16]};
                        end
                        2'b11: begin
                            ram_vldbyte_o <= 4'b0001;
                            ram_data_o <= {{24{1'b0}}, reg2_i[31:24]};
                        end
                        default: begin
                            ram_vldbyte_o <= 4'b0000;
                            ram_data_o <= `Zero;
                        end
                    endcase
                end
                `Ins_SWR_OP: begin
                    ram_addr_o <= {ram_addr_i[31:2], 2'b00};
                    wram_o <= 1'b1;
                    ram_ce_o <= 1'b1;
                    case (ram_addr_i[1:0])
                        2'b00: begin
                            ram_vldbyte_o <= 4'b1000;
                            ram_data_o <= {reg2_i[7:0], {24{1'b0}}};
                        end
                        2'b01: begin
                            ram_vldbyte_o <= 4'b1100;
                            ram_data_o <= {reg2_i[15:0], {16{1'b0}}};
                        end
                        2'b10: begin
                            ram_vldbyte_o <= 4'b1110;
                            ram_data_o <= {reg2_i[23:0], {8{1'b0}}};
                        end
                        2'b11: begin
                            ram_vldbyte_o <= 4'b1111;
                            ram_data_o <= reg2_i;
                        end
                        default: begin
                            ram_vldbyte_o <= 4'b0000;
                            ram_data_o <= `Zero;
                        end
                    endcase
                end
                `Ins_LL_OP: begin
                    wdata_o <= ram_i;
                    ram_addr_o <= ram_addr_i;
                    wram_o <= 1'b0;
                    ram_ce_o <= 1'b1;
                    watomicreg_o <= 1'b1;
                    atomicreg_wdata_o <= 1'b1;
                end
                `Ins_SC_OP: begin
                    if (atomicbit == 1'b1) begin
                        wdata_o <= 32'b1;
                        ram_ce_o <= 1'b1;
                        wram_o <= 1'b1;
                        ram_addr_o <= ram_addr_i;
                        ram_data_o <= reg2_i;
                        watomicreg_o <= 1'b1;
                        atomicreg_wdata_o <= 1'b0;
                    end
                end
                default: begin

                end
            endcase
        end
    end
    always @(*) begin
        if (rst == 1'b1) begin
            atomicbit <= 1'b0;
        end else begin
            if (wb_watomicreg == 1'b1) begin
                atomicbit <= wb_atomicreg_wdata_i;
            end else begin
                atomicbit <= atomicreg_i;
            end
        end
    end
endmodule