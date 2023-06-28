library ieee;
use ieee.std_logic_1164.all;

entity DetectorNZ is
    datain : in std_logic(7 downto 0);
    NZ : out std_logic(1 downto 0);
end entity;
architecture Detector of DetectorNZ is
    NZ(1) <= '1' when datain(7) = '1';
    NZ(0) <= '1' when datain = "00000000";
end architecture;