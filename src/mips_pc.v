`include "defines.vh"
module mips_pc(
    input wire clk,
    input wire rst
);

wire[`AddrBusWidth] cpu_rom_addr;
wire[`DataBusWidth] rom_cpu_data;
wire rom_ce;

wire cpu_ram_we;
wire cpu_ram_ce;
wire[`RegDataBus] cpu_ram_addr;
wire[3:0] cpu_ram_vldbyte;
wire[`RegDataBus] cpu_ram_data;

wire[`RegDataBus] ram_cpu_data;

wire timer_int_flg;
wire[5:0] int_flg;

assign int_flg = {5'b00000, timer_int_flg};

mips_cpu mips_cpu0(
    // input wire clk,
    // input wire rst,
    // input wire[`RegDataBus] data_i,
    .clk(clk),
    .rst(rst),
    .rom_i(rom_cpu_data),
    // input wire[`RegDataBus] ram_i,
    .ram_i(ram_cpu_data),
    // output wire[`RegDataBus] addr_o,
    // output wire ce_o
    .rom_addr_o(cpu_rom_addr),
    .rom_ce_o(rom_ce),
    .int_flg_i(int_flg),

    .ram_addr_o(cpu_ram_addr),
    .ram_data_o(cpu_ram_data),
    .ram_ce_o(cpu_ram_ce),
    .ram_we_o(cpu_ram_we),
    .ram_vldbyte_o(cpu_ram_vldbyte),
    .timer_int_flg_o(timer_int_flg)
);
rom rom0(
    .ce(rom_ce),
    .addr(cpu_rom_addr),
    .inst(rom_cpu_data)
);
ram ram0(
    .clk(clk),
    .ce(cpu_ram_ce),
    .we_i(cpu_ram_we),
    .addr_i(cpu_ram_addr),
    .vldbyte_i(cpu_ram_vldbyte),
    .data_i(cpu_ram_data),
    .data_o(ram_cpu_data)
);
endmodule