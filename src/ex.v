`include "defines.vh"
module ex(
    input wire rst,

    input wire[`RegDataBus] inst_i,
    input wire[`OpCodeBus] opcode_i,
    input wire[`RegDataBus] reg1_i,
    input wire[`RegDataBus] reg2_i,
    input wire[`RegAddrBus] waddr_i,
    input wire wreg_i,
    input wire[`RegDataBus] hi_i,
    input wire[`RegDataBus] lo_i,
    input wire[`RegDataBus] hi_mem_i,
    input wire[`RegDataBus] lo_mem_i,
    input wire wspreg_mem_i,
    input wire[`RegDataBus] hi_wb_i,
    input wire[`RegDataBus] lo_wb_i,
    input wire wspreg_wb_i,
    input wire[`RegDataBus_DBL] hilo_temp_i,
    input wire[1:0] madd_stat_i,
    input wire[`RegDataBus] link_addr_i,
    input wire[1:0] div_stat_i,
    input wire[`RegDataBus] tmp_rem_i,
    input wire[`RegDataBus] tmp_quo_i,
    input wire[5:0] shift_cnt_i,
    input wire[`RegDataBus] cp0_i,
    input wire mem_wcp0,
    input wire[`RegAddrBus] mem_cp0_waddr,
    input wire[`RegDataBus] mem_cp0_wdata,
    input wire wb_wcp0,
    input wire[`RegAddrBus] wb_cp0_waddr,
    input wire[`RegDataBus] wb_cp0_wdata,

    input wire in_delayslot_i,

    output wire[`OpCodeBus] opcode_o,
    output reg wreg_o,
    output reg[`RegAddrBus] waddr_o,
    output reg[`RegDataBus] wdata_o,
    output reg[`RegDataBus] hi_o,
    output reg[`RegDataBus] lo_o,
    output reg wspreg_o,
    output reg[`RegDataBus_DBL] hilo_temp_o,
    output reg[1:0] madd_stat_o,
    output reg[1:0] div_stat_o,
    output reg[`RegDataBus] tmp_rem_o,
    output reg[`RegDataBus] tmp_quo_o,
    output reg[5:0] shift_cnt_o,
    output wire[`RegDataBus] reg2_o,
    output wire[`RegDataBus] ram_addr_o,
    output reg[`RegAddrBus] cp0_raddr_o,
    output reg wcp0_o,
    output reg[`RegAddrBus] cp0_waddr_o,
    output reg[`RegDataBus] cp0_wdata_o,

    output reg stallreq_o
);

    reg[`RegDataBus_DBL] multop;
    reg[`RegDataBus] HI;
    reg[`RegDataBus] LO;

    wire[`RegDataBus] reg2_i_com;
    wire[`RegDataBus] reg1_i_not;
    wire[`RegDataBus] result_sum;
    wire sum_ov_flg;
    wire reg1_eq_reg2;
    wire reg1_lt_reg2;
    wire[`RegDataBus] mul_multiplicand;
    wire[`RegDataBus] mul_multiplier;
    wire[`RegDataBus] div_dividend;
    wire[`RegDataBus] div_divisor;
    wire[`RegDataBus] div_quotient;
    wire[`RegDataBus] div_remainder;
    wire[`RegDataBus_DBL] hilo_temp;
    reg[`RegDataBus_DBL] hilo_temp1;
    reg[5:0] dividend_cnt;
    reg[5:0] divisor_cnt;
    reg[`RegDataBus] tmp_divisor;
    reg madd_stall;     //stall request for MADD/MADDU/MSUB/MSUBU instruction
    reg div_stall;      //stall request for division instruction

    assign opcode_o = opcode_i;
    assign ram_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
    assign reg2_o = reg2_i;

    // couplement of reg2
    assign reg2_i_com = ((opcode_i == `Ins_SUB_OP) || (opcode_i == `Ins_SUBU_OP) || (opcode_i == `Ins_SLT_OP)) ? (~reg2_i)+1 : reg2_i;
    assign result_sum = reg1_i + reg2_i_com;
    // whether the sum operation had overflowed
    assign sum_ov_flg = ((!reg1_i[31] && !reg2_i_com[31]) && result_sum[31]) || ((reg1_i[31] && reg2_i_com[31]) && (!result_sum[31]));
    assign reg1_lt_reg2 = ((opcode_i == `Ins_SLT_OP)) ?
                            ((reg1_i[31] && !reg2_i[31]) ||
                            (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
                            (reg1_i[31] && reg2_i[31] && result_sum[31])) : (reg1_i < reg2_i);
    assign reg1_i_not = ~reg1_i;

    always @(*) begin
        if (rst == 1'b1) begin
            wreg_o <= 1'b0;
            waddr_o <= `ZeroRegAddr;
            wdata_o <= `Zero;
        end else begin
            waddr_o <= waddr_i;
            if (((opcode_i == `Ins_ADD_OP) || (opcode_i == `Ins_ADDI_OP) || (opcode_i == `Ins_SUB_OP)) && (sum_ov_flg == 1'b1)) begin
                wreg_o <= 1'b0;     //  will not write register when overflow happens
            end else begin
                wreg_o <= wreg_i;
            end
            case (opcode_i)
                `Ins_AND_OP: begin
                    wdata_o <= reg1_i & reg2_i;
                end
                `Ins_OR_OP: begin
                    wdata_o <= reg1_i | reg2_i;
                end
                `Ins_NOR_OP: begin
                    wdata_o <= ~(reg1_i | reg2_i);
                end
                `Ins_XOR_OP: begin
                    wdata_o <= reg1_i ^ reg2_i;
                end
                `Ins_MFHI_OP: begin
                    wdata_o <= HI;
                end
                `Ins_MFLO_OP: begin
                    wdata_o <= LO;
                end
                `Ins_MOVZ_OP: begin
                    wdata_o <= reg1_i;
                end
                `Ins_MOVN_OP: begin
                    wdata_o <= reg1_i;
                end
                `Ins_MFC0_OP: begin
                    cp0_raddr_o <= inst_i[15:11];
                    wdata_o <= cp0_i;
                    if ((mem_wcp0 == 1'b1) && (mem_cp0_waddr == inst_i[15:11])) begin
                        wdata_o <= mem_cp0_wdata;
                    end else if ((wb_wcp0 == 1'b1) && (wb_cp0_waddr == inst_i[15:11])) begin
                        wdata_o <= wb_cp0_wdata;
                    end
                end
                `Ins_SLL_OP: begin
                    wdata_o <= (reg2_i << reg1_i[4:0]);
                end
                `Ins_SRL_OP: begin
                    wdata_o <= (reg2_i >> reg1_i[4:0]);
                end
                `Ins_SRA_OP: begin
                    wdata_o <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                end
                `Ins_SLT_OP, `Ins_SLTU_OP: begin
                    wdata_o <= reg1_lt_reg2;
                end
                `Ins_ADD_OP, `Ins_ADDU_OP, `Ins_ADDI_OP, `Ins_ADDIU_OP, `Ins_SUB_OP, `Ins_SUBU_OP: begin
                    wdata_o <= result_sum;
                end
                `Ins_MUL_OP: begin
                    wdata_o <= multop[31:0];
                end
                `Ins_CLZ_OP: begin
                    casez (reg1_i)
                        32'b1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 0;
                        32'b01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 1;
                        32'b001zzzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 2;
                        32'b0001zzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 3;
                        32'b00001zzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 4;
                        32'b000001zzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 5;
                        32'b0000001zzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 6;
                        32'b00000001zzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 7;
                        32'b000000001zzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 8;
                        32'b0000000001zzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 9;
                        32'b00000000001zzzzzzzzzzzzzzzzzzzzz: wdata_o <= 10;
                        32'b000000000001zzzzzzzzzzzzzzzzzzzz: wdata_o <= 11;
                        32'b0000000000001zzzzzzzzzzzzzzzzzzz: wdata_o <= 12;
                        32'b00000000000001zzzzzzzzzzzzzzzzzz: wdata_o <= 13;
                        32'b000000000000001zzzzzzzzzzzzzzzzz: wdata_o <= 14;
                        32'b0000000000000001zzzzzzzzzzzzzzzz: wdata_o <= 15;
                        32'b00000000000000001zzzzzzzzzzzzzzz: wdata_o <= 16;
                        32'b000000000000000001zzzzzzzzzzzzzz: wdata_o <= 17;
                        32'b0000000000000000001zzzzzzzzzzzzz: wdata_o <= 18;
                        32'b00000000000000000001zzzzzzzzzzzz: wdata_o <= 19;
                        32'b000000000000000000001zzzzzzzzzzz: wdata_o <= 20;
                        32'b0000000000000000000001zzzzzzzzzz: wdata_o <= 21;
                        32'b00000000000000000000001zzzzzzzzz: wdata_o <= 22;
                        32'b000000000000000000000001zzzzzzzz: wdata_o <= 23;
                        32'b0000000000000000000000001zzzzzzz: wdata_o <= 24;
                        32'b00000000000000000000000001zzzzzz: wdata_o <= 25;
                        32'b000000000000000000000000001zzzzz: wdata_o <= 26;
                        32'b0000000000000000000000000001zzzz: wdata_o <= 27;
                        32'b00000000000000000000000000001zzz: wdata_o <= 28;
                        32'b000000000000000000000000000001zz: wdata_o <= 29;
                        32'b0000000000000000000000000000001z: wdata_o <= 30;
                        32'b00000000000000000000000000000001: wdata_o <= 31;
                        32'b00000000000000000000000000000000: wdata_o <= 32;
                        default: ;
                    endcase
                end
                `Ins_CLO_OP: begin
                    casez (reg1_i)
                        32'b0zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 0;
                        32'b10zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 1;
                        32'b110zzzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 2;
                        32'b1110zzzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 3;
                        32'b11110zzzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 4;
                        32'b111110zzzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 5;
                        32'b1111110zzzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 6;
                        32'b11111110zzzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 7;
                        32'b111111110zzzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 8;
                        32'b1111111110zzzzzzzzzzzzzzzzzzzzzz: wdata_o <= 9;
                        32'b11111111110zzzzzzzzzzzzzzzzzzzzz: wdata_o <= 10;
                        32'b111111111110zzzzzzzzzzzzzzzzzzzz: wdata_o <= 11;
                        32'b1111111111110zzzzzzzzzzzzzzzzzzz: wdata_o <= 12;
                        32'b11111111111110zzzzzzzzzzzzzzzzzz: wdata_o <= 13;
                        32'b111111111111110zzzzzzzzzzzzzzzzz: wdata_o <= 14;
                        32'b1111111111111110zzzzzzzzzzzzzzzz: wdata_o <= 15;
                        32'b11111111111111110zzzzzzzzzzzzzzz: wdata_o <= 16;
                        32'b111111111111111110zzzzzzzzzzzzzz: wdata_o <= 17;
                        32'b1111111111111111110zzzzzzzzzzzzz: wdata_o <= 18;
                        32'b11111111111111111110zzzzzzzzzzzz: wdata_o <= 19;
                        32'b111111111111111111110zzzzzzzzzzz: wdata_o <= 20;
                        32'b1111111111111111111110zzzzzzzzzz: wdata_o <= 21;
                        32'b11111111111111111111110zzzzzzzzz: wdata_o <= 22;
                        32'b111111111111111111111110zzzzzzzz: wdata_o <= 23;
                        32'b1111111111111111111111110zzzzzzz: wdata_o <= 24;
                        32'b11111111111111111111111110zzzzzz: wdata_o <= 25;
                        32'b111111111111111111111111110zzzzz: wdata_o <= 26;
                        32'b1111111111111111111111111110zzzz: wdata_o <= 27;
                        32'b11111111111111111111111111110zzz: wdata_o <= 28;
                        32'b111111111111111111111111111110zz: wdata_o <= 29;
                        32'b1111111111111111111111111111110z: wdata_o <= 30;
                        32'b11111111111111111111111111111110: wdata_o <= 31;
                        32'b11111111111111111111111111111111: wdata_o <= 32;
                        default: ;
                    endcase
                end
                `Ins_BEQ_OP, `Ins_BGEZ_OP, `Ins_BGEZAL_OP, `Ins_BGTZ_OP,
                `Ins_BLEZ_OP, `Ins_BLTZ_OP, `Ins_BLTZAL_OP, `Ins_BNE_OP,
                `Ins_J_OP, `Ins_JAL_OP, `Ins_JALR_OP, `Ins_JR_OP: begin
                    wdata_o <= link_addr_i;
                end
                default: begin
                    wdata_o <= `Zero;
                end
            endcase
        end
    end

    always @(*) begin
        if (rst == 1'b1) begin
            HI <= `Zero;
            LO <= `Zero;
        end else if (wspreg_mem_i == 1'b1) begin
            HI <= hi_mem_i;
            LO <= lo_mem_i;
        end else if (wspreg_wb_i == 1'b1) begin
            HI <= hi_wb_i;
            LO <= lo_wb_i;
        end else begin
            HI <= hi_i;
            LO <= lo_i;
        end
    end

    always @(*) begin      //pipeline stall request
        stallreq_o = (madd_stall || div_stall);
    end

    always @(*) begin      //MADD、MADDU、MSUB、MUSBU instruction
        if (rst == 1'b1) begin
            hilo_temp_o <= {`Zero,`Zero};
            madd_stat_o <= 2'b00;
            madd_stall <= 1'b0;
        end else begin
            case (opcode_i)
                `Ins_MADD_OP, `Ins_MADDU_OP: begin
                    if (madd_stat_i == 2'b00) begin
                        hilo_temp_o <= multop;
                        madd_stat_o <= 2'b01;
                        hilo_temp1 <= {`Zero,`Zero};
                        madd_stall <= 1'b1;
                    end else if (madd_stat_i == 2'b01) begin
                        hilo_temp_o <= {`Zero,`Zero};
                        madd_stat_o <= 2'b10;
                        hilo_temp1 <= hilo_temp_i + {HI,LO};        //mult result +{HI,LO}
                        madd_stall <= 1'b0;
                    end
                end
                `Ins_MSUB_OP, `Ins_MSUBU_OP: begin
                    if (madd_stat_i == 2'b00) begin
                        hilo_temp_o <= ~multop + 1;
                        madd_stat_o <= 2'b01;
                        madd_stall <= 1'b1;
                    end else if (madd_stat_i == 2'b01) begin
                        hilo_temp_o <= {`Zero,`Zero};
                        madd_stat_o <= 2'b10;
                        hilo_temp1 <= hilo_temp_i + {HI,LO};
                        madd_stall <= 1'b0;
                    end
                end
                default: begin
                    hilo_temp_o <= {`Zero,`Zero};
                    madd_stat_o <= 2'b00;
                    madd_stall <= 1'b0;
                end
            endcase
        end
    end

    // convert the complement of dividend to true form
    assign div_dividend = ((opcode_i == `Ins_DIV_OP) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
    // convert the complement of divisor to true form
    assign div_divisor = ((opcode_i == `Ins_DIV_OP) && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;
    // convert the division result back to complement
    assign div_quotient = ((opcode_i == `Ins_DIV_OP) && (reg1_i[31] ^ reg2_i[31] == 1'b1)) ? {1'b1, (~tmp_quo_i[30:0] + 1)} : tmp_quo_i;
    assign div_remainder = ((opcode_i == `Ins_DIV_OP) && (reg1_i[31] == 1'b1)) ? {1'b1, (~tmp_rem_i[30:0] + 1)} : tmp_rem_i;

    always @(*) begin
        casez (div_dividend)
                        32'b1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 0;
                        32'b01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 1;
                        32'b001zzzzzzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 2;
                        32'b0001zzzzzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 3;
                        32'b00001zzzzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 4;
                        32'b000001zzzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 5;
                        32'b0000001zzzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 6;
                        32'b00000001zzzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 7;
                        32'b000000001zzzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 8;
                        32'b0000000001zzzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 9;
                        32'b00000000001zzzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 10;
                        32'b000000000001zzzzzzzzzzzzzzzzzzzz: dividend_cnt <= 11;
                        32'b0000000000001zzzzzzzzzzzzzzzzzzz: dividend_cnt <= 12;
                        32'b00000000000001zzzzzzzzzzzzzzzzzz: dividend_cnt <= 13;
                        32'b000000000000001zzzzzzzzzzzzzzzzz: dividend_cnt <= 14;
                        32'b0000000000000001zzzzzzzzzzzzzzzz: dividend_cnt <= 15;
                        32'b00000000000000001zzzzzzzzzzzzzzz: dividend_cnt <= 16;
                        32'b000000000000000001zzzzzzzzzzzzzz: dividend_cnt <= 17;
                        32'b0000000000000000001zzzzzzzzzzzzz: dividend_cnt <= 18;
                        32'b00000000000000000001zzzzzzzzzzzz: dividend_cnt <= 19;
                        32'b000000000000000000001zzzzzzzzzzz: dividend_cnt <= 20;
                        32'b0000000000000000000001zzzzzzzzzz: dividend_cnt <= 21;
                        32'b00000000000000000000001zzzzzzzzz: dividend_cnt <= 22;
                        32'b000000000000000000000001zzzzzzzz: dividend_cnt <= 23;
                        32'b0000000000000000000000001zzzzzzz: dividend_cnt <= 24;
                        32'b00000000000000000000000001zzzzzz: dividend_cnt <= 25;
                        32'b000000000000000000000000001zzzzz: dividend_cnt <= 26;
                        32'b0000000000000000000000000001zzzz: dividend_cnt <= 27;
                        32'b00000000000000000000000000001zzz: dividend_cnt <= 28;
                        32'b000000000000000000000000000001zz: dividend_cnt <= 29;
                        32'b0000000000000000000000000000001z: dividend_cnt <= 30;
                        32'b00000000000000000000000000000001: dividend_cnt <= 31;
                        32'b00000000000000000000000000000000: dividend_cnt <= 32;
                        default: ;
                    endcase

    end
    always @(*) begin
        casez (div_divisor)
                        32'b1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 0;
                        32'b01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 1;
                        32'b001zzzzzzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 2;
                        32'b0001zzzzzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 3;
                        32'b00001zzzzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 4;
                        32'b000001zzzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 5;
                        32'b0000001zzzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 6;
                        32'b00000001zzzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 7;
                        32'b000000001zzzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 8;
                        32'b0000000001zzzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 9;
                        32'b00000000001zzzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 10;
                        32'b000000000001zzzzzzzzzzzzzzzzzzzz: divisor_cnt <= 11;
                        32'b0000000000001zzzzzzzzzzzzzzzzzzz: divisor_cnt <= 12;
                        32'b00000000000001zzzzzzzzzzzzzzzzzz: divisor_cnt <= 13;
                        32'b000000000000001zzzzzzzzzzzzzzzzz: divisor_cnt <= 14;
                        32'b0000000000000001zzzzzzzzzzzzzzzz: divisor_cnt <= 15;
                        32'b00000000000000001zzzzzzzzzzzzzzz: divisor_cnt <= 16;
                        32'b000000000000000001zzzzzzzzzzzzzz: divisor_cnt <= 17;
                        32'b0000000000000000001zzzzzzzzzzzzz: divisor_cnt <= 18;
                        32'b00000000000000000001zzzzzzzzzzzz: divisor_cnt <= 19;
                        32'b000000000000000000001zzzzzzzzzzz: divisor_cnt <= 20;
                        32'b0000000000000000000001zzzzzzzzzz: divisor_cnt <= 21;
                        32'b00000000000000000000001zzzzzzzzz: divisor_cnt <= 22;
                        32'b000000000000000000000001zzzzzzzz: divisor_cnt <= 23;
                        32'b0000000000000000000000001zzzzzzz: divisor_cnt <= 24;
                        32'b00000000000000000000000001zzzzzz: divisor_cnt <= 25;
                        32'b000000000000000000000000001zzzzz: divisor_cnt <= 26;
                        32'b0000000000000000000000000001zzzz: divisor_cnt <= 27;
                        32'b00000000000000000000000000001zzz: divisor_cnt <= 28;
                        32'b000000000000000000000000000001zz: divisor_cnt <= 29;
                        32'b0000000000000000000000000000001z: divisor_cnt <= 30;
                        32'b00000000000000000000000000000001: divisor_cnt <= 31;
                        32'b00000000000000000000000000000000: divisor_cnt <= 32;
                        default: ;
                    endcase
    end

    always @(*) begin       //DIV DIVU instruction
        if (rst == 1'b1) begin
            tmp_rem_o <= `Zero;
            tmp_quo_o <= `Zero;
            div_stat_o <= 2'b00;
            shift_cnt_o <= 6'b000000;
            div_stall <= 1'b0;
        end else begin
            case (opcode_i)
                `Ins_DIV_OP, `Ins_DIVU_OP: begin
                    case (div_stat_i)
                        2'b00: begin
                            if (div_divisor == `Zero) begin     //divisor is zero
                                hilo_temp1 <= {`Zero,`Zero};
                            end else begin
                                tmp_quo_o <= `Zero;
                                hilo_temp1 <= {`Zero,`Zero};
                                tmp_rem_o <= div_dividend;
                                tmp_divisor <= div_divisor;
                                div_stall <= 1'b1;
                                if (divisor_cnt < dividend_cnt) begin
                                    div_stat_o <= 2'b10;
                                end else begin
                                    shift_cnt_o <= divisor_cnt - dividend_cnt;
                                    div_stat_o <= 2'b01;
                                end
                            end

                        end
                        2'b01: begin
                            if (tmp_rem_i >= (tmp_divisor << shift_cnt_i)) begin
                            tmp_quo_o <= tmp_quo_i + (1 << shift_cnt_i);
                            tmp_rem_o <= tmp_rem_i - (tmp_divisor << shift_cnt_i);
                            end
                            if (shift_cnt_i > 0) begin
                                shift_cnt_o <= shift_cnt_i - 1;
                            end else begin
                                div_stat_o <= 2'b10;
                            end
                        end
                        2'b10: begin
                            hilo_temp1 <= {div_remainder, div_quotient};
                            div_stat_o <= 2'b00;
                            div_stall <= 1'b0;
                        end
                        default: begin
                            hilo_temp1 <= {`Zero,`Zero};
                        end
                    endcase
                end
            endcase
        end
    end

    always @(*) begin      //MTC0 instruction
        if (rst == 1'b1) begin
            wcp0_o <= 1'b0;
            cp0_waddr_o <= 5'b00000;
            cp0_wdata_o <= `Zero;
        end else if (opcode_i == `Ins_MTC0_OP) begin
            wcp0_o <= 1'b1;
            cp0_waddr_o <= inst_i[15:11];
            cp0_wdata_o <= reg1_i;
        end else begin
            wcp0_o <= 1'b0;
            cp0_waddr_o <= 5'b00000;
            cp0_wdata_o <= `Zero;
        end
    end

    //convert the complement of multiplicand to true form
    assign mul_multiplicand = (((opcode_i == `Ins_MUL_OP) || (opcode_i == `Ins_MULT_OP) || (opcode_i == `Ins_MADD_OP) || (opcode_i == `Ins_MSUB_OP)) && (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
    //convert the complement of multiplier to true form
    assign mul_multiplier = (((opcode_i == `Ins_MUL_OP) || (opcode_i == `Ins_MULT_OP) || (opcode_i == `Ins_MADD_OP) || (opcode_i == `Ins_MSUB_OP)) && (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;
    assign hilo_temp = mul_multiplicand * mul_multiplier;

    always @(*) begin
        if(rst == 1'b1) begin
            multop <= {`Zero,`Zero};
        end else if ((opcode_i == `Ins_MULT_OP) || (opcode_i == `Ins_MUL_OP) || (opcode_i == `Ins_MADD_OP) || (opcode_i == `Ins_MSUB_OP)) begin
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin      //multiplicand and multiplier have different sign
                multop <= ~hilo_temp + 1;                   //convert the true form back to complement
            end else begin
                multop <= hilo_temp;
            end
        end else begin
                multop <= hilo_temp;
        end
    end

    always @(*) begin       //MTHI MTLO instruction
        if (rst == 1'b1) begin
            hi_o <= `Zero;
            lo_o <= `Zero;
            wspreg_o <= 1'b0;
        end else if ((opcode_i == `Ins_MULT_OP) || (opcode_i == `Ins_MULTU_OP)) begin
            hi_o <= multop[63:32];
            lo_o <= multop[31:0];
            wspreg_o <= 1'b1;
        end else if (opcode_i == `Ins_MTHI_OP) begin
            hi_o <= reg1_i;
            lo_o <= LO;
            wspreg_o <= 1'b1;
        end else if (opcode_i == `Ins_MTLO_OP) begin
            hi_o <= HI;
            lo_o <= reg1_i;
            wspreg_o <= 1'b1;
        end else if ((opcode_i == `Ins_MADD_OP) || (opcode_i == `Ins_MADDU_OP)) begin
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
            wspreg_o <= 1'b1;
        end else if ((opcode_i == `Ins_MSUB_OP) || (opcode_i == `Ins_MSUBU_OP)) begin
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
            wspreg_o <= 1'b1;
        end else if ((opcode_i == `Ins_DIV_OP) || (opcode_i == `Ins_DIVU_OP)) begin
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
            wspreg_o <= 1'b1;
        end else begin
            hi_o <= `Zero;
            lo_o <= `Zero;
            wspreg_o <= 1'b0;
        end
    end
endmodule