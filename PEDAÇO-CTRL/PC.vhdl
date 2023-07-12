--------------PROGRAME COUNTER-------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY PC IS
    PORT (
        barr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        nbarrinc : IN STD_LOGIC;
        nrw, cl, clk : IN STD_LOGIC;
        endout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch OF PC IS
    COMPONENT somador_8bits IS
    PORT (
        x_sum : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        y_sum : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        canal_cinn : IN STD_LOGIC;
        canal_coutt : OUT STD_LOGIC;
        s_add : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END COMPONENT;  
    COMPONENT regPC IS
    PORT (
        AC_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END COMPONENT;
    SIGNAL sadd, s_mux2pc, s_PCatual, aux : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL auxcout : STD_LOGIC;
BEGIN
    --

    u_add : somador_8bits PORT MAP("00000001", s_PCatual, '0', auxcout, sadd);

    s_mux2pc <= sadd when nbarrinc = '1' else barr when nbarrinc = '0';

    u_regPC : regPC PORT MAP(s_mux2pc, clk, '1', cl, nrw, endout);

END ARCHITECTURE;
    -----------REGISTRADOR DE 8 BITS-----------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY regPC IS
    PORT (
        AC_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch_ac OF regPC IS
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
-- Reg Carga 1 Bit
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY regCarga1bit IS
    PORT (
        d : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        s : OUT STD_LOGIC
    );
END ENTITY;
ARCHITECTURE reg1bit OF regCarga1bit IS
    COMPONENT ffd IS
        PORT (
            d : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            q, nq : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT mux2x1 IS
        PORT (
            c0 : IN STD_LOGIC;
            c1 : IN STD_LOGIC;
            sel : IN STD_LOGIC;
            Z : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL datain, dataout, s_mux, damn : STD_LOGIC;

BEGIN
    -- envio de dataout para saída s
    s <= dataout;

    -- multiplexador
    u_mux2x1 : mux2x1 PORT MAP(dataout, d, nrw, s_mux);
    -- nrw = 1 -> entrada principal de interface d
    -- nrw = 0 -> saida temporária dataout (mantém estado)
    -- instância do reg
    u_reg : ffd PORT MAP(s_mux, clk, pr, cl, dataout, damn);
END ARCHITECTURE;

--  Multiplexador de 2 canais com 1 bits por canal
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux2x1 IS
    PORT (
        c0 : IN STD_LOGIC;
        c1 : IN STD_LOGIC;
        sel : IN STD_LOGIC;
        Z : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE comutar OF mux2x1 IS
BEGIN
    -- atribuição condicional
    z <= c0 WHEN sel = '0' ELSE
        c1 WHEN sel = '1' ELSE
        'Z';

END ARCHITECTURE;

-- FFD

LIBRARY ieee;
USE ieee.std_logic_1164.ALL; -- std_logic para detectar erros

ENTITY ffd IS
    PORT (
        d : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        q, nq : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE latch OF ffd IS
    COMPONENT ffjk IS
        PORT (
            j, k : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            q, nq : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL sq : STD_LOGIC := '0'; -- opcional -> valor inicial
    SIGNAL snq : STD_LOGIC := '1';
    SIGNAL nj : STD_LOGIC;
BEGIN

    u_td : ffjk PORT MAP(d, nj, clk, pr, cl, q, nq);
    nj <= NOT(d);

END ARCHITECTURE latch;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL; -- std_logic para detectar erros

ENTITY ffjk IS
    PORT (
        j, k : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        q, nq : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE latch OF ffjk IS
    SIGNAL sq : STD_LOGIC := '0'; -- opcional -> valor inicial
    SIGNAL snq : STD_LOGIC := '1';
BEGIN

    q <= sq;
    nq <= snq;

    u_ff : PROCESS (clk, pr, cl)
    BEGIN
        -- pr = 0 e cl = 0 -> Desconhecido
        IF (pr = '0') AND (cl = '0') THEN
            sq <= 'X';
            snq <= 'X';
            -- prioridade para cl
        ELSIF (pr = '1') AND (cl = '0') THEN
            sq <= '0';
            snq <= '1';
            -- tratamento de pr
        ELSIF (pr = '0') AND (cl = '1') THEN
            sq <= '1';
            snq <= '0';
            -- pr e cl desativados
        ELSIF (pr = '1') AND (cl = '1') THEN
            IF falling_edge(clk) THEN
                -- jk = 00 -> mantém estado
                IF (j = '0') AND (k = '0') THEN
                    sq <= sq;
                    snq <= snq;
                    -- jk = 01 -> q = 0
                ELSIF (j = '0') AND (k = '1') THEN
                    sq <= '0';
                    snq <= '1';
                    -- jk = 01 -> q = 1
                ELSIF (j = '1') AND (k = '0') THEN
                    sq <= '1';
                    snq <= '0';
                    -- jk = 11 -> q = !q
                ELSIF (j = '1') AND (k = '1') THEN
                    sq <= NOT(sq);
                    snq <= NOT(snq);
                    -- jk = ?? -> falha
                ELSE
                    sq <= 'U';
                    snq <= 'U';
                END IF;
            END IF;
        ELSE
            sq <= 'X';
            snq <= 'X';
        END IF;
    END PROCESS;

END ARCHITECTURE;
---------------------Somador 8 Bits----------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY somador_8bits IS
    PORT (
        x_sum : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        y_sum : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        canal_cinn : IN STD_LOGIC;
        canal_coutt : OUT STD_LOGIC;
        s_add : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END somador_8bits;
ARCHITECTURE arch_somador OF somador_8bits IS
    COMPONENT somador_1bit
        PORT (
            canal_a : IN STD_LOGIC;
            canal_b : IN STD_LOGIC;
            canal_cin : IN STD_LOGIC;
            canal_cout : OUT STD_LOGIC;
            saida_soma : OUT STD_LOGIC
        );
    END COMPONENT;
    SIGNAL aux : STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
    u_somador1 : somador_1bit PORT MAP(canal_a => x_sum(0), canal_b => y_sum(0), canal_cin => canal_cinn, canal_cout => aux(0), saida_soma => s_add(0));
    loop_sum : FOR i IN 1 TO 7 GENERATE
        u_sum2 : somador_1bit PORT MAP(canal_a => x_sum(i), canal_b => y_sum(i), canal_cin => aux(i - 1), canal_cout => aux(i), saida_soma => s_add(i));
    END GENERATE loop_sum;
END ARCHITECTURE;
------Somador 1 bit-----------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
ENTITY somador_1bit IS
    PORT (
        canal_a : IN STD_LOGIC;
        canal_b : IN STD_LOGIC;
        canal_cin : IN STD_LOGIC;
        canal_cout : OUT STD_LOGIC;
        saida_soma : OUT STD_LOGIC
    );
END ENTITY;
ARCHITECTURE somando_1bit OF somador_1bit IS
BEGIN
    saida_soma <= (canal_a XOR canal_b) XOR canal_cin;
    canal_cout <= (canal_a AND canal_b) OR (canal_a AND canal_cin) OR (canal_b AND canal_cin);
END ARCHITECTURE;