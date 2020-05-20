`include "defines.vh"
module rom(
    input wire ce,
    input wire[`AddrBusWidth] addr,
    output reg[`DataBusWidth] inst
);

reg[`DataBusWidth] inst_mem[16383:0];
initial $readmemh("./rom.data", inst_mem);

always @ (*) begin
    if(ce == 1'b0) begin
        inst <= `Zero;
    end else begin
        inst <= inst_mem[addr[16:2]];
    end
end
endmodule
