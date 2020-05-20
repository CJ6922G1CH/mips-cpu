`include "defines.vh"

module cp0(

    input wire clk,
    input wire rst,


    input wire we_i,
    input wire[4:0] waddr_i,
    input wire[4:0] raddr_i,
    input wire[`RegDataBus] wdata_i,

    input wire[5:0] int_flg_i,

    output reg[`RegDataBus] data_o,
    output reg[`RegDataBus] count_o,
    output reg[`RegDataBus] compare_o,
    output reg[`RegDataBus] status_o,
    output reg[`RegDataBus] cause_o,
    output reg[`RegDataBus] epc_o,
    output reg[`RegDataBus] config_o,
    output reg[`RegDataBus] prid_o,

    output reg timer_int_flg_o
);

    always @(posedge clk) begin
        if(rst == 1'b1) begin
            count_o <= `Zero;
            compare_o <= `Zero;
            //status CU == 0001，indicates the existence of coprocessor CP0
            status_o <= 32'b00010000000000000000000000000000;
            cause_o <= `Zero;
            epc_o <= `Zero;
            //config BE ==1: Big-Endian
            config_o <= 32'b00000000000000001000000000000000;
            //ID of processor
            prid_o <= 32'b00000000010011000000000100000010;
            timer_int_flg_o <= 1'b0;
        end else begin
            count_o <= count_o + 1;
            cause_o[15:10] <= int_flg_i;

            if ((compare_o != `Zero) && (count_o == compare_o)) begin
                timer_int_flg_o <= 1'b1;
            end

            if (we_i == 1'b1) begin
                case (waddr_i)
                    5'b01001: begin
                        count_o <= wdata_i;
                    end
                    5'b01011: begin
                        compare_o <= wdata_i;
                        timer_int_flg_o <= 1'b0;
                    end
                    5'b01100: begin
                        status_o <= wdata_i;
                    end
                    5'b01110: begin
                        epc_o <= wdata_i;
                    end
                    5'b01101: begin
                        cause_o[9:8] <= wdata_i[9:8];
                        cause_o[23] <= wdata_i[23];
                        cause_o[22] <= wdata_i[22];
                    end
                endcase
            end


        end    //if
    end      //always

    always @(*) begin
        if (rst == 1'b1) begin
            data_o <= `Zero;
        end else begin
            case (raddr_i)
                5'b01001: begin       //COUNT
                    data_o <= count_o ;
                end
                5'b01011: begin       //COMPARE
                    data_o <= compare_o ;
                end
                5'b01100: begin        //STATUS
                    data_o <= status_o ;
                end
                5'b01101: begin        //CAUSE
                    data_o <= cause_o ;
                end
                5'b01110: begin         //EPC
                    data_o <= epc_o ;
                end
                5'b01111: begin         //PRId
                    data_o <= prid_o ;
                end
                5'b10000: begin         //CONFIG
                    data_o <= config_o ;
                end
                default: begin

                end
            endcase
        end
    end
endmodule