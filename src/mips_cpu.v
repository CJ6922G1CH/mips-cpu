`include "defines.vh"
module mips_cpu(
    input wire clk,
    input wire rst,
    input wire[`RegDataBus] rom_i,
    input wire[`RegDataBus] ram_i,
    input wire[5:0] int_flg_i,

    output wire[`RegDataBus] rom_addr_o,
    output wire rom_ce_o,
    output wire[`RegDataBus] ram_addr_o,
    output wire[`RegDataBus] ram_data_o,
    output wire ram_ce_o,
    output wire ram_we_o,
    output wire[3:0] ram_vldbyte_o,
    output wire timer_int_flg_o
);

wire[`AddrBusWidth] pc;
// input ports to ID
wire[`AddrBusWidth] id_pc_i;
wire[`DataBusWidth] id_inst_i;

// output ports from ID
wire id_prev_loadop_flg_i;

wire[`RegDataBus] id_inst_o;
// wire[`OpBus] id_op_o;
wire[`OpCodeBus] id_opcode_o;
wire[`RegDataBus] id_reg1_o;
wire[`RegDataBus] id_reg2_o;
wire[`RegAddrBus] id_waddr_o;
wire id_wreg_o;
wire id_in_delayslot_o;
wire[`RegDataBus] id_link_addr_o;
wire id_loadop_flg_o;

wire id_stall;

// input ports to EX
wire[`RegDataBus] ex_inst_i;
// wire[`OpBus] ex_op_i;
wire[`OpCodeBus] ex_opcode_i;
wire[`RegDataBus] ex_reg1_i;
wire[`RegDataBus] ex_reg2_i;
wire[`RegAddrBus] ex_waddr_i;
wire ex_wreg_i;
wire ex_in_delayslot_i;
wire[`RegDataBus] ex_link_addr_i;

wire[`RegDataBus] ex_cp0_data_i;

// output ports from EX
wire[`OpCodeBus] ex_opcode_o;
wire[`RegDataBus] ex_reg2_o;
wire[`RegAddrBus] ex_waddr_o;
wire[`RegDataBus] ex_wdata_o;
wire ex_wreg_o;
wire[`RegDataBus] ex_ram_addr_o;
wire[`RegDataBus] ex_hi_o;
wire[`RegDataBus] ex_lo_o;
wire ex_wspreg_o;

wire ex_wcp0_o;
wire[`RegAddrBus] ex_cp0_waddr_o;
wire[`RegDataBus] ex_cp0_wdata_o;

wire[`RegAddrBus] ex_cp0_raddr_o;
wire ex_stall;

// input ports to MEM
wire[`RegDataBus_DBL] ex_hilo_i;
wire[1:0] ex_madd_stat_i;
wire[1:0] from_ex_div_stat;
wire[`RegDataBus] from_ex_tmp_rem;
wire[`RegDataBus] from_ex_tmp_quo;
wire[5:0] from_ex_shift_cnt;

//wire[`RegDataBus] from_ram_data_i;

wire[`OpCodeBus] mem_opcode_i;
wire[`RegDataBus] mem_reg2_i;
wire[`RegDataBus] mem_ram_addr_i;
wire[`RegAddrBus] mem_waddr_i;
wire[`RegDataBus] mem_wdata_i;
wire mem_wreg_i;
wire[`RegDataBus] mem_hi_i;
wire[`RegDataBus] mem_lo_i;
wire mem_wspreg_i;

wire mem_wcp0_i;
wire[`RegAddrBus] mem_cp0_waddr_i;
wire[`RegDataBus] mem_cp0_wdata_i;

wire[`RegDataBus_DBL] ex_hilo_o;
wire[1:0] ex_madd_stat_o;

wire[1:0] to_ex_div_stat;
wire[`RegDataBus] to_ex_tmp_rem;
wire[`RegDataBus] to_ex_tmp_quo;
wire[5:0] to_ex_shift_cnt;

wire areg_atomicdata_i;

// output ports from MEM
wire[`RegAddrBus] mem_waddr_o;
wire[`RegDataBus] mem_wdata_o;
wire mem_wreg_o;

wire[`RegDataBus] mem_hi_o;
wire[`RegDataBus] mem_lo_o;
wire mem_wspreg_o;
wire mem_watomicreg_o;
wire mem_atomicreg_wdata_o;

wire mem_wcp0_o;
wire[`RegAddrBus] mem_cp0_waddr_o;
wire[`RegDataBus] mem_cp0_wdata_o;

//input ports to WB
wire[`RegAddrBus] wb_waddr_i;
wire[`RegDataBus] wb_wdata_i;
wire wb_we_i;
wire[`RegDataBus] wb_hi_i;
wire[`RegDataBus] wb_lo_i;
wire wb_wspreg_i;

wire wb_watomicreg_i;
wire wb_atomicreg_wdata_i;

wire wb_wcp0_i;
wire[`RegAddrBus] wb_cp0_waddr_i;
wire[`RegDataBus] wb_cp0_wdata_i;

// ports to register module from ID
wire re1;
wire[`RegAddrBus] raddr_1;
wire re2;
wire[`RegAddrBus] raddr_2;
// ports to ID from register module
wire[`RegDataBus] rdata_1;
wire[`RegDataBus] rdata_2;


//ports from special register to EX
wire[`RegDataBus] ex_hi_i;
wire[`RegDataBus] ex_lo_i;

wire in_delayslot_i;
wire in_delayslot_o;
wire id_next_in_delayslot_o;
wire id_branch_flg_o;
wire[`RegDataBus] id_branch_addr_o;
wire[5:0] stall;

regs regs0(
    .clk(clk),
    .rst(rst),
    .waddr(wb_waddr_i),
    .wdata(wb_wdata_i),
    .we(wb_we_i),
    .re1(re1),
    .raddr1(raddr_1),
    .reg1_o(rdata_1),
    .re2(re2),
    .raddr2(raddr_2),
    .reg2_o(rdata_2)
);

pc pc0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),
    .branch_flg_i(id_branch_flg_o),
    .branch_addr_i(id_branch_addr_o),
    .pc_o(pc),
    .ce(rom_ce_o)
);
assign rom_addr_o = pc;

if_id if_id0(
    .clk(clk),
    .rst(rst),
    .if_pc(pc),
    .if_inst(rom_i),
    .stall_i(stall),
    .id_pc(id_pc_i),
    .id_inst(id_inst_i)
);

id id0(
    .rst(rst),
    .pc_i(id_pc_i),
    .inst_i(id_inst_i),

    .reg1_i(rdata_1),
    .reg2_i(rdata_2),

    .inst_o(id_inst_o),
    .ex_waddr_i(ex_waddr_o),
    .ex_wdata_i(ex_wdata_o),
    .ex_wreg_i(ex_wreg_o),
    .mem_waddr_i(mem_waddr_o),
    .mem_wdata_i(mem_wdata_o),
    .mem_wreg_i(mem_wreg_o),

    .loadop_flg_i(id_prev_loadop_flg_i),
    .in_delayslot_i(in_delayslot_i),

    .reg1_addr_o(raddr_1),
    .reg2_addr_o(raddr_2),
    .reg1_read_o(re1),
    .reg2_read_o(re2),

    .opcode_o(id_opcode_o),
    .reg1_o(id_reg1_o),
    .reg2_o(id_reg2_o),
    .waddr_o(id_waddr_o),
    .wreg_o(id_wreg_o),
    .in_delayslot_o(id_in_delayslot_o),
    .link_addr_o(id_link_addr_o),
    .next_in_delayslot_o(id_next_in_delayslot_o),
    .branch_addr_o(id_branch_addr_o),
    .branch_flg_o(id_branch_flg_o),

    .loadop_flg_o(id_loadop_flg_o),
    .stallreq_o(id_stall)
);

id_ex id_ex0(
    .clk(clk),
    .rst(rst),
    .id_inst(id_inst_o),

    .id_opcode(id_opcode_o),
    .id_reg1(id_reg1_o),
    .id_reg2(id_reg2_o),
    .id_waddr(id_waddr_o),
    .id_wreg(id_wreg_o),
    .id_in_delayslot(id_in_delayslot_o),
    .id_link_addr(id_link_addr_o),
    .next_in_delayslot_i(id_next_in_delayslot_o),
    .id_loadop_flg(id_loadop_flg_o),
    .stall_i(stall),

    .ex_inst(ex_inst_i),

    .ex_opcode(ex_opcode_i),
    .ex_reg1(ex_reg1_i),
    .ex_reg2(ex_reg2_i),
    .ex_waddr(ex_waddr_i),
    .ex_wreg(ex_wreg_i),
    .ex_in_delayslot(ex_in_delayslot_i),
    .ex_link_addr(ex_link_addr_i),
    .prev_loadop_flg(id_prev_loadop_flg_i),
    .in_delayslot_o(in_delayslot_i)
);

ex ex0(
    .rst(rst),
    .inst_i(ex_inst_i),

    .opcode_i(ex_opcode_i),
    .reg1_i(ex_reg1_i),
    .reg2_i(ex_reg2_i),
    .waddr_i(ex_waddr_i),
    .wreg_i(ex_wreg_i),

    .hi_i(ex_hi_i),
    .lo_i(ex_lo_i),
    .hi_mem_i(mem_hi_o),
    .lo_mem_i(mem_lo_o),
    .wspreg_mem_i(mem_wspreg_o),
    .hi_wb_i(wb_hi_i),
    .lo_wb_i(wb_lo_i),
    .wspreg_wb_i(wb_wspreg_i),
    .hilo_temp_i(ex_hilo_i),
    .madd_stat_i(ex_madd_stat_i),
    .in_delayslot_i(ex_in_delayslot_i),
    .link_addr_i(ex_link_addr_i),
    .div_stat_i(to_ex_div_stat),
    .tmp_rem_i(to_ex_tmp_rem),
    .tmp_quo_i(to_ex_tmp_quo),
    .shift_cnt_i(to_ex_shift_cnt),
    .cp0_i(ex_cp0_data_i),

    .mem_wcp0(mem_wcp0_o),
    .mem_cp0_waddr(mem_cp0_waddr_o),
    .mem_cp0_wdata(mem_cp0_wdata_o),
    .wb_wcp0(wb_wcp0_i),
    .wb_cp0_waddr(wb_cp0_waddr_i),
    .wb_cp0_wdata(wb_cp0_wdata_i),

    .hi_o(ex_hi_o),
    .lo_o(ex_lo_o),
    .wspreg_o(ex_wspreg_o),

    .opcode_o(ex_opcode_o),
    .reg2_o(ex_reg2_o),
    .wdata_o(ex_wdata_o),
    .waddr_o(ex_waddr_o),
    .wreg_o(ex_wreg_o),
    .ram_addr_o(ex_ram_addr_o),
    .madd_stat_o(ex_madd_stat_o),
    .hilo_temp_o(ex_hilo_o),
    .div_stat_o(from_ex_div_stat),
    .tmp_rem_o(from_ex_tmp_rem),
    .tmp_quo_o(from_ex_tmp_quo),
    .shift_cnt_o(from_ex_shift_cnt),
    .cp0_raddr_o(ex_cp0_raddr_o),
    .wcp0_o(ex_wcp0_o),
    .cp0_waddr_o(ex_cp0_waddr_o),
    .cp0_wdata_o(ex_cp0_wdata_o),

    .stallreq_o(ex_stall)
);
ex_mem ex_mem0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),

    .ex_opcode(ex_opcode_o),
    .ex_reg2(ex_reg2_o),
    .ex_wdata(ex_wdata_o),
    .ex_waddr(ex_waddr_o),
    .ex_wreg(ex_wreg_o),
    .ex_ram_addr(ex_ram_addr_o),
    .ex_hi(ex_hi_o),
    .ex_lo(ex_lo_o),
    .ex_wspreg(ex_wspreg_o),
    .tmp_hilo_i(ex_hilo_o),
    .madd_stat_i(ex_madd_stat_o),
    .div_stat_i(from_ex_div_stat),
    .tmp_rem_i(from_ex_tmp_rem),
    .tmp_quo_i(from_ex_tmp_quo),
    .shift_cnt_i(from_ex_shift_cnt),
    .ex_wcp0(ex_wcp0_o),
    .ex_cp0_waddr(ex_cp0_waddr_o),
    .ex_cp0_wdata(ex_cp0_wdata_o),

    .mem_opcode(mem_opcode_i),
    .mem_reg2(mem_reg2_i),
    .wdata_o(mem_wdata_i),
    .waddr_o(mem_waddr_i),
    .wreg_o(mem_wreg_i),
    .mem_ram_addr(mem_ram_addr_i),
    .mem_hi(mem_hi_i),
    .mem_lo(mem_lo_i),
    .mem_wspreg(mem_wspreg_i),
    .tmp_hilo_o(ex_hilo_i),
    .madd_stat_o(ex_madd_stat_i),
    .div_stat_o(to_ex_div_stat),
    .tmp_rem_o(to_ex_tmp_rem),
    .tmp_quo_o(to_ex_tmp_quo),
    .shift_cnt_o(to_ex_shift_cnt),
    .mem_wcp0(mem_wcp0_i),
    .mem_cp0_waddr(mem_cp0_waddr_i),
    .mem_cp0_wdata(mem_cp0_wdata_i)
);
mem mem0(
    .rst(rst),

    .opcode_i(mem_opcode_i),
    .reg2_i(mem_reg2_i),
    .waddr_i(mem_waddr_i),
    .wdata_i(mem_wdata_i),
    .wreg_i(mem_wreg_i),
    .ram_addr_i(mem_ram_addr_i),
    .hi_i(mem_hi_i),
    .lo_i(mem_lo_i),
    .wspreg_i(mem_wspreg_i),

    .ram_i(ram_i),

    .atomicreg_i(areg_atomicdata_i),
    .wb_watomicreg(wb_watomicreg_i),
    .wb_atomicreg_wdata_i(wb_atomicreg_wdata_i),
    .wcp0_i(mem_wcp0_i),
    .cp0_waddr_i(mem_cp0_waddr_i),
    .cp0_wdata_i(mem_cp0_wdata_i),

    .waddr_o(mem_waddr_o),
    .wdata_o(mem_wdata_o),
    .wreg_o(mem_wreg_o),
    .hi_o(mem_hi_o),
    .lo_o(mem_lo_o),
    .wspreg_o(mem_wspreg_o),

    .wram_o(ram_we_o),
    .ram_ce_o(ram_ce_o),
    .ram_addr_o(ram_addr_o),
    .ram_vldbyte_o(ram_vldbyte_o),
    .ram_data_o(ram_data_o),

    .watomicreg_o(mem_watomicreg_o),
    .atomicreg_wdata_o(mem_atomicreg_wdata_o),
    .wcp0_o(mem_wcp0_o),
    .cp0_waddr_o(mem_cp0_waddr_o),
    .cp0_wdata_o(mem_cp0_wdata_o)
);
mem_wb mem_wb0(
    .clk(clk),
    .rst(rst),
    .stall_i(stall),
    .mem_wdata(mem_wdata_o),
    .mem_waddr(mem_waddr_o),
    .mem_wreg(mem_wreg_o),
    .mem_hi(mem_hi_o),
    .mem_lo(mem_lo_o),
    .mem_wspreg(mem_wspreg_o),
    .mem_watomicreg(mem_watomicreg_o),
    .mem_atomicreg_wdata(mem_atomicreg_wdata_o),
    .mem_wcp0(mem_wcp0_o),
    .mem_cp0_waddr(mem_cp0_waddr_o),
    .mem_cp0_wdata(mem_cp0_wdata_o),

    .wb_waddr(wb_waddr_i),
    .wb_wdata(wb_wdata_i),
    .wb_wreg(wb_we_i),
    .wb_hi(wb_hi_i),
    .wb_lo(wb_lo_i),
    .wb_wspreg(wb_wspreg_i),

    .wb_watomicreg(wb_watomicreg_i),
    .wb_atomicreg_wdata(wb_atomicreg_wdata_i),

    .wb_wcp0(wb_wcp0_i),
    .wb_cp0_waddr(wb_cp0_waddr_i),
    .wb_cp0_wdata(wb_cp0_wdata_i)
);
reg_spcl reg_spcl0(
    .clk(clk),
    .rst(rst),

    .hi_i(wb_hi_i),
    .lo_i(wb_lo_i),
    .wspreg(wb_wspreg_i),

    .hi_o(ex_hi_i),
    .lo_o(ex_lo_i)
);
reg_atomic reg_atomic0(
    .clk(clk),
    .rst(rst),

    .exc_flg_i(1'b0),
    .we_i(wb_watomicreg_i),
    .atomicbit_i(wb_atomicreg_wdata_i),

    .atomicbit_o(areg_atomicdata_i)
);
cp0 cp0(
    .clk(clk),
    .rst(rst),

    .raddr_i(ex_cp0_raddr_o),
    .we_i(wb_wcp0_i),
    .waddr_i(wb_cp0_waddr_i),
    .wdata_i(wb_cp0_wdata_i),
    .int_flg_i(int_flg_i),

    .data_o(ex_cp0_data_i),
    .timer_int_flg_o(timer_int_flg_o)
);
ctrl ctrl0(
    .rst(rst),
    .id_stall_i(id_stall),
    .ex_stall_i(ex_stall),
    .stall_o(stall)
);
endmodule