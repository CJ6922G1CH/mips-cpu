`include "defines.vh"
`define RamAddrBus 31:0
`define RamDataBus 31:0
`define DataMemNum 63
`define DataMemBus 6
`define ByteWidth 7:0
module ram(
    input wire clk,
    input wire ce,

    input wire we_i,
    input wire[`RamAddrBus] addr_i,
    input wire[3:0] vldbyte_i,
    input wire[`RamDataBus] data_i,

    output reg[`RamDataBus] data_o
);
    reg[`ByteWidth] data_mem0[0:`DataMemNum-1];
    reg[`ByteWidth] data_mem1[0:`DataMemNum-1];
    reg[`ByteWidth] data_mem2[0:`DataMemNum-1];
    reg[`ByteWidth] data_mem3[0:`DataMemNum-1];

    always @ (posedge clk) begin
        if (ce == 1'b0) begin
            //data_o <= 'Zero;
        end else if(we_i == 1'b1) begin
            if (vldbyte_i[3] == 1'b1) begin
                data_mem3[addr_i[`DataMemBus+1:2]] <= data_i[31:24];
            end
            if (vldbyte_i[2] == 1'b1) begin
                data_mem2[addr_i[`DataMemBus+1:2]] <= data_i[23:16];
            end
            if (vldbyte_i[1] == 1'b1) begin
                data_mem1[addr_i[`DataMemBus+1:2]] <= data_i[15:8];
            end
            if (vldbyte_i[0] == 1'b1) begin
                data_mem0[addr_i[`DataMemBus+1:2]] <= data_i[7:0];
            end
        end
    end

    always @ (*) begin
        if (ce == 1'b0) begin
            data_o <= `Zero;
        end else if (we_i == 1'b0) begin
            data_o <= {data_mem3[addr_i[`DataMemBus+1:2]],
                       data_mem2[addr_i[`DataMemBus+1:2]],
                       data_mem1[addr_i[`DataMemBus+1:2]],
                       data_mem0[addr_i[`DataMemBus+1:2]]};
        end else begin
            data_o <= `Zero;
        end
    end

endmodule