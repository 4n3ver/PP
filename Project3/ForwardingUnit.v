module ForwardingUnit(reg0, reg1, regRd0, regRd1, regFw, regIndex0, regIndex1,
                        regIndexWr);
    input [31:0]    regRd0, regRd1,
                    regFw;
    input [3:0]     regIndex0, regIndex1, regIndexWr;

    output [31:0]   reg0, reg1;

    assign reg0 = regIndex0 == regIndexWr ? regFw : regRd0;
    assign reg1 = regIndex1 == regIndexWr ? regFw : regRd1;

endmodule // ForwardingUnit