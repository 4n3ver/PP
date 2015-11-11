module Project2(/*clk, reset,*/ SW,KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,CLOCK_50);
  //input clk, reset;

  input  [9:0] SW;
  input  [3:0] KEY;
  input  CLOCK_50;
  output [9:0] LEDR;
  output [7:0] LEDG;
  output [6:0] HEX0,HEX1,HEX2,HEX3;

  parameter ADDR_KEY             = 32'hF0000010;
  parameter ADDR_SW              = 32'hF0000014;
  parameter ADDR_HEX             = 32'hF0000000;
  parameter ADDR_LEDR            = 32'hF0000004;
  parameter ADDR_LEDG            = 32'hF0000008;


  parameter DBITS                  = 32;
  parameter INST_BIT_WIDTH         = 32;
  parameter START_PC               = 32'h40;
  parameter REG_INDEX_BIT_WIDTH    = 4;

  parameter IMEM_INIT_FILE         = "Sorter2.mif";

  parameter IMEM_ADDR_BIT_WIDTH      = 11;
  parameter IMEM_DATA_BIT_WIDTH      = INST_BIT_WIDTH;
  parameter TRUE_DMEM_ADDR_BIT_WIDTH = 11;
  parameter DMEM_ADDR_BIT_WIDTH      = INST_BIT_WIDTH - 2;
  parameter DMEM_DATA_BIT_WIDTH      = INST_BIT_WIDTH;
  parameter IMEM_PC_BITS_HI          = IMEM_ADDR_BIT_WIDTH + 2;
  parameter IMEM_PC_BITS_LO          = 2;

 // PLL, clock generation, and reset generation
  wire clk, lock, reset;
  PLL PLL_inst (.inclk0 (CLOCK_50),.c0 (clk),.locked (lock));
  //assign clk = ~KEY[0];
  assign reset = ~lock;

  // Wires..
  wire pcWrtEn = 1'b1;
  wire memtoReg, memWrite, branch, jal, alusrc, regWrite;
  wire [7:0] aluControl, ledg;
  wire [9:0] ledr;
  wire [15:0] hex;
  wire [IMEM_DATA_BIT_WIDTH - 1 : 0] instWord;
  wire [DBITS - 1 : 0] pcIn, pcOut, incrementedPC, pcAdderOut, aluOut, signExtImm,
      dataMuxOut, sr1Out, sr2Out, aluMuxOut, memDataOut;

  // Should use this value instead of value from register
  wire [31:0] fwr1Out, fwr2Out;

  // PIPE BUFF
  reg buff_memtoReg, buff_memWrite, buff_regWrite, buff_jal;
  reg [3:0] buff_KEY;
  reg [9:0] buff_SW;
  reg [DBITS - 1 : 0] buff_incrementedPC, buff_aluOut, buff_sr2Out;
  reg [REG_INDEX_BIT_WIDTH - 1 : 0] buff_instWord;

  // Create PCMUX
  Mux3to1 #(DBITS) pcMux (
    .sel({jal, (branch & aluOut[0])}),
    .dInSrc1(incrementedPC),
    .dInSrc2(pcAdderOut),
    .dInSrc3(aluOut),
    .dOut(pcIn)
  );

  // This PC instantiation is your starting point
  Register #(DBITS, START_PC) pc (
    .clk(clk),
    .reset(reset),
    .wrtEn(pcWrtEn),
    .dataIn(pcIn),
    .dataOut(pcOut)
  );

  // Create PC Increment (PC + 4)
  PCIncrement pcIncrement (
    .dIn(pcOut),
    .dOut(incrementedPC)
  );

  // Create Instruction Memory
  InstMemory #(IMEM_INIT_FILE, IMEM_ADDR_BIT_WIDTH, IMEM_DATA_BIT_WIDTH) instMemory (
    .addr(pcOut[IMEM_PC_BITS_HI - 1 : IMEM_PC_BITS_LO]),
    .dataOut(instWord)
  );

  // Create Controller(SCProcController)
  SCProcController controller (
    .opcode({instWord[3:0],instWord[7:4]}),
    .aluControl(aluControl),
    .memtoReg(memtoReg),
    .memWrite(memWrite),
    .branch(branch),
    .jal(jal),
    .alusrc(alusrc),
    .regWrite(regWrite)
  );

  // Create SignExtension
  SignExtension #(16, DBITS) signExtension (
    .dIn(instWord[23:8]),
    .dOut(signExtImm)
  );

  // Create pcAdder (incrementedPC + signExtImm << 2)
  PCAdder pcAdder (
    .dIn1(incrementedPC),
    .dIn2(signExtImm),
    .dOut(pcAdderOut)
  );

  // Create Dual Ported Register File
  RegisterFile #(DBITS, REG_INDEX_BIT_WIDTH) dprf (
    .clk(clk),
    .wrtEn(buff_regWrite),
    .dIn(dataMuxOut),
    .dr(buff_instWord),
    .sr1(memWrite | branch ? instWord[31:28] : instWord[27:24]),
    .sr2(memWrite | branch ? instWord[27:24] : instWord[23:20]),
    .sr1Out(sr1Out),
    .sr2Out(sr2Out)
  );

  // Create forwarding unit
  ForwardingUnit raw (
    .reg0(fwr1Out),
    .reg1(fwr2Out),
    .regRd0(sr1Out),
    .regRd1(sr2Out),
    .regFw(dataMuxOut),
    .regIndex0(memWrite | branch ? instWord[31:28] : instWord[27:24]),
    .regIndex1(memWrite | branch ? instWord[27:24] : instWord[23:20]),
    .regIndexWr(buff_instWord),
    .wrEn(buff_regWrite)
  );

  // Create AluMux (Between DPRF and ALU)
  Mux2to1 #(DBITS) aluMux (
    .sel(alusrc),
    .dInSrc1(fwr2Out),
    .dInSrc2(signExtImm),
    .dOut(aluMuxOut)
  );

  // Create ALU
  ALU alu (
    .dIn1(fwr1Out),
    .dIn2(aluMuxOut),
    .op1(aluControl[7:4]),
    .op2(aluControl[3:0]),
    .dOut(aluOut)
  );

  // Stage 2
  always @(posedge clk) begin
    if (reset) begin
      {
        buff_jal, buff_memtoReg, buff_memWrite, buff_KEY, buff_SW, buff_aluOut, buff_sr2Out, buff_regWrite,
        buff_incrementedPC, buff_instWord
      } <= 0;
    end else begin
      buff_jal        <= jal;
      buff_memtoReg   <= memtoReg;
      buff_memWrite   <= memWrite;
      buff_KEY        <= KEY;
      buff_SW         <= SW;
      buff_aluOut     <= aluOut;
      buff_sr2Out     <= fwr2Out;
      buff_regWrite   <= regWrite;
      buff_incrementedPC <= incrementedPC;
      buff_instWord   <= instWord[31:28];
    end
  end

  // Create DataMemory
  DataMemory #(IMEM_INIT_FILE, DMEM_ADDR_BIT_WIDTH, DMEM_DATA_BIT_WIDTH,
    TRUE_DMEM_ADDR_BIT_WIDTH) dataMemory (
    .clk(clk),
    .wrtEn(buff_memWrite),
    .addr(buff_aluOut),
    .dIn(buff_sr2Out),
    .sw(buff_SW),
    .key(buff_KEY),
    .ledr(ledr),
    .ledg(ledg),
    .hex(hex),
    .dOut(memDataOut)
  );

  // Create dataMux to RegFile
  Mux3to1 #(DBITS) dataMux (
    .sel({buff_jal, buff_memtoReg}),
    .dInSrc1(buff_aluOut),
    .dInSrc2(memDataOut),
    .dInSrc3(buff_incrementedPC),
    .dOut(dataMuxOut)
  );


  // Create SevenSeg for HEX3
  SevenSeg sevenSeg3 (
    .dIn(hex[15:12]),
    // .dIn(pcOut[15:12]),
    .dOut(HEX3)
  );

  // Create SevenSeg for HEX2
  SevenSeg sevenSeg2 (
    .dIn(hex[11:8]),
    // .dIn(pcOut[11:8]),
    .dOut(HEX2)
  );

  // Create SevenSeg for HEX1
  SevenSeg sevenSeg1 (
    .dIn(hex[7:4]),
    // .dIn(pcOut[7:4]),
    .dOut(HEX1)
  );

  // Create SevenSeg for HEX0
  SevenSeg sevenSeg0 (
    .dIn(hex[3:0]),
    // .dIn(pcOut[3:0]),
    .dOut(HEX0)
  );

  assign LEDR = ledr;
  assign LEDG = ledg;

endmodule
