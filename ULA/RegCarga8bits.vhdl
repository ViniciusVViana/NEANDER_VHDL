library ieee;
use ieee.std_logic_1164.all;
    entity regCarga8bits is
        port(
            d : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic_vector(7 downto 0)
        );
    end entity;
architecture reg8bit of regCarga8bits is
    component regCarga1bit is
        port(
            d : in std_logic;
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic
        );
    end component;
begin
    -- instâncias de regCarga1bit (8 vezes)
    loop_reg: for i in 0 to 7 generate
        u_reg1bit: regCarga1bit port map(d(i),clk,pr,cl,nrw,s(i));
    end generate loop_reg;
end architecture;

  -- Reg Carga 1 Bit
library ieee;
use ieee.std_logic_1164.all;
    entity regCarga1bit is
        port(
            d : in std_logic;
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic
        );
        end entity;
architecture reg1bit of regCarga1bit is
    component ffd is
        port(
            d : in std_logic;
            clk : in std_logic;
            pr, cl : in std_logic;
            q, nq : out std_logic
        );
        end component;
        
    component mux2x1 is
        port(
            c0: in std_logic;
            c1: in std_logic;
            sel: in std_logic;
            Z: out std_logic
        );
    end component;
    signal datain, dataout,s_mux, damn : std_logic;

begin
    -- envio de dataout para saída s
    s <= dataout;
 
    -- multiplexador
    u_mux2x1: mux2x1 port map(dataout,d,nrw,s_mux);
    -- nrw = 1 -> entrada principal de interface d
    -- nrw = 0 -> saida temporária dataout (mantém estado)
    -- instância do reg
    u_reg : ffd port map(s_mux,clk,pr,cl,dataout,damn);
end architecture;

--  Multiplexador de 2 canais com 1 bits por canal
library ieee;
use ieee.std_logic_1164.all;

entity mux2x1 is
    port(
        c0: in std_logic;
        c1: in std_logic;
        sel: in std_logic;
        Z: out std_logic
    );
    end entity;

architecture comutar of mux2x1 is
begin
    -- atribuição condicional
    z <= c0 when sel = '0' else
         c1 when sel = '1' else 'Z'; 

end architecture;

  -- FFD
  
library ieee;
use ieee.std_logic_1164.all;
    entity ffd is
        port(
            d : in std_logic;
            clk : in std_logic;
            pr, cl : in std_logic;
            q, nq : out std_logic
        );
    end ffd;
architecture ff of ffd is
    signal s_snj , s_snk : std_logic;
    signal s_sns , s_snr : std_logic;
    signal s_sns2, s_snr2 : std_logic;
    signal s_eloS, s_eloR : std_logic;
    signal s_eloQ, s_elonQ: std_logic;
    signal s_nClock : std_logic;
begin
    s_nClock <= not(clk);
    -- envio de saídas de NAND para Q e NQ
    q <= s_eloQ;
    nq <= s_elonQ;
    -- s_snj
    -- NAND de 3 entradas? Faça not( X and Y and Z)
    s_snj <=  not(d and clk and s_elonQ);
    -- s_snk
    s_snk <= not(not(d) and clk and s_eloQ);
    -- s_sns
    s_sns <= not(pr and s_snj and s_eloR);
    -- s_snr
    s_snr <= not(cl and s_snk and s_eloS);
    -- s_sns2
    s_sns2 <= s_sns nand s_nClock;
    -- s_snr2
    s_snr2 <= s_snr nand s_nClock;
    -- s_eloS
    s_eloS <= s_sns;
    -- s_eloR
    s_eloR <= s_snr;
    -- s_eloQ
    s_eloQ <= not(pr and s_sns2 and s_elonQ);
    -- s_elonQ
    s_elonQ <= not(s_eloQ and s_snr2 and cl);
    
    
end architecture ff;

