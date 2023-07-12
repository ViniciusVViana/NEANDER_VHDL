-- Módulo UC
library IEEE;
use IEEE.std_logic_1164.all;

entity UC is
    port(
        dec2uc: in std_logic_vector(11 downto 0);
        NZ: in std_logic_vector(1 downto 0);
        rst, clk: in std_logic;
        barr_ctrl: out std_logic_vector(11 downto 0)
    );
end entity;

architecture arch of UC is 
begin

end arch ; -- arch

--NOP
library IEEE;
use IEEE.std_logic_1164.all;
entity NOP is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        NOP_out: out std_logic_vector(10 downto 0)
    );
architecture arch of NOP is 
begin

end arch; -- arch

--STA
library IEEE;
use IEEE.std_logic_1164.all;
entity STA is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        STA_out: out std_logic_vector(10 downto 0)
    );
architecture arch of STA is 
begin

end arch; -- arch

--LDA
library IEEE;
use IEEE.std_logic_1164.all;
entity LDA is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        LDA_out: out std_logic_vector(10 downto 0)
    );
architecture arch of LDA is 
begin

end arch; -- arch

--ADD
library IEEE;
use IEEE.std_logic_1164.all;
entity ADD is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        ADD_out: out std_logic_vector(10 downto 0)
    );
architecture arch of ADD is 
begin

end arch; -- arch

--AND
library IEEE;
use IEEE.std_logic_1164.all;
entity AND_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        AND_out: out std_logic_vector(10 downto 0)
    );
architecture arch of AND_UC is 
begin

end arch; -- arch

--OR
library IEEE;
use IEEE.std_logic_1164.all;
entity OR_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        OR_out: out std_logic_vector(10 downto 0)
    );
architecture arch of OR_UC is 
begin

end arch; -- arch

--NOT
library IEEE;
use IEEE.std_logic_1164.all;
entity NOT_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        NOT_out: out std_logic_vector(10 downto 0)
    );
architecture arch of NOT_UC is 
begin

end arch; -- arch

--NOT
library IEEE;
use IEEE.std_logic_1164.all;
entity NOT_UC is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        NOT_out: out std_logic_vector(10 downto 0)
    );
architecture arch of NOT_UC is 
begin

end arch; -- arch

--JMPS
library IEEE;
use IEEE.std_logic_1164.all;
entity JMPS_UC is
    port(
        NZ: in std_logic_vector(1 downto 0);
        ciclo: in std_logic_vector(2 downto 0);
        JMPS_out: out std_logic_vector(10 downto 0)
    );
architecture arch of JMPS_UC is 
begin

end arch; -- arch

--HLT
library IEEE;
use IEEE.std_logic_1164.all;
entity HLT is
    port(
        ciclo: in std_logic_vector(2 downto 0);
        HLT_out: out std_logic_vector(10 downto 0)
    );
architecture arch of HLT is 
begin

end arch; -- arch


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