`include "../src/defines.vh"
`timescale 1ns/1ps

module mips_cpu_tb();
reg CLOCK_50;
reg rst;

    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        rst = 1'b1;
        #100 rst= 1'b0;
        #500 $stop;
    end

    mips_pc mips_pc0(
		.clk(CLOCK_50),
		.rst(rst)	
	);

endmodule
