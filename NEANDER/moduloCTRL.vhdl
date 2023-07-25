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
    --------------------DECODIFICADOR------------------
    component decode is
        port(
            instr_in_decode: in std_logic_vector(7 downto 0);
            instr_out_decode: out std_logic_vector(10 downto 0)
        );
    end component;

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
            NZ: in std_logic_vector(1 downto 0);
            ciclo: in std_logic_vector(2 downto 0);
            JMPN_out: out std_logic_vector(10 downto 0)
        );
    end component;
    ------------------------JMPZ------------------------
    component JMPZ_UC is
        port(
            NZ: in std_logic_vector(1 downto 0);
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

    signal sNOP, sSTA, sLDA, sADD, sOR_UC, sAND_UC, sNOT_UC, sJMP_UC, sJMPN_UC, sJMPZ_UC, sHLT, s_instr_out_decode : std_logic_vector(10 downto 0);
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

    
    barr_ctrl <= sNOP       when dec2uc = "10000000000" else (others  => 'Z');
    barr_ctrl <= sSTA       when dec2uc = "01000000000" else (others  => 'Z');
    barr_ctrl <= sLDA       when dec2uc = "00100000000" else (others  => 'Z');  
    barr_ctrl <= sADD       when dec2uc = "00010000000" else (others  => 'Z'); 
    barr_ctrl <= sOR_UC     when dec2uc = "00001000000" else (others  => 'Z');  
    barr_ctrl <= sAND_UC    when dec2uc = "00000100000" else (others  => 'Z');
    barr_ctrl <= sNOT_UC    when dec2uc = "00000010000" else (others  => 'Z');
    barr_ctrl <= sJMP_UC    when dec2uc = "00000001000" else (others  => 'Z');
    barr_ctrl <= sJMPN_UC   when dec2uc = "00000000100" else (others  => 'Z');
    barr_ctrl <= sJMPZ_UC   when dec2uc = "00000000010" else (others  => 'Z');
    barr_ctrl <= sHLT       when dec2uc = "00000000001" else (others  => 'Z');

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

    NOP_out(10) <= (not(ciclo(0)) and not(ciclo(1))) or (not(ciclo(0)) and ciclo(1) and not(ciclo(2))); 
    NOP_out(9) <= (not(ciclo(0)) and not(ciclo(1))) or (not(ciclo(0)) and ciclo(1) and not(ciclo(2)));
    NOP_out(8 downto 6) <= "000";
    NOP_out(5) <= not(ciclo(0)) and not(ciclo(1)) and ciclo(2);
    NOP_out(4) <= '0';
    NOP_out(3) <= '0';
    NOP_out(2) <= not(ciclo(0)) and not(ciclo(1)) and not(ciclo(2));
    NOP_out(1) <= not(ciclo(0)) and not(ciclo(1)) and ciclo(2);
    NOP_out(0) <= not(ciclo(0)) and ciclo(1) and ciclo(2);

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

    STA_out(10) <= not(ciclo(0)) or (not(ciclo(2)) and ciclo(0)) or (not(ciclo(1)) and ciclo(2) and ciclo(0));
    STA_out(9) <= not(ciclo(0)) or (not(ciclo(2)) and ciclo(0));
    STA_out(8 downto 6) <= "000";
    STA_out(5) <= (not(ciclo(0)) and not(ciclo(1)) and ciclo(2)) or (ciclo(0) and not(ciclo(1)) and not(ciclo(2)));
    STA_out(4) <= '0';
    STA_out(3) <= ciclo(0) and ciclo(1) and not(ciclo(2));
    STA_out(2) <= (not(ciclo(0) or ciclo(1) or ciclo(2))) or (not(ciclo(1)) and ciclo(0) and ciclo(2)) or (not(ciclo(0)) and ciclo(1) and ciclo(2));
    STA_out(1) <= (not(ciclo(0)) and not(ciclo(1)) and ciclo(2)) or (ciclo(0) and not(ciclo(1)) and not(ciclo(2)));
    STA_out(0) <= not(ciclo(0)) and ciclo(1) and not(ciclo(2));

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

    NOT_out(10) <= (not(ciclo(0)) and not(ciclo(1)) )or (not(ciclo(0)) and ciclo(1) and not(ciclo(2)));
    NOT_out(9) <= (not(ciclo(0)) and not(ciclo(1)) )or (not(ciclo(0)) and ciclo(1) and not(ciclo(2)));
    NOT_out(8) <= (not(ciclo(0)) and not(ciclo(1)) )or (not(ciclo(0)) and ciclo(1) and not(ciclo(2)));
    NOT_out(7 downto 6) <= "00";
    NOT_out(5) <= not(ciclo(0)) and not(ciclo(1)) and ciclo(2);
    NOT_out(4) <= '0';
    NOT_out(3) <= '0';
    NOT_out(2) <= not(ciclo(0)) and not(ciclo(1)) and not(ciclo(2));
    NOT_out(1) <= not(ciclo(0)) and not(ciclo(1)) and ciclo(2);
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

    JMP_out(10) <= not(ciclo(0)) or (ciclo(0) and not(ciclo(1)));
    JMP_out(9) <= (not(ciclo(0))) or (not(ciclo(1)) and not(ciclo(2)) and ciclo(0));
    JMP_out(8 downto 6) <= "000";
    JMP_out(5) <= not(ciclo(0)) and not(ciclo(1)) and ciclo(2);
    JMP_out(4) <= '0';
    JMP_out(3) <= '0';
    JMP_out(2) <= (not(ciclo(0) or ciclo(1) or ciclo(2))) or (not(ciclo(0)) and ciclo(1) and ciclo(2));
    JMP_out(1) <= (not(ciclo(0)) and not(ciclo(1)) and ciclo(2)) or (not(ciclo(1)) and not(ciclo(2)) and ciclo(0));
    JMP_out(0) <= not(ciclo(0)) and ciclo(1) and not(ciclo(2));

end arch; -- arch

--JMPN
library IEEE;
use IEEE.std_logic_1164.all;
entity JMPN_UC is
    port(
        NZ: in std_logic_vector(1 downto 0);
        ciclo: in std_logic_vector(2 downto 0);
        JMPN_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of JMPN_UC is 
    component JMP_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            JMP_out: out std_logic_vector(10 downto 0)
        );
    end component;
    signal sJMPN : std_logic_vector(10 downto 0);
begin
    u_JMPN : JMP_UC  port map(ciclo, sJMPN);
    
    JMPN_out <= sJMPN when NZ = "10" else "00000100000";    

end arch; -- arch

--JMPZ
library IEEE;
use IEEE.std_logic_1164.all;
entity JMPZ_UC is
    port(
        NZ: in std_logic_vector(1 downto 0);
        ciclo: in std_logic_vector(2 downto 0);
        JMPZ_out: out std_logic_vector(10 downto 0)
    );
end entity;

architecture arch of JMPZ_UC is 
    component JMP_UC is
        port(
            ciclo: in std_logic_vector(2 downto 0);
            JMP_out: out std_logic_vector(10 downto 0)
        );
    end component;
    signal sJPMZ : std_logic_vector(10 downto 0);
begin
    u_JMPZ : JMP_UC  port map(ciclo, sJPMZ);
    
    JMPZ_out <= sJPMZ when NZ = "01" else "00000100000";    
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
        port(
            j, k   : in std_logic;
            clock  : in std_logic;
            pr, cl : in std_logic;
            q, nq  : out std_logic
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
library ieee;
use ieee.std_logic_1164.all;

entity FFJK is

    port(
        j, k   : in std_logic;
        clock  : in std_logic;
        pr, cl : in std_logic;
        q, nq  : out std_logic
    );

end;

architecture FF of FFJK is

    signal s_snj , s_snk    : std_logic;
    signal s_sns , s_snr    : std_logic;
    signal s_sns2 , s_snr2  : std_logic;
    signal s_eloS , s_eloR  : std_logic;
    signal s_eloQ , s_elonQ : std_logic;
    signal s_nClock         : std_logic;

begin

    s_nClock <= not clock;

    --s_snj
    s_snj <= not(j and clock and s_elonQ);

    --s_snk
    s_snk <= not(k and clock and s_eloQ);

    --s_sns
    s_sns <= not(s_snj and pr and s_eloR);

    --s_snr
    s_snr <= not(s_snk and cl and s_eloS);

    --s_sns2
    s_sns2 <= s_sns nand s_nClock;

    --s_snr2
    s_snr2 <= s_snr nand s_nClock;

    --s_eloS
    s_eloS <= not(s_snj and pr and s_eloR);

    --s_eloR
    s_eloR <= not(s_snk and cl and s_eloS);

    --s_eloQ
    s_eloQ <= not(s_sns2 and s_elonQ and pr);

    --s_elonQ
    s_elonQ <= not(s_eloQ and s_snr2 and cl);

    --Q ~Q
    q <= not(s_sns2 and s_elonQ and pr);
    nq <= not(s_eloQ and s_snr2 and cl);

end architecture;