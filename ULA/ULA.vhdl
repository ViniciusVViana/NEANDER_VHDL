--Testbanch
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY testbanch IS
END ENTITY;

ARCHITECTURE testbanch_arch OF testbanch IS
    constant CLK_PERIOD : time := 20 ns;

    COMPONENT ULA IS
        PORT (
            interface_barramento : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            ULA_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            AC_rw : IN STD_LOGIC;
            interface_flags : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_nrw : IN STD_LOGIC;
            rst, clk : IN STD_LOGIC
        );
    END COMPONENT;

    SIGNAL s_interface_barramento : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_ULA_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_AC_rw : STD_LOGIC;
    SIGNAL s_interface_flags : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_mem_nrw : STD_LOGIC;
    SIGNAL s_rst : STD_LOGIC;
    SIGNAL s_clk : STD_LOGIC := '1';

BEGIN
    u_ULA : ULA PORT MAP(s_interface_barramento, s_ULA_op, s_AC_rw, s_interface_flags, s_mem_nrw, s_rst, s_clk);

    u_teste: process
    begin
        s_rst <= '0';
        wait for CLK_PERIOD;
        s_rst <= '1';
        s_interface_barramento <= "00000000";
        s_ULA_op <= "000";
        s_AC_rw <= '0';
        s_mem_nrw <= '0';
        wait for CLK_PERIOD;
        
        s_interface_barramento <= "00000001";
        s_ULA_op <= "001";
        s_AC_rw <= '1';
        s_mem_nrw <= '1';
        wait for CLK_PERIOD;

        s_interface_barramento <= "00000010";
        s_ULA_op <= "010";
        s_AC_rw <= '0';
        s_mem_nrw <= '0';
        wait for CLK_PERIOD;

        wait;
    end process;


    u_clk : process
    begin
        s_clk <= not(s_clk);
        wait for CLK_PERIOD/2;
    end process;
END ARCHITECTURE;

-- ULA 8 bits Grande
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY ULA IS
    PORT (
        interface_barramento : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ULA_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        AC_rw : IN STD_LOGIC;
        interface_flags : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_nrw : IN STD_LOGIC;
        rst, clk : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE ULA_arch OF ULA IS

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
            F_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw : IN STD_LOGIC;
            F_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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

    SIGNAL s_pr, s_clk, s_rst, s_nrw : STD_LOGIC;
    SIGNAL s_ac2flags : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_ULA_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_ac2ula, s_ula2ac, barramento, s_interface_flags : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    s_pr <= '1';
    barramento <= s_ac2ula WHEN mem_nrw = '1' ELSE
        (OTHERS => 'Z');

    u_ula : micro_ULA PORT MAP(s_ac2ula, barramento, s_ULA_op, s_ac2flags, s_ula2ac);
    u_flags : Flags PORT MAP(s_ac2flags, s_clk, s_pr, s_rst, s_nrw, s_interface_flags);
    u_ac : AC PORT MAP(s_ula2ac, s_clk, s_pr, s_rst, s_nrw, barramento);

END ULA_arch; -- ULA_arch

-- Registrador Flags
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY Flags IS
    PORT (
        F_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        F_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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
    loop_reg : FOR i IN 0 TO 1 GENERATE
        u_reg1bit : regCarga1bit PORT MAP(F_datain(i), clk, pr, cl, nrw, F_dataout(i));
    END GENERATE loop_reg;
END ARCHITECTURE;
-- Registrador AC
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY AC IS
    PORT (
        AC_dataout : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
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