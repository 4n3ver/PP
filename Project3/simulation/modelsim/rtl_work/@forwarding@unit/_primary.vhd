library verilog;
use verilog.vl_types.all;
entity ForwardingUnit is
    port(
        reg0            : out    vl_logic_vector(31 downto 0);
        reg1            : out    vl_logic_vector(31 downto 0);
        regRd0          : in     vl_logic_vector(31 downto 0);
        regRd1          : in     vl_logic_vector(31 downto 0);
        regFw           : in     vl_logic_vector(31 downto 0);
        regIndex0       : in     vl_logic_vector(3 downto 0);
        regIndex1       : in     vl_logic_vector(3 downto 0);
        regIndexWr      : in     vl_logic_vector(3 downto 0);
        wrEn            : in     vl_logic
    );
end ForwardingUnit;
