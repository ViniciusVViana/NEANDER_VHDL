library ieee;
use ieee.std_logic_1164.all;

entity tb_neander is
end entity;

architecture monark of tb_neander is

    -- Constants
    constant CLK_PERIOD : time := 20 ns;

    -- Component

    component NEANDER is
        port(
            Ncl, Nclck : in std_logic
        );
    end component;

    signal cl : std_logic;
    signal clk : std_logic := '1';

begin
    u_neander : neander port map(cl, clk);
    p_clock : process
    begin
        clk <= not clk;
        wait for CLK_PERIOD/2;
    end process;

    p_neander : process
    begin
        cl <= '0';
        wait for CLK_PERIOD;

        cl <= '1';
        wait;
    end process;
end architecture;