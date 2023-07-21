-- ULA 8 bits Grande
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY moduloULA IS
    PORT (
        interface_barramento : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ULA_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        AC_rw : IN STD_LOGIC;
        interface_flags : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_nrw : IN STD_LOGIC;
        rst, clk : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE ULA_arch OF moduloULA IS

    COMPONENT micro_ULA IS
        PORT (
            x_ULA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            y_ULA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            op_ULA : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            s_ac2flags : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --Saida NZ
            s_ula2ac : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );

    END COMPONENT;

    COMPONENT Flags IS
        PORT (
            F_datain : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw : IN STD_LOGIC;
            F_dataout : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT AC IS
        PORT (
            AC_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw : IN STD_LOGIC;
            AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_pr : STD_LOGIC;
    SIGNAL s_ac2flags : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_ac2ula, s_ula2ac : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    s_pr <= '1';

    u_ac : AC PORT MAP(s_ula2ac, clk, s_pr, rst, AC_rw, s_ac2ula);
    
    u_ula : micro_ULA PORT MAP(s_ac2ula, interface_barramento, ULA_op, s_ac2flags, s_ula2ac);
    u_flags : Flags PORT MAP(s_ac2flags, clk, s_pr, rst, AC_rw, interface_flags);
    interface_barramento <= s_ac2ula WHEN mem_nrw = '1' ELSE (OTHERS => 'Z');

END ULA_arch; -- ULA_arch

-- Registrador Flags
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Flags IS
    PORT (
        F_datain : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        F_dataout : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch_flags OF Flags IS
    COMPONENT regCarga1bit IS
        PORT (
            d : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw : IN STD_LOGIC;
            s : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    -- instâncias de regCarga1bit (8 vezes)
        u_reg1bit0 : regCarga1bit PORT MAP(F_datain(0), clk, cl, pr, nrw, F_dataout(0));
        u_reg1bit1 : regCarga1bit PORT MAP(F_datain(1), clk, pr, cl, nrw, F_dataout(1));

END ARCHITECTURE;
-- Registrador AC
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY AC IS
    PORT (
        AC_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch_ac OF AC IS
    COMPONENT regCarga1bit IS
        PORT (
            d : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw : IN STD_LOGIC;
            s : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    -- instâncias de regCarga1bit (8 vezes)
    loop_reg : FOR i IN 0 TO 7 GENERATE
        u_reg1bit : regCarga1bit PORT MAP(AC_datain(i), clk, pr, cl, nrw, AC_dataout(i));
    END GENERATE loop_reg;
END ARCHITECTURE;

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
entity Detectornz is
    port(
        datain : in std_logic_vector(7 downto 0);
        NZ : out std_logic_vector(1 downto 0)
    );
end entity;
architecture Detector of Detectornz is
    begin
        NZ(1) <= '1' when datain(7) = '1' else '0';
        NZ(0) <= '1' when datain = "00000000" else '0';
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
    u_somador1 : somador_1bit port map(canal_a => x_sum(0), canal_b => y_sum(0), canal_cin => canal_cinn, canal_cout => aux(0), saida_soma => s_add(0));
    
    loop_sum: FOR i IN 1 TO 7 GENERATE
        u_sum2 : somador_1bit port map(canal_a => x_sum(i), canal_b => y_sum(i), canal_cin => aux(i-1), canal_cout => aux(i), saida_soma => s_add(i));
    END GENERATE loop_sum;
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
