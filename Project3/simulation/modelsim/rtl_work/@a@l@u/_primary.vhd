library verilog;
use verilog.vl_types.all;
entity ALU is
    generic(
        BIT_WIDTH       : integer := 32
    );
    port(
        dIn1            : in     vl_logic_vector;
        dIn2            : in     vl_logic_vector;
        op1             : in     vl_logic_vector(3 downto 0);
        op2             : in     vl_logic_vector(3 downto 0);
        dOut            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BIT_WIDTH : constant is 1;
end ALU;
