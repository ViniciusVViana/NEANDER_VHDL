entity pl_and_4 is
    port(
        c_in0 : in std_logic_vector(7 downto 0);
        c_in1 : in std_logic_vector(7 downto 0);
        sand : out bit
    );
end pl_and_4;

architecture comportamento of pl_and_4 is
begin
    sand <= c_in0 and c_in1;
end comportamento;
