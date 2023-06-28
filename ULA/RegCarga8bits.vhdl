LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY tb_regCarga8bits IS
END tb_regCarga8bits;

architecture arch of tb_regCarga8bits is
    
    component regCarga8bits is
        port(
            d : in std_logic_vector(7 downto 0);
            clk : in std_logic;
            pr, cl : in std_logic;
            nrw : in std_logic;
            s : out std_logic_vector(7 downto 0)
        );
    end component;

    signal sD, sS: std_logic_vector(7 downto 0);
    signal sPr,sCl, sNrw: std_logic;

    constant CLK_PERIOD : time := 20 ns;
    signal sClk : std_logic := '1';

begin
    u_regCarga8bits: regCarga8bits port map(sD,sClk, sPr,sCl, sNrw, sS);
    
    u_teste: process
    begin
        
        sPr <= '1';
        sCl <= '0';
        sD <= "11110000";
        sNrw <= '1';
        wait for CLK_PERIOD;

        sPr <= '1';
        sCl <= '1';
        sD <= "11110000";
        sNrw <= '1';
        wait for CLK_PERIOD;

        sPr <= '1';
        sCl <= '1';
        sD <= "11110000";
        sNrw <= '0';

        wait for CLK_PERIOD;

        sPr <= '1';
        sCl <= '1';
        sD <= "00001111";
        sNrw <= '1';
        wait for CLK_PERIOD;

        sPr <= '1';
        sCl <= '1';
        sD <= "00001111";
        sNrw <= '0';

        wait for CLK_PERIOD;
    
    wait;
    end process;

     -- process para Clock
    tbp1 : process
    begin
        sClk <= not(sClk);
        wait for CLK_PERIOD/2;
    end process;

end architecture;


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
use ieee.std_logic_1164.all; -- std_logic para detectar erros

entity ffd is
    port(
        d      : in std_logic;
        clk    : in std_logic;
        pr, cl : in std_logic;
        q, nq  : out std_logic
    );
end entity;

architecture latch of ffd is
    component ffjk is
        port(
            j, k   : in std_logic;
            clk    : in std_logic;
            pr, cl : in std_logic;
            q, nq  : out std_logic
        );
    end component;

    signal sq  : std_logic := '0'; -- opcional -> valor inicial
    signal snq : std_logic := '1';
    signal nj  : std_logic;
begin

    u_td : ffjk port map(d, nj, clk, pr, cl, q, nq);
    nj <= not(d);

end architecture latch;



library ieee;
use ieee.std_logic_1164.all; -- std_logic para detectar erros

entity ffjk is
    port(
        j, k   : in std_logic;
        clk    : in std_logic;
        pr, cl : in std_logic;
        q, nq  : out std_logic
    );
end entity;

architecture latch of ffjk is
    signal sq  : std_logic := '0'; -- opcional -> valor inicial
    signal snq : std_logic := '1';
begin

    q  <= sq;
    nq <= snq;

    u_ff : process (clk, pr, cl)
    begin
        -- pr = 0 e cl = 0 -> Desconhecido
        if (pr = '0') and (cl = '0') then
            sq  <= 'X';
            snq <= 'X';
            -- prioridade para cl
            elsif (pr = '1') and (cl = '0') then
                sq  <= '0';
                snq <= '1';
                -- tratamento de pr
                elsif (pr = '0') and (cl = '1') then
                    sq  <= '1';
                    snq <= '0';
                    -- pr e cl desativados
                    elsif (pr = '1') and (cl = '1') then
                        if falling_edge(clk) then
                            -- jk = 00 -> mantém estado
                            if    (j = '0') and (k = '0') then
                                sq  <= sq;
                                snq <= snq;
                            -- jk = 01 -> q = 0
                            elsif (j = '0') and (k = '1') then
                                sq  <= '0';
                                snq <= '1';
                            -- jk = 01 -> q = 1
                            elsif (j = '1') and (k = '0') then
                                sq  <= '1';
                                snq <= '0';
                            -- jk = 11 -> q = !q
                            elsif (j = '1') and (k = '1') then
                                sq  <= not(sq);
                                snq <= not(snq);
                            -- jk = ?? -> falha
                            else
                                sq  <= 'U';
                                snq <= 'U';
                            end if;
                        end if;
            else
                sq  <= 'X';
                snq <= 'X';
        end if;
    end process;

end architecture;


