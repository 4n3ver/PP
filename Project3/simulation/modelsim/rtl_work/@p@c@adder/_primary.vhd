library verilog;
use verilog.vl_types.all;
entity PCAdder is
    port(
        dIn1            : in     vl_logic_vector(31 downto 0);
        dIn2            : in     vl_logic_vector(31 downto 0);
        dOut            : out    vl_logic_vector(31 downto 0)
    );
end PCAdder;
