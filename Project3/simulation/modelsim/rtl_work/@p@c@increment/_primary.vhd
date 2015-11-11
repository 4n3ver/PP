library verilog;
use verilog.vl_types.all;
entity PCIncrement is
    port(
        dIn             : in     vl_logic_vector(31 downto 0);
        dOut            : out    vl_logic_vector(31 downto 0)
    );
end PCIncrement;
