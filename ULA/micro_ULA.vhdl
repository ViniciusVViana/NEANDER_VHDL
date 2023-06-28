-- tb_ULA
library ieee;
use ieee.std_logic_1164.all;
entity tb is 
end entity;

architecture arch of tb is
    
component micro_ULA is
    port(
        x_ULA: in std_logic_vector(7 downto 0);
        y_ULA: in std_logic_vector(7 downto 0);
        op_ULA: in std_logic_vector(2 downto 0);
        s_ac2flags: out std_logic_vector(1 downto 0); --Saida NZ
        s_ula2ac: out std_logic_vector(7 downto 0)
    );

end component;
    signal x,y,s: std_logic_vector(7 downto 0);
    signal snz: std_logic_vector(1 downto 0);
    signal op: std_logic_vector(2 downto 0);
begin
    u_test: micro_ULA port map(x,y,op,snz,s);

    u_main: process 
    begin
        x <= x"01";
        y <= x"04";
        op <= "000";
        wait for 20 ns;
        x <= x"01";
        y <= x"04";
        op <= "001";
        wait for 20 ns;
        x <= x"01";
        y <= x"04";
        op <= "010";
        wait for 20 ns;
        x <= x"01";
        y <= x"04";
        op <= "011";
        wait for 20 ns;
        x <= x"01";
        y <= x"04";
        op <= "100";
        wait for 20 ns;

    
    wait;
    end process;
    
    
    
end architecture arch;

--Micro_ALU

library ieee;
use ieee.std_logic_1164.all;

entity micro_ULA is
    port(
        x_ULA: in std_logic_vector(7 downto 0);
        y_ULA: in std_logic_vector(7 downto 0);
        op_ULA: in std_logic_vector(2 downto 0);
        s_ac2flags: out std_logic_vector(1 downto 0); --Saida NZ
        s_ula2ac: out std_logic_vector(7 downto 0)
    );

end micro_ULA;


architecture arch_ULA of micro_ULA is

    -- Detector NZ
    component DetectorNZ is
        port(
            datain : in std_logic_vector(7 downto 0);
            NZ : out std_logic_vector(1 downto 0)
           );
    end component;

    --Somador 8 bits
    component somador_8bits is

        port(
    
            x_sum : in std_logic_vector(7 downto 0);
            y_sum : in std_logic_vector(7 downto 0);
            canal_cinn : in std_logic;
            canal_coutt : out std_logic;
            s_add : out std_logic_vector(7 downto 0)
    
        );
    
    end component;

    -- AND
    component and_8bits is
        port(
            x_and : in std_logic_vector(7 downto 0);
            y_and : in std_logic_vector(7 downto 0);
            s_and : out std_logic_vector(7 downto 0)
        );
    end component;

    -- OR 
    component or_8bits is
        port(
            x_or: in std_logic_vector(7 downto 0);
            y_or : in std_logic_vector(7 downto 0);
            s_or : out std_logic_vector(7 downto 0)
        );
    end component;

    -- NOT
    component inversor_8bits is
        port(
            x_not : in std_logic_vector(7 downto 0);
            s_not : out std_logic_vector(7 downto 0) 
        );
    end component;
    signal aux_out: std_logic;
    signal s_resultado: std_logic_vector(7 downto 0);
    signal snot, sor, sand, sadd:std_logic_vector(7 downto 0);
begin


    u_not: inversor_8bits port map(x_ULA,snot);
    u_or: or_8bits port map(x_ULA, y_ULA, sor);
    u_and: and_8bits port map(x_ULA, y_ULA, sand);
    u_sum: somador_8bits port map(x_ULA,y_ULA,'0',aux_out,sadd);
    
    s_resultado <=  y_ULA when op_ULA = "000" else
                    sadd when op_ULA = "001" else
                    sor when op_ULA = "010" else
                    sand when op_ULA = "011" else
                    snot when op_ULA = "100";

    u_NZ: DetectorNZ port map(s_resultado, s_ac2flags);
    
    s_ula2ac <= s_resultado;
    
end architecture arch_ULA;
-- Detector NZ

library ieee;
use ieee.std_logic_1164.all;

entity DetectorNZ is
   port(
    datain : in std_logic_vector(7 downto 0);
    NZ : out std_logic_vector(1 downto 0)
   );
end entity;

architecture Detector of DetectorNZ is
begin
    NZ(1) <= '1' when datain(7) = '1';
    NZ(0) <= '1' when datain = "00000000";
end architecture;

-- Somador 8 Bits

library ieee;
use ieee.std_logic_1164.all;

entity somador_8bits is

    port(

        x_sum : in std_logic_vector(7 downto 0);
        y_sum : in std_logic_vector(7 downto 0);
        canal_cinn : in std_logic;
        canal_coutt : out std_logic;
        s_add : out std_logic_vector(7 downto 0)

    );

end somador_8bits;
   
architecture arch_somador of somador_8bits is

    component somador_1bit
        
        port(

            canal_a : in std_logic;
            canal_b : in std_logic;
            canal_cin : in std_logic;
            canal_cout : out std_logic;
            saida_soma : out std_logic

        );

    end component;
        
    signal aux : std_logic_vector(7 downto 0);

begin
    loop_sum: for i in 0 to 7 generate
        u_somador1 : somador_1bit port map(canal_a => x_sum(i), canal_b => y_sum(i), canal_cin => canal_cinn, canal_cout => aux(i), saida_soma => s_add(i));
    end generate loop_sum;
end architecture;

--Somador 1 bit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador_1bit is

    port(

        canal_a : in std_logic;
        canal_b : in std_logic;
        canal_cin : in std_logic;
        canal_cout : out std_logic;
        saida_soma : out std_logic

    );

end entity;

architecture somando_1bit of somador_1bit is
    
begin

    saida_soma <= (canal_a xor canal_b) xor canal_cin;
    canal_cout <= (canal_a and canal_b) or (canal_a and canal_cin) or (canal_b and canal_cin);

end architecture;

-- AND 8 bits
library ieee;
use ieee.std_logic_1164.all;
    entity and_8bits is
        port(
            x_and : in std_logic_vector(7 downto 0);
            y_and : in std_logic_vector(7 downto 0);
            s_and : out std_logic_vector(7 downto 0)
        );
    end and_8bits;

architecture comportamento of and_8bits is
begin
    s_and <= x_and and y_and;
end comportamento;

-- OR 8 bits
library ieee;
use ieee.std_logic_1164.all;
entity or_8bits is
    port(
        x_or: in std_logic_vector(7 downto 0);
        y_or : in std_logic_vector(7 downto 0);
        s_or : out std_logic_vector(7 downto 0)
    );
end or_8bits;

architecture comportamento of or_8bits is
begin
    s_or <= x_or or y_or;
end comportamento;

-- NOT 8 bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity inversor_8bits is
    port(
        x_not : in std_logic_vector(7 downto 0);
        s_not : out std_logic_vector(7 downto 0) 
    );
end entity;
architecture invertendo of inversor_8bits is
begin
    s_not <= not(x_not);
end architecture;
