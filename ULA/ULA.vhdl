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
