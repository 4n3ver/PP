library verilog;
use verilog.vl_types.all;
entity RegisterFile is
    generic(
        BIT_WIDTH       : integer := 32;
        REG_WIDTH       : integer := 4;
        REG_SIZE        : vl_notype
    );
    port(
        clk             : in     vl_logic;
        wrtEn           : in     vl_logic;
        dIn             : in     vl_logic_vector;
        dr              : in     vl_logic_vector;
        sr1             : in     vl_logic_vector;
        sr2             : in     vl_logic_vector;
        sr1Out          : out    vl_logic_vector;
        sr2Out          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of REG_SIZE : constant is 3;
end RegisterFile;
