library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity moduloCTRL is
    port(
        interface_barramento : in std_logic_vector (7 downto 0);
        inNZ                 : std_logic_vector (1 downto 0);
        nrw, cl, clk         : in std_logic;
        barramento_ctrl      : out std_logic_vector (10 downto 0)
    );
end entity;

architecture controllah of moduloCTRL is -- Tô em todo lugar!
    component RI IS
    PORT (
        RI_datain  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk        : IN STD_LOGIC;
        pr, cl     : IN STD_LOGIC;
        nrw        : IN STD_LOGIC;
        RI_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END component;

    component decode is
        port(
            instr_in_decode  : in std_logic_vector(7 downto 0);
            instr_out_decode : out std_logic_vector(10 downto 0)
        );
    end component;

    component UC is
        port(
            dec2uc    : in std_logic_vector(10 downto 0);
            NZ        : in std_logic_vector(1 downto 0);
            rst, clk  : in std_logic;
            barr_ctrl : out std_logic_vector(10 downto 0)
        );
    end component;
        signal ri2dec : std_logic_vector(7 downto 0);
        signal dec2uc : std_logic_vector(10 downto 0);
        signal barr_ctrl_out : std_logic_vector(10 downto 0);
    begin

        uRI  : RI port map(interface_barramento, clk, '1', cl, nrw, ri2dec);
        uDEC : decode port map(ri2dec, dec2uc);
        uUC  : UC port map(dec2uc, inNZ, cl, clk, barr_ctrl_out);
        
        barramento_ctrl <= barr_ctrl_out;

end architecture;


------------------ Registrador RI--------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY RI IS
    PORT (
        RI_datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        nrw : IN STD_LOGIC;
        RI_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch_RI OF RI IS
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
        u_reg1bit : regCarga1bit PORT MAP(RI_datain(i), clk, pr, cl, nrw, RI_dataout(i));
    END GENERATE loop_reg;
END ARCHITECTURE;

------------------------UC------------------------------
-- Módulo UC
library IEEE;
use IEEE.std_logic_1164.all;

entity UC is
    port(
        dec2uc: in std_logic_vector(10 downto 0);
        NZ: in std_logic_vector(1 downto 0);
        rst, clk: in std_logic;
        barr_ctrl: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of UC is 

    ----------------------CONTADOR---------------------
    component CONTADOR is
        port(
            clk, reset : in std_logic;
            z : out std_logic_vector(2 downto 0)
        );
    end component;
    ------------------------NOP------------------------
    component  NOP is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            NOP_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------STA------------------------
    component STA is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            STA_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------LDA------------------------
    component LDA is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            LDA_out: out std_logic_vector(10 downto 0) 
        );
    end component;
    ------------------------ADD------------------------
    component ADD is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            ADD_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------OR------------------------
    component OR_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            OR_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------AND------------------------
    component AND_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            AND_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------NOT------------------------
    component NOT_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            NOT_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------JMP------------------------
    component JMP_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            JMP_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------JMPN------------------------
    component JMPN_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            JMPN_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------JMPZ------------------------
    component JMPZ_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            JMPZ_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------HLT------------------------
    component HLT is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            HLT_out: out std_logic_vector(10 downto 0)
        );
    end component;

    signal sNOP, sSTA, sLDA, sADD, sOR_UC, sAND_UC, sNOT_UC, sJMP_UC, sJMPN_UC, sJMPZ_UC, sHLT : std_logic_vector(10 downto 0);
    signal sCTD : std_logic_vector(2 downto 0);
begin

    uCONT    : CONTADOR port map(clk, rst, sCTD);
    uNOP     : NOP port map(sCTD, sNOP);
    uSTA     : STA port map(sCTD, sSTA);
    uLDA     : LDA port map(sCTD, sLDA);
    uADD     : ADD port map(sCTD, sADD);
    uOR_UC   : OR_UC port map(sCTD, sOR_UC);
    uAND_UC  : AND_UC port map(sCTD, sAND_UC);
    uNOT_UC  : NOT_UC port map(sCTD, sNOT_UC);
    uJMP_UC  : JMP_UC port map(sCTD, sJMP_UC);
    uJMPN_UC : JMPN_UC port map(NZ, sCTD, sJMPN_UC);
    uJMPZ_UC : JMPZ_UC port map(NZ, sCTD, sJMPZ_UC);
    uHLT     : HLT port map(sCTD, sHLT);

    barr_ctrl <= sNOP when dec2uc = "10000000000" else
    sSTA when dec2uc = "01000000000" else
    sLDA when dec2uc = "00100000000" else
    sADD when dec2uc = "00010000000" else
    sAND_UC when dec2uc = "00001000000" else
    sOR_UC when  dec2uc = "00000100000" else
    sNOT_UC when dec2uc = "00000010000" else
    sJMP_UC when dec2uc = "00000001000" else

    sJMP_UC when dec2uc = ("00000000100") and (NZ(1) = '1') else    
    sJMPN_UC  when dec2uc = ("00000000100") and (NZ(1) = '0') else 

    sJMP_UC when dec2uc = ("00000000010") and (NZ(0) = '1') else
    sJMPZ_UC when dec2uc = ("00000000010") and (NZ(0) = '0') else
    sHLT when dec2uc = "00000000001" else (others => 'Z');

end arch ; -- arch

------------------------DECODIFICADOR----------------------
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
    instr_out_decode <= "10000000000" when instr_in_decode="00000000" else 
              "01000000000" when instr_in_decode="00010000" else 
              "00100000000" when instr_in_decode="00100000" else 
              "00010000000" when instr_in_decode="00110000" else 
              "00001000000" when instr_in_decode="01000000" else 
              "00000100000" when instr_in_decode="01010000" else 
              "00000010000" when instr_in_decode="01100000" else 
              "00000001000" when instr_in_decode="10000000" else 
              "00000000100" when instr_in_decode="10010000" else 
              "00000000010" when instr_in_decode="10100000" else 
              "00000000001" when instr_in_decode="11110000" else
                (others => 'Z'); 
end arch ; -- arch

--NOP
library IEEE;
use IEEE.std_logic_1164.all;
entity NOP is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        NOP_out: out std_logic_vector(10 downto 0)
    );
end entity;
architecture arch of NOP is 
begin

    NOP_out(10) <= '1'; 
    NOP_out(9) <= '1';
    NOP_out(8 downto 6) <= "000";
    NOP_out(5) <= not(ciclo(2)) and not(ciclo(1)) and ciclo(0);
    NOP_out(4) <= '0';
    NOP_out(3) <= '0';
    NOP_out(2) <= not(ciclo(2)) and not(ciclo(1)) and not(ciclo(0));
    NOP_out(1) <= not(ciclo(2)) and not(ciclo(1)) and ciclo(0);
    NOP_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(2));

end arch; -- arch

--STA
library IEEE;
use IEEE.std_logic_1164.all;
entity STA is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        STA_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of STA is 
begin

    STA_out(10) <= '1';
    STA_out(9) <= not(ciclo(2)) or (ciclo(2) and not(ciclo(0)));
    STA_out(8 downto 6) <= "000";
    STA_out(5) <= not(ciclo(1)) and (ciclo(2) xor ciclo(0));
    STA_out(4) <= '0';
    STA_out(3) <= ciclo(2) and ciclo(1) and not(ciclo(0));
    STA_out(2) <= (ciclo(0) and (ciclo(2) xor ciclo(1))) or (not(ciclo(2)) and not(ciclo(1)) and not(ciclo(0)));
    STA_out(1) <= not ciclo(1) and (ciclo(2) xor ciclo(0)); --aaaaa
    STA_out(0) <= not ciclo(2) and ciclo(1) and not ciclo(0);

end arch; -- arch

--LDA
library IEEE;
use IEEE.std_logic_1164.all;
entity LDA is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        LDA_out: out std_logic_vector(10 downto 0) --
    );
end entity;

architecture arch of LDA is 
begin

    LDA_out(10) <= '1';
    LDA_out(9) <= not(ciclo(2)) or ciclo(1) or not(ciclo(0));
    LDA_out(8 downto 6) <= "000";
    LDA_out(5) <= not(ciclo(1)) and (ciclo(2) xor ciclo(0));
    LDA_out(4) <= ciclo(2) and ciclo(1) and ciclo(0);
    LDA_out(3) <= '0';
    LDA_out(2) <= (not(ciclo(1)) and (ciclo(2) xnor ciclo(0))) or (not(ciclo(2)) and ciclo(1) and ciclo(0));
    LDA_out(1) <= (ciclo(2) and not(ciclo(0))) or (not(ciclo(2)) and not(ciclo(1)) and ciclo(0));
    LDA_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0));

end arch; -- arch

--ADD
library IEEE;
use IEEE.std_logic_1164.all;
entity ADD is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        ADD_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of ADD is 
begin

    ADD_out(10) <= '1';
    ADD_out(9) <= not(ciclo(2)) or ciclo(1) or not(ciclo(0));
    ADD_out(8 downto 6) <= "001";
    ADD_out(5) <= not(ciclo(1)) and (ciclo(2) xor ciclo(0));
    ADD_out(4) <= ciclo(2) and ciclo(1) and ciclo(0);
    ADD_out(3) <= '0';
    ADD_out(2) <= (not(ciclo(1)) and (ciclo(2) xnor ciclo(0))) or (not(ciclo(2)) and ciclo(1) and ciclo(0));
    ADD_out(1) <= (ciclo(2) and not(ciclo(0))) or (not(ciclo(2)) and not(ciclo(1)) and ciclo(0));
    ADD_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0));

end arch; -- arch

--OR
library IEEE;
use IEEE.std_logic_1164.all;
entity OR_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        OR_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of OR_UC is 
begin

    OR_out(10) <= '1';
    OR_out(9) <= not(ciclo(2)) or ciclo(1) or not(ciclo(0));
    OR_out(8 downto 6) <= "010";
    OR_out(5) <= not(ciclo(1)) and (ciclo(2) xor ciclo(0));
    OR_out(4) <= ciclo(2) and ciclo(1) and ciclo(0);
    OR_out(3) <= '0';
    OR_out(2) <= (not(ciclo(1)) and (ciclo(2) xnor ciclo(0))) or (not(ciclo(2)) and ciclo(1) and ciclo(0));
    OR_out(1) <= (ciclo(2) and not(ciclo(0))) or (not(ciclo(2)) and not(ciclo(1)) and ciclo(0));
    OR_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0));

end arch; -- arch

--AND
library IEEE;
use IEEE.std_logic_1164.all;
entity AND_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        AND_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of AND_UC is 
begin

    AND_out(10) <= '1';
    AND_out(9) <= not(ciclo(2)) or ciclo(1) or not(ciclo(0));
    AND_out(8 downto 6) <= "011";
    AND_out(5) <= not(ciclo(1)) and (ciclo(2) xor ciclo(0));
    AND_out(4) <= ciclo(2) and ciclo(1) and ciclo(0);
    AND_out(3) <= '0';
    AND_out(2) <= (not(ciclo(1)) and (ciclo(2) xnor ciclo(0))) or (not(ciclo(2)) and ciclo(1) and ciclo(0));
    AND_out(1) <= (ciclo(2) and not(ciclo(0))) or (not(ciclo(2)) and not(ciclo(1)) and ciclo(0));
    AND_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0));

end arch; -- arch

--NOT
library IEEE;
use IEEE.std_logic_1164.all;
entity NOT_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        NOT_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of NOT_UC is 
begin

    NOT_out(10) <= '1';
    NOT_out(9) <= '1';
    NOT_out(8 downto 6) <= "100";
    NOT_out(5) <= not(ciclo(2)) and not(ciclo(1)) and ciclo(0);
    NOT_out(4) <= ciclo(2) and ciclo(1) and ciclo(0);
    NOT_out(3) <= '0';
    NOT_out(2) <= not(ciclo(2)) and not(ciclo(1)) and not(ciclo(0));
    NOT_out(1) <= not(ciclo(2)) and not(ciclo(1)) and ciclo(0);
    NOT_out(0) <= ciclo(1) and not(ciclo(0)) and not(ciclo(2));

end arch; -- arch

--JMP
library IEEE;
use IEEE.std_logic_1164.all;
entity JMP_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        JMP_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of JMP_UC is 
begin

    JMP_out(10) <= not(ciclo(2)) or (not(ciclo(1)) and not(ciclo(0)));
    JMP_out(9) <= '1';
    JMP_out(8 downto 6) <= "000";
    JMP_out(5) <=  not(ciclo(1)) and ciclo(0);
    JMP_out(4) <= '0';
    JMP_out(3) <= '0';
    JMP_out(2) <= not(ciclo(2)) and (ciclo(1) xnor ciclo(0));
    JMP_out(1) <= not(ciclo(1)) and (ciclo(2) xor ciclo(0));
    JMP_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0));

end arch; -- arch

--JMPN
library IEEE;
use IEEE.std_logic_1164.all;
entity JMPN_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        JMPN_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of JMPN_UC is 
   
begin
 
     JMPN_out(10) <= '1';
     JMPN_out(9) <= '1';
     JMPN_out(8 downto 6) <= "000";
     JMPN_out(5) <= not(ciclo(2)) and ciclo(0); 
     JMPN_out(4) <= '0';
     JMPN_out(3) <= '0';
     JMPN_out(2) <= not(ciclo(2)) and not(ciclo(1)) and not(ciclo(0)); 
     JMPN_out(1) <= not(ciclo(2)) and not(ciclo(1)) and ciclo(0); 
     JMPN_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0)); 

end arch; -- arch

--JMPZ
library IEEE;
use IEEE.std_logic_1164.all;
entity JMPZ_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        JMPZ_out: out std_logic_vector(10 downto 0)

    );
end entity;

architecture arch of JMPZ_UC is 

begin
    JMPZ_out(10) <= '1';
    JMPZ_out(9) <= '1';

    JMPZ_out(8 downto 6) <= "000";
    JMPZ_out(5) <= not(ciclo(2)) and ciclo(0);  
    JMPZ_out(4) <= '0';     
    JMPZ_out(3) <= '0'; 
    JMPZ_out(2) <= not(ciclo(2)) and not(ciclo(1)) and not(ciclo(0)); 
    JMPZ_out(1) <= not(ciclo(2)) and not(ciclo(1)) and ciclo(0); 
    JMPZ_out(0) <= not(ciclo(2)) and ciclo(1) and not(ciclo(0));
end arch; -- arch
--HLT
library IEEE;
use IEEE.std_logic_1164.all;
entity HLT is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        HLT_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of HLT is 
begin

    HLT_out <= "00000000000";

end arch; -- arch

--------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity CONTADOR is
    port(
        clk, reset : in std_logic;
        z : out std_logic_vector(2 downto 0)
    );
end entity;

architecture CONTAR of CONTADOR is
    component CTRL is
        port(
            Q : in std_logic_vector(2 downto 0);
            J : out std_logic_vector(2 downto 0);
            K : out std_logic_vector(2 downto 0)
        );
    end component;
    component FFJK is
        PORT (
        j, k : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        pr, cl : IN STD_LOGIC;
        q, nq : OUT STD_LOGIC
        );
    end component;

    signal sJ, sK, sQ, sNQ : std_logic_vector(2 downto 0);
    signal vcc : std_logic := '1';

begin
    u_CTRL: CTRL port map(sQ, sJ, sK);

    u_FFJK0 : FFJK port map(sJ(0), sK(0), clk, vcc, reset, sQ(0), sNQ(0));
    u_FFJK1 : FFJK port map(sJ(1), sK(1), clk, vcc, reset, sQ(1), sNQ(1));
    u_FFJK2 : FFJK port map(sJ(2), sK(2), clk, vcc, reset, sQ(2), sNQ(2));

    z <= sQ;
end architecture;
----------CRONTOLADORA------------
library ieee;
use ieee.std_logic_1164.all;

entity CTRL is
    port(
        Q : in std_logic_vector(2 downto 0);
        J : out std_logic_vector(2 downto 0);
        K : out std_logic_vector(2 downto 0)
    );
end entity;

architecture CONTROLAR of CTRL is
begin
    J(2) <= Q(1) and Q(0);
    J(1) <= Q(0);
    J(0) <= '1';

    K(2) <= Q(1) and Q(0);
    K(1) <= Q(0);
    K(0) <= '1';
end architecture;
----------------FFJK-------------------------
library IEEE;
use IEEE.std_logic_1164.all;

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
