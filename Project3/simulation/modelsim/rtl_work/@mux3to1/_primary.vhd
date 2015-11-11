library verilog;
use verilog.vl_types.all;
entity Mux3to1 is
    generic(
        BIT_WIDTH       : integer := 32
    );
    port(
        sel             : in     vl_logic_vector(1 downto 0);
        dInSrc1         : in     vl_logic_vector;
        dInSrc2         : in     vl_logic_vector;
        dInSrc3         : in     vl_logic_vector;
        dOut            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BIT_WIDTH : constant is 1;
end Mux3to1;
