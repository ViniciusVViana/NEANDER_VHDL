library IEEE;
use IEEE.std_logic_1164.all;

entity decode is
    port(
        instr_in_decode: in std_logic_vector(7 downto 0);
        instr_out_decode: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of decode is
begin
    instr_out_decode <= "10000000000" when instr_in_decode = "00000000" else (others  => 'Z');
    instr_out_decode <= "01000000000" when instr_in_decode = "00010000" else (others  => 'Z');
    instr_out_decode <= "00100000000" when instr_in_decode = "00100000" else (others  => 'Z');    
    instr_out_decode <= "00010000000" when instr_in_decode = "00110000" else (others  => 'Z');    
    instr_out_decode <= "00001000000" when instr_in_decode = "01000000" else (others  => 'Z');
    instr_out_decode <= "00000100000" when instr_in_decode = "01010000" else (others  => 'Z');
    instr_out_decode <= "00000010000" when instr_in_decode = "01100000" else (others  => 'Z');    
    instr_out_decode <= "00000001000" when instr_in_decode = "10000000" else (others  => 'Z'); 
    instr_out_decode <= "00000000100" when instr_in_decode = "10010000" else (others  => 'Z');
    instr_out_decode <= "00000000010" when instr_in_decode = "10100000" else (others  => 'Z');    
    instr_out_decode <= "00000000001" when instr_in_decode = "11110000" else (others  => 'Z'); 
end arch ; -- arch