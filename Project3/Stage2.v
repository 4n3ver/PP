module Stage2(regWrEn, ledr, ledg, hex0, hex1, hex2, hex3, regWrData, regWrIndex,
    clk, sw, key, opcode, memDataIn, regDataIn, memAddr, regIndex);
    parameter ADDR_KEY             = 32'hF0000010;
    parameter ADDR_SW              = 32'hF0000014;
    parameter ADDR_HEX             = 32'hF0000000;
    parameter ADDR_LEDR            = 32'hF0000004;
    parameter ADDR_LEDG            = 32'hF0000008;

    parameter REG_INDEX_BIT_WIDTH      = 4;
    parameter DMEM_ADDR_BIT_WIDTH      = 30;
    parameter DMEM_DATA_BIT_WIDTH      = 32;

    input clk;
    input [9:0] sw;
    input [3:0] key;
    input [3:0] opcode;
    input [DMEM_DATA_BIT_WIDTH - 1:0] memDataIn, regDataIn;
    input [DMEM_ADDR_BIT_WIDTH - 1:0] memAddr;
    input [REG_INDEX_BIT_WIDTH - 1:0] regIndex;

    output regWrEn;
    output [9:0] ledr;
    output [7:0] ledg;
    output [6:0] hex0, hex1, hex2, hex3;
    output [DMEM_DATA_BIT_WIDTH - 1:0] regWrData;
    output [REG_INDEX_BIT_WIDTH - 1:0] regWrIndex;

    wire memWrEn;
    assign regWrEn = (opcode[3] || !opcode[2])  ? 1'b1 : 1'b0;  // ALU-I, LW, CMP-I, JAL, ALU-R, CMP-R
    assign memWrEn = (opcode[2] && opcode[0])   ? 1'b1 : 1'b0;  // SW

    // Create DataMemory
    DataMemory #(IMEM_INIT_FILE, DMEM_ADDR_BIT_WIDTH, DMEM_DATA_BIT_WIDTH,
        TRUE_DMEM_ADDR_BIT_WIDTH) dataMemory (
        .clk(clk),
        .wrtEn(memWrEn),
        .addr(memAddr),
        .dIn(memDataIn),
        .sw(sw),
        .key(key),
        .ledr(ledr),
        .ledg(ledg),
        .hex(hex),
        .dOut(memDataOut)
    );

endmodule