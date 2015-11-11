`timescale 1ns / 1ps

module ProcTest;

    reg clk, reset;
    reg[9:0] switches;
    reg[3:0] keys;
    wire[9:0] ledr;
    wire[7:0] ledg;
    wire[6:0] hex0, hex1, hex2, hex3;

    reg[31:0] prevMemOut;

    integer i, counter;

    always #10 clk = ~clk;

    Project2 CPU(
        .clk    (clk),
        .reset  (reset),
        .SW     (switches),
        .KEY    (keys),
        .LEDR   (ledr),
        .LEDG   (ledg),
        .HEX0   (hex0),
        .HEX1   (hex1),
        .HEX2   (hex2),
        .HEX3   (hex3),
        .CLOCK_50(clk)
    );

    initial begin
        keys = 0;
        switches = 0;
        prevMemOut = 0;

        // Initialize instruction data
        for(i=0; i<256; i=i+1) begin
            CPU.instMemory.data[i] = 32'b0;
        end

        // Initialize data data
        for(i=0; i<2048; i=i+1) begin
            CPU.dataMemory.data[i] = 32'b0;
        end

        // initialize Register File
        for(i=0; i<16; i=i+1) begin
            CPU.dprf.regs[i] = 32'b0;
        end

        CPU.dprf.regs[1] = 10;
        CPU.dprf.regs[2] = 20;

        // Load instructions into instruction data
        $readmemh("../instructions.txt", CPU.instMemory.data);

        counter = 0;
        clk = 0;
        reset = 1;

        $display("time\t clk  reset");
        $monitor("%g\t   %b    %b", $time, clk, reset);
        #50
        reset = 0;

    end

    always@(posedge clk) begin
        if(counter == 200)    // stop after 5 cycles
            $stop;

        $display("cycle = %d", counter);

        // print PC
        $display("PC    = %h", CPU.pcOut[13:2]);
        $display("instr = %h", CPU.instMemory.data[CPU.pcOut[13:2]]);

        // print Registers
        $display("Stage 1");
        $display("memWrite        :          %d", CPU.memWrite);
        $display("KEY             :         %d", CPU.KEY);
        $display("SW              :       %d", CPU.SW);
        $display("aluOut          : %d", CPU.aluOut);
        $display("sr2Out          : %d", CPU.sr2Out);
        $display("instWord[31:28] :         %d", CPU.instWord[31:28]);
        $display("memtoReg        :          %d", CPU.memtoReg);
        $display("regWrite        :          %d", CPU.regWrite);
        $display("jal             :          %d", CPU.jal);
        $display("branch          :          %d", CPU.branch);
        $display("fwr1Out         : %d", CPU.fwr1Out);
        $display("aluMuxOut         : %d", CPU.aluMuxOut);
        $display();
        $display("Registers");
        $display("A0=%d, T0=%d, S2 =%d, GP=%d", CPU.dprf.regs[0], CPU.dprf.regs[4], CPU.dprf.regs[8], CPU.dprf.regs[12]);
        $display("A1=%d, T1=%d, R9 =%d, FP=%d", CPU.dprf.regs[1], CPU.dprf.regs[5], CPU.dprf.regs[9], CPU.dprf.regs[13]);
        $display("A2=%d, S0=%d, R10=%d, SP=%d", CPU.dprf.regs[2], CPU.dprf.regs[6], CPU.dprf.regs[10], CPU.dprf.regs[14]);
        $display("A3=%d, S1=%d, R11=%d, RA=%d", CPU.dprf.regs[3], CPU.dprf.regs[7], CPU.dprf.regs[11], CPU.dprf.regs[15]);
        $display();
        $display("Stage 2");
        $display("dataMuxOut      : %d", CPU.dataMuxOut);
        $display("memWrite        :          %d", CPU.buff_memWrite);
        $display("KEY             :         %d", CPU.buff_KEY);
        $display("SW              :       %d", CPU.buff_SW);
        $display("aluOut          : %d", CPU.buff_aluOut);
        $display("sr2Out          : %d", CPU.buff_sr2Out);
        $display("instWord[31:28] :         %d", CPU.buff_instWord);
        $display("memtoReg        :          %d", CPU.buff_memtoReg);
        $display("regWrite        :          %d", CPU.buff_regWrite);
        $display("jal             :          %d", CPU.buff_jal);


        // print Data Memory
        $display();
        $display("Data Memory");
        $display("DMEM[%d]=%d", prevMemOut, CPU.dataMemory.data[prevMemOut]);
        $display("DMEM[%d]=%d", CPU.buff_aluOut, CPU.memDataOut);

        prevMemOut <= CPU.buff_aluOut;
        // $display("Data data: 0x00 =%d", {CPU.dataMemory.data[3] , CPU.dataMemory.data[2] , CPU.dataMemory.data[1] , CPU.dataMemory.data[0] });
        // $display("Data data: 0x04 =%d", {CPU.dataMemory.data[7] , CPU.dataMemory.data[6] , CPU.dataMemory.data[5] , CPU.dataMemory.data[4] });
        // $display("Data data: 0x08 =%d", {CPU.dataMemory.data[11], CPU.dataMemory.data[10], CPU.dataMemory.data[9] , CPU.dataMemory.data[8] });
        // $display("Data data: 0x0c =%d", {CPU.dataMemory.data[15], CPU.dataMemory.data[14], CPU.dataMemory.data[13], CPU.dataMemory.data[12]});
        // $display("Data data: 0x10 =%d", {CPU.dataMemory.data[19], CPU.dataMemory.data[18], CPU.dataMemory.data[17], CPU.dataMemory.data[16]});
        // $display("Data data: 0x14 =%d", {CPU.dataMemory.data[23], CPU.dataMemory.data[22], CPU.dataMemory.data[21], CPU.dataMemory.data[20]});
        // $display("Data data: 0x18 =%d", {CPU.dataMemory.data[27], CPU.dataMemory.data[26], CPU.dataMemory.data[25], CPU.dataMemory.data[24]});
        // $display("Data data: 0x1c =%d", {CPU.dataMemory.data[31], CPU.dataMemory.data[30], CPU.dataMemory.data[29], CPU.dataMemory.data[28]});

        $display("--------------------------------------------------------------");
        $display("\n");


        counter = counter + 1;
    end


endmodule
