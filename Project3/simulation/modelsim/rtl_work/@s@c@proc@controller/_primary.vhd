library verilog;
use verilog.vl_types.all;
entity SCProcController is
    port(
        opcode          : in     vl_logic_vector(7 downto 0);
        aluControl      : out    vl_logic_vector(7 downto 0);
        memtoReg        : out    vl_logic;
        memWrite        : out    vl_logic;
        branch          : out    vl_logic;
        jal             : out    vl_logic;
        alusrc          : out    vl_logic;
        regWrite        : out    vl_logic
    );
end SCProcController;
