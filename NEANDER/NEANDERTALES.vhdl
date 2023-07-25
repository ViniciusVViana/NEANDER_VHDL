LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity NEANDER is
    port(
        Ncl, Nclck : in std_logic
    );
end entity;

architecture HOMORECTALES of NEANDER is

    component moduloULA is
        port (
            interface_barramento : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            ULA_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            AC_rw : IN STD_LOGIC;
            interface_flags : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_nrw : IN STD_LOGIC;
            rst, clk : IN STD_LOGIC
        );
    end component;

    component PC is
        port (
            barr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            nbarrinc : IN STD_LOGIC;
            nrw, cl, clk : IN STD_LOGIC;
            endout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    end component;

    component moduloCTRL is
        port(
            interface_barramento : in std_logic_vector (7 downto 0);
            inNZ                 : std_logic_vector (1 downto 0);
            nrw, cl, clk         : in std_logic;
            barramento_ctrl      : out std_logic_vector (10 downto 0)
        );
    end component;

    component memoria is
        port(
            rst, clk   : in    std_logic;
            nbarrPC    : in    std_logic;
            REM_nrw    : in    std_logic;
            MEM_nrw    : in    std_logic;
            RDM_nrw    : in    std_logic;
            end_PC     : in    std_logic_vector(7 downto 0);       
            end_Barr   : in    std_logic_vector(7 downto 0);
            interface_barramento : inout std_logic_vector(7 downto 0)
        );
    end component;

    signal barramento_data_ins, sendout : std_logic_vector(7 downto 0);
    signal barramento_ctrl :  std_logic_vector(10 downto 0);
    signal sNcl, sNclck : std_logic;
    signal sNflags : std_logic_vector(1 downto 0);
begin

    sNcl   <= ncl;
    sNclck <= Nclck;

    --BIT 10 = NBARR/INC
    --BIT 09 = NBARR/PC
    --BIT 08-07-06 = ULA_OP
    --BIT 05 = PC_NRW
    --BIT 04 = AC_NRW
    --BIT 03 = MEM_NRW
    --BIT 02 = REM_NRW
    --BIT 01 = RDM_NRW
    --BIT 00 = RI_NRW
    
    u_Npc : PC port map(barramento_data_ins, barramento_ctrl(10), barramento_ctrl(5), sNcl, sNclck, sendout);

    u_Nmem : memoria port map(sNcl, sNclck, barramento_ctrl(9), barramento_ctrl(2), barramento_ctrl(3), barramento_ctrl(1), sendout, barramento_data_ins, barramento_data_ins);

    u_Nctrtl : moduloCTRL port map(barramento_data_ins, sNflags, barramento_ctrl(0), sNcl, sNclck, barramento_ctrl);

    u_Nula : moduloULA port map(barramento_data_ins, barramento_ctrl(8 downto 6), barramento_ctrl(4), sNflags, barramento_ctrl(3), sNcl, sNclck);

end architecture;