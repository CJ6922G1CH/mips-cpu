`include "defines.vh"
module id(
    input wire rst,
    input wire[`AddrBusWidth] pc_i,
    input wire[`DataBusWidth] inst_i,

    input wire[`RegDataBus] reg1_i,
    input wire[`RegDataBus] reg2_i,

    input wire[`RegAddrBus] ex_waddr_i,
    input wire[`RegDataBus] ex_wdata_i,
    input wire ex_wreg_i,

    input wire[`RegAddrBus] mem_waddr_i,
    input wire[`RegDataBus] mem_wdata_i,
    input wire mem_wreg_i,

    input wire in_delayslot_i,
    input wire loadop_flg_i,

    output wire[`RegDataBus] inst_o,
    output reg[`OpCodeBus] opcode_o,
    output reg[`RegDataBus] reg1_o,
    output reg[`RegDataBus] reg2_o,
    output reg[`RegAddrBus] waddr_o,
    output reg wreg_o,

    output reg reg1_read_o,
    output reg reg2_read_o,
    output reg[`RegAddrBus] reg1_addr_o,
    output reg[`RegAddrBus] reg2_addr_o,

    output reg branch_flg_o,
    output reg[`RegDataBus] branch_addr_o,
    output reg[`RegDataBus] link_addr_o,        //return address saved by jump instructions
    output reg in_delayslot_o,
    output reg next_in_delayslot_o,

    output reg loadop_flg_o,
    output wire stallreq_o
);
wire[`RegDataBus] pc_plus_8;
wire[`RegDataBus] pc_plus_4;
wire[`RegDataBus] branchoffset;

reg[`RegDataBus] imme;

reg inv_ins_flg;      //flag of invalid instructions

reg ldstall_reg1;
reg ldstall_reg2;

// assign stallreq_o = 1'b0;
assign pc_plus_8 = pc_i + 8;
assign pc_plus_4 = pc_i + 4;
assign branchoffset = {{14{inst_i[15]}}, inst_i[15:0], 2'b00};
assign inst_o = inst_i;

    always @(*) begin
        if (rst == 1'b1) begin
            opcode_o <= `Ins_NOP_OP;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `ZeroRegAddr;
            reg2_addr_o <= `ZeroRegAddr;
            wreg_o <= 1'b0;
            waddr_o <= `ZeroRegAddr;
            imme <= 32'h0;
            branch_flg_o <= 1'b0;
            branch_addr_o <= `Zero;
            link_addr_o <= `Zero;
            next_in_delayslot_o <= 1'b0;
            loadop_flg_o <= 1'b0;
            inv_ins_flg <= 1'b0;        //invalid instruction

        end else begin
            opcode_o <= `Ins_NOP_OP;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];       //default reg1 address
            reg2_addr_o <= inst_i[20:16];
            waddr_o <= inst_i[15:11];       //default wire reg address
            wreg_o <= 1'b0;
            imme <= `Zero;
            branch_flg_o <= 1'b0;
            branch_addr_o <= `Zero;
            link_addr_o <= `Zero;
            next_in_delayslot_o <= 1'b0;
            loadop_flg_o <= 1'b0;
            inv_ins_flg <= 1'b1;
            case (inst_i[31:26])
                `Ins_Spcl: begin
                    case (inst_i[10:6])
                        5'b00000: begin
                            case (inst_i[5:0])
                                // Arithmetic operations
                                `Ins_ADD: begin
                                    opcode_o <= `Ins_ADD_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_ADDU: begin
                                    opcode_o <= `Ins_ADDU_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_SUB: begin
                                    opcode_o <= `Ins_SUB_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_SUBU: begin
                                    opcode_o <= `Ins_SUBU_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                // Shift and rotate operations
                                `Ins_SLLV: begin
                                    opcode_o <= `Ins_SLL_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_SRAV: begin
                                    opcode_o <= `Ins_SRA_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_SRLV: begin
                                    opcode_o <= `Ins_SRL_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                // Logical and bit-field operations
                                `Ins_AND: begin
                                    opcode_o <= `Ins_AND_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_OR: begin
                                    opcode_o <= `Ins_OR_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_NOR: begin
                                    opcode_o <= `Ins_NOR_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_XOR: begin
                                    opcode_o <= `Ins_XOR_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                // Condition testing and conditional move operations
                                `Ins_MOVN: begin
                                    opcode_o <= `Ins_MOVN_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                    if (reg2_o == `Zero) begin
                                        wreg_o <= 1'b0;
                                    end else begin
                                        wreg_o <= 1'b1;
                                    end
                                end
                                `Ins_MOVZ: begin
                                    opcode_o <= `Ins_MOVZ_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                    if (reg2_o == `Zero) begin
                                        wreg_o <= 1'b1;
                                    end else begin
                                        wreg_o <= 1'b0;
                                    end
                                end
                                `Ins_SLT: begin
                                    opcode_o <= `Ins_SLT_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_SLTU: begin
                                    opcode_o <= `Ins_SLTU_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                // Multiply and divide operations
                                `Ins_DIV: begin
                                    opcode_o <= `Ins_DIV_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b0;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_DIVU: begin
                                    opcode_o <= `Ins_DIVU_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b0;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_MULT: begin
                                    opcode_o <= `Ins_MULT_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b0;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_MULTU: begin
                                    opcode_o <= `Ins_MULTU_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b0;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_MFHI: begin
                                    opcode_o <= `Ins_MFHI_OP;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                // Accumulator assess operations
                                `Ins_MFLO: begin
                                    opcode_o <= `Ins_MFLO_OP;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_MTHI: begin
                                    opcode_o <= `Ins_MTHI_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= 1'b0;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_MTLO: begin
                                    opcode_o <= `Ins_MTLO_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                // Jumps and branches
                                `Ins_JR: begin
                                    opcode_o <= `Ins_JR_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    wreg_o <= 1'b0;
                                    link_addr_o <= `Zero;
                                    branch_flg_o <= 1'b1;
                                    branch_addr_o <= reg1_o;
                                    next_in_delayslot_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end
                                `Ins_JALR: begin
                                    opcode_o <= `Ins_JALR_OP;
                                    reg1_read_o <= 1'b1;
                                    reg2_read_o <= 1'b0;
                                    waddr_o <= inst_i[15:11];
                                    wreg_o <= 1'b1;
                                    link_addr_o <= pc_plus_8;
                                    branch_addr_o <= reg1_o;
                                    branch_flg_o <= 1'b1;
                                    next_in_delayslot_o <= 1'b1;
                                    inv_ins_flg <= 1'b0;
                                end

                                `Ins_SYNC: begin
                                    opcode_o <= `Ins_NOP_OP;
                                    reg1_read_o <= 1'b0;
                                    reg2_read_o <= 1'b1;
                                    wreg_o <= 1'b0;
                                    inv_ins_flg <= 1'b0;
                                end
                                default: begin

                                end
                            endcase
                        end
                        default: begin

                        end
                    endcase
                end
                `Ins_Spcl2: begin
                    case (inst_i[5:0])
                        // Arithmetic operations
                        `Ins_CLO: begin
                            opcode_o <= `Ins_CLO_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            wreg_o <= 1'b1;
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_CLZ: begin
                            opcode_o <= `Ins_CLZ_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            wreg_o <= 1'b1;
                            inv_ins_flg <= 1'b0;
                        end
                        // Multiply and divide operations
                        `Ins_MADD: begin
                            opcode_o <= `Ins_MADD_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            wreg_o <= 1'b0;
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_MADDU: begin
                            opcode_o <= `Ins_MADDU_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            wreg_o <= 1'b0;
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_MSUB: begin
                            opcode_o <= `Ins_MSUB_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            wreg_o <= 1'b0;
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_MSUBU: begin
                            opcode_o <= `Ins_MSUBU_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            wreg_o <= 1'b0;
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_MUL: begin
                            opcode_o <= `Ins_MUL_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b1;
                            wreg_o <= 1'b1;
                            inv_ins_flg <= 1'b0;
                        end
                        default: begin

                        end
                    endcase
                end
                // Arithmetic operations
                `Ins_ADDI: begin
                    opcode_o <= `Ins_ADDI_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imme <= {{16{inst_i[15]}}, inst_i[15:0]};
                    waddr_o <= inst_i[20:16];
                    wreg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_ADDIU: begin
                    opcode_o <= `Ins_ADDIU_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imme <= {{16{inst_i[15]}}, inst_i[15:0]};
                    waddr_o <= inst_i[20:16];
                    wreg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LUI: begin
                    opcode_o <= `Ins_OR_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imme <= {inst_i[15:0], 16'h0};
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    inv_ins_flg <= 1'b0;
                end
                // Logical and bit-field operations
                `Ins_ANDI: begin
                    opcode_o <= `Ins_AND_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imme <= {16'h0, inst_i[15:0]};
                    waddr_o <= inst_i[20:16];
                    wreg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_ORI: begin
                    opcode_o <= `Ins_OR_OP;
                    wreg_o <= 1'b1;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imme <= {16'h0, inst_i[15:0]};
                    waddr_o <= inst_i[20:16];
                    inv_ins_flg <= 1'b0;
                end
                `Ins_XORI: begin
                    opcode_o <= `Ins_XOR_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    imme <= {16'h0, inst_i[15:0]};
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    inv_ins_flg <= 1'b0;
                end
                // Condition testing and conditional move operations
                `Ins_SLTI: begin
                    opcode_o <= `Ins_SLT_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    imme <= {{16{inst_i[15]}}, inst_i[15:0]};  //有符号扩展，看
                    waddr_o <= inst_i[20:16];
                    inv_ins_flg <= 1'b0;
                end
                `Ins_SLTIU: begin
                    opcode_o <= `Ins_SLTU_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    imme <= {{16{inst_i[15]}}, inst_i[15:0]};  //有符号扩展，看
                    waddr_o <= inst_i[20:16];
                    inv_ins_flg <= 1'b0;
                end
                // Jumps and branches
                `Ins_BEQ: begin
                    opcode_o <= `Ins_BEQ_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    if (reg1_o == reg2_o) begin
                        branch_flg_o <= 1'b1;
                        branch_addr_o <= pc_plus_4 + branchoffset;
                        next_in_delayslot_o <= 1'b1;
                    end
                    inv_ins_flg <= 1'b0;
                end
                `Ins_BGTZ: begin
                    opcode_o <= `Ins_BGTZ_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b0;
                    if ((reg1_o[31] == 1'b0) && (reg1_o != `Zero)) begin
                        branch_flg_o <= 1'b1;
                        branch_addr_o <= pc_plus_4 + branchoffset;
                        next_in_delayslot_o <= 1'b1;
                    end
                    inv_ins_flg <= 1'b0;
                end
                `Ins_BLEZ: begin
                    opcode_o <= `Ins_BLEZ_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b0;
                    if ((reg1_o[31] == 1'b1) && (reg1_o != `Zero)) begin
                        branch_flg_o <= 1'b1;
                        branch_addr_o <= pc_plus_4 + branchoffset;
                        next_in_delayslot_o <= 1'b1;
                    end
                    inv_ins_flg <= 1'b0;
                end
                `Ins_BNE: begin
                    opcode_o <= `Ins_BNE_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    if (reg1_o != reg2_o) begin
                        branch_flg_o <= 1'b1;
                        branch_addr_o <= pc_plus_4 + branchoffset;
                        next_in_delayslot_o <= 1'b1;
                    end
                    inv_ins_flg <= 1'b0;
                end
                `Ins_J: begin
                    opcode_o <= `Ins_J_OP;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b0;
                    link_addr_o <= `Zero;
                    branch_flg_o <= 1'b1;
                    branch_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    next_in_delayslot_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_JAL: begin
                    opcode_o <= `Ins_JAL_OP;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= 5'b11111;
                    link_addr_o <= pc_plus_8;
                    branch_flg_o <= 1'b1;
                    branch_addr_o <= {pc_plus_4[31:28], inst_i[25:0], 2'b00};
                    next_in_delayslot_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_REGIMM: begin
                    case (inst_i[20:16])
                        // Jumps and branches
                        `Ins_BGEZ: begin
                            opcode_o <= `Ins_BGEZ_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            wreg_o <= 1'b0;
                            if (reg1_o[31] == 1'b0) begin
                                branch_flg_o <= 1'b1;
                                branch_addr_o <= pc_plus_4 + branchoffset;
                                next_in_delayslot_o <= 1'b1;
                            end
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_BGEZAL: begin
                            opcode_o <= `Ins_BGEZAL_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            waddr_o <= 5'b11111;
                            wreg_o <= 1'b1;
                            link_addr_o <= pc_plus_8;
                            if (reg1_o[31] == 1'b0) begin
                                branch_flg_o <= 1'b1;
                                branch_addr_o <= pc_plus_4 + branchoffset;
                                next_in_delayslot_o <= 1'b1;
                            end
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_BLTZ: begin
                            opcode_o <= `Ins_BLTZ_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            wreg_o <= 1'b0;
                            if (reg1_o[31] == 1'b1) begin
                                branch_flg_o <= 1'b1;
                                branch_addr_o <= pc_plus_4 + branchoffset;
                                next_in_delayslot_o <= 1'b1;
                            end
                            inv_ins_flg <= 1'b0;
                        end
                        `Ins_BLTZAL: begin
                            opcode_o <= `Ins_BLTZAL_OP;
                            reg1_read_o <= 1'b1;
                            reg2_read_o <= 1'b0;
                            waddr_o <= 5'b11111;
                            wreg_o <= 1'b1;
                            link_addr_o <= pc_plus_8;
                            if (reg1_o[31] == 1'b1) begin
                                branch_flg_o <= 1'b1;
                                branch_addr_o <= pc_plus_4 + branchoffset;
                                next_in_delayslot_o <= 1'b1;
                            end
                            inv_ins_flg <= 1'b0;
                        end
                        default: begin

                        end
                    endcase
                end
                // Load and store operations
                `Ins_LB: begin
                    opcode_o <= `Ins_LB_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LBU: begin
                    opcode_o <= `Ins_LBU_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LH: begin
                    opcode_o <= `Ins_LH_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LHU: begin
                    opcode_o <= `Ins_LHU_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LW: begin
                    opcode_o <= `Ins_LW_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LWL: begin
                    opcode_o <= `Ins_LWL_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_LWR: begin
                    opcode_o <= `Ins_LWR_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_SB: begin
                    opcode_o <= `Ins_SB_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_SH: begin
                    opcode_o <= `Ins_SH_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_SW: begin
                    opcode_o <= `Ins_SW_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_SWL: begin
                    opcode_o <= `Ins_SWL_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    inv_ins_flg <= 1'b0;
                end
                `Ins_SWR: begin
                    opcode_o <= `Ins_SWR_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b0;
                    inv_ins_flg <= 1'b0;
                end
                // Atomic Read-Modify-Write operations
                `Ins_LL: begin
                    opcode_o <= `Ins_LL_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg<= 1'b0;
                end
                `Ins_SC: begin
                    opcode_o <= `Ins_SC_OP;
                    reg1_read_o <= 1'b1;
                    reg2_read_o <= 1'b1;
                    wreg_o <= 1'b1;
                    waddr_o <= inst_i[20:16];
                    loadop_flg_o <= 1'b1;
                    inv_ins_flg<= 1'b0;
                end

                `Ins_PREF: begin
                    opcode_o <= `Ins_NOP_OP;
                    reg1_read_o <= 1'b0;
                    reg2_read_o <= 1'b0;
                    wreg_o <= 1'b0;
                    inv_ins_flg <= 1'b0;
                end
                default: begin

                end
            endcase

            if (inst_i[31:21] == 11'b00000000000) begin
                case (inst_i[5:0])
                    `Ins_SLL: begin
                        // op_o <= `OP_Shift;
                        opcode_o <= `Ins_SLL_OP;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b1;
                        imme[4:0] <= inst_i[10:6];
                        wreg_o <= 1'b1;
                        waddr_o <= inst_i[15:11];
                        inv_ins_flg <= 1'b0;
                    end
                    `Ins_SRL: begin
                        // op_o <= `OP_Shift;
                        opcode_o <= `Ins_SRL_OP;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b1;
                        imme[4:0] <= inst_i[10:6];
                        wreg_o <= 1'b1;
                        waddr_o <= inst_i[15:11];
                        inv_ins_flg <= 1'b0;
                    end
                    `Ins_SRA: begin
                        // op_o <= `OP_Shift;
                        opcode_o <= `Ins_SRA_OP;
                        reg1_read_o <= 1'b0;
                        reg2_read_o <= 1'b1;
                        imme[4:0] <= inst_i[10:6];
                        wreg_o <= 1'b1;
                        waddr_o <= inst_i[15:11];
                        inv_ins_flg <= 1'b0;
                    end
                    default: begin

                    end
                endcase
            end

            if ((inst_i[31:21] == 11'b01000000000) && (inst_i[10:2] == 000000000) && (inst_i[1:0] == 00)) begin
                opcode_o <= `Ins_MFC0_OP;
                wreg_o <= 1'b1;
                waddr_o <= inst_i[20:16];
                reg1_read_o <= 1'b0;
                reg2_read_o <= 1'b0;
                inv_ins_flg <= 1'b0;
            end else if ((inst_i[31:21] == 11'b01000000100) && (inst_i[10:2] == 000000000) && (inst_i[1:0] == 00)) begin
                opcode_o <= `Ins_MTC0_OP;
                wreg_o <= 1'b0;
                reg1_read_o <= 1'b1;
                reg1_addr_o <= inst_i[20:16];
                reg2_read_o <= 1'b0;
                inv_ins_flg <= 1'b0;
            end
        end
    end

    always @(*) begin
        ldstall_reg1 <= 1'b0;
        // prev instruction load data from ram to register, the current inst request data from same reg. a load relate happens
        if ((reg1_read_o == 1'b1) && (loadop_flg_i == 1'b1) && (ex_waddr_i == reg1_addr_o)) begin
            ldstall_reg1 <= 1'b1;       //request pipeline to stall
        end
    end
    always @(*) begin
        ldstall_reg2 <= 1'b0;
        if ((reg2_read_o == 1'b1) && (loadop_flg_i == 1'b1) && (ex_waddr_i == reg2_addr_o)) begin
            ldstall_reg2 <= 1'b1;
        end
    end
    assign stallreq_o = ldstall_reg1 || ldstall_reg2;

    //give opdata 1 from RAM
    always @(*) begin
        if(rst == 1'b1) begin
            reg1_o <= `Zero;
        end else if ((reg1_read_o == 1'b1) && (ex_waddr_i == reg1_addr_o) && (ex_wreg_i == 1'b1)) begin
            reg1_o <= ex_wdata_i;
        end else if ((reg1_read_o == 1'b1) && (mem_waddr_i == reg1_addr_o) && (mem_wreg_i == 1'b1)) begin
            reg1_o <= mem_wdata_i;
        end else if (reg1_read_o == 1'b1) begin
            reg1_o <= reg1_i;
        end else if (reg1_read_o == 1'b0) begin
            reg1_o <= imme;     //no read register, give immediate number from reg1
        end else begin
            reg1_o <= `Zero;
        end
    end

    //give opdata 2 from RAM
    always @(*) begin
        if(rst == 1'b1) begin
            reg2_o <= `Zero;
        end else if ((reg2_read_o == 1'b1) && (ex_waddr_i == reg2_addr_o) && (ex_wreg_i == 1'b1)) begin
            reg2_o <= ex_wdata_i;
        end else if ((reg2_read_o == 1'b1) && (mem_waddr_i == reg2_addr_o) && (mem_wreg_i == 1'b1)) begin
            reg2_o <= mem_wdata_i;
        end else if (reg2_read_o == 1'b1) begin
            reg2_o <= reg2_i;
        end else if (reg2_read_o == 1'b0) begin
            reg2_o <= imme;
        end else begin
            reg2_o <= `Zero;
        end
    end
    always @(*) begin
        if (rst == 1'b1) begin
            in_delayslot_o <= 1'b0;
        end else begin
            in_delayslot_o <= in_delayslot_i;
        end
    end

endmodule