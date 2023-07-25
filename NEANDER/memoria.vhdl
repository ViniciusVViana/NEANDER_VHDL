-- Módulo Memória
library IEEE;
use IEEE.std_logic_1164.all;
entity memoria is
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
end entity;
architecture decora of memoria is

    --Ram
    component as_ram is
        port(
            addr  : in    std_logic_vector(7 downto 0);
            data  : inout std_logic_vector(7 downto 0);
            notrw : in    std_logic;
            reset : in    std_logic
        );
    end component;

    --Registrador REM
    component regREM IS
    PORT (
        AC_datain  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk        : IN STD_LOGIC;
        pr, cl     : IN STD_LOGIC;
        nrw        : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END component;

    --Registrador RDM
    component regRDM IS
    PORT (
        AC_datain  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk        : IN STD_LOGIC;
        pr, cl     : IN STD_LOGIC;
        nrw        : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END component;
    signal s_mux2rem, s_rem2mem, s_mem2rdm, s_rdm2barr : std_logic_vector(7 downto 0);
    
    SIGNAL s_pr : STD_LOGIC;

begin
    interface_barramento <= s_rdm2barr when MEM_nrw = '0'
        else (others => 'Z');
        
    s_mem2rdm <= interface_barramento when MEM_nrw = '1'
        else (others => 'Z');

    s_mux2rem <= end_PC when nbarrPC = '1'
        else end_Barr;

    s_pr <= '1';

    u_rem : regREM port map(s_mux2rem, clk, s_pr, rst, REM_nrw, s_rem2mem);
    u_ram : as_ram port map(s_rem2mem, s_mem2rdm, MEM_nrw, rst);
    u_rdm : regRDM port map(s_mem2rdm, clk, s_pr, rst, RDM_nrw, s_rdm2barr);


end architecture;

-- Registrador REM
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY regREM IS
    PORT (
        AC_datain  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk        : IN STD_LOGIC;
        pr, cl     : IN STD_LOGIC;
        nrw        : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch_ac OF regREM IS
    COMPONENT regCarga1bit IS
        PORT (
            d      : IN STD_LOGIC;
            clk    : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw    : IN STD_LOGIC;
            s      : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    -- instâncias de regCarga1bit (8 vezes)
    loop_reg : FOR i IN 0 TO 7 GENERATE
        u_reg1bit : regCarga1bit PORT MAP(AC_datain(i), clk, pr, cl, nrw, AC_dataout(i));
    END GENERATE loop_reg;
END ARCHITECTURE;

-- Registrador RDM
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY regRDM IS
    PORT (
        AC_datain  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        clk        : IN STD_LOGIC;
        pr, cl     : IN STD_LOGIC;
        nrw        : IN STD_LOGIC;
        AC_dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;
ARCHITECTURE arch_ac OF regRDM IS
    COMPONENT regCarga1bit IS
        PORT (
            d      : IN STD_LOGIC;
            clk    : IN STD_LOGIC;
            pr, cl : IN STD_LOGIC;
            nrw    : IN STD_LOGIC;
            s      : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN
    -- instâncias de regCarga1bit (8 vezes)
    loop_reg : FOR i IN 0 TO 7 GENERATE
        u_reg1bit : regCarga1bit PORT MAP(AC_datain(i), clk, pr, cl, nrw, AC_dataout(i));
    END GENERATE loop_reg;
END ARCHITECTURE;

-------------------------asRAM---------------------------
-- neander asynchronous simple ram memory
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;

entity as_ram is
	port(
		addr  : in    std_logic_vector(7 downto 0);
		data  : inout std_logic_vector(7 downto 0);
		notrw : in    std_logic;
		reset : in    std_logic
	);
end entity as_ram;

architecture behavior of as_ram is
	type ram_type is array (0 to 255) of std_logic_vector(7 downto 0);
	signal ram : ram_type;
	signal data_out : std_logic_vector(7 downto 0);
begin
	
	rampW : process(notrw, reset, addr, data)
	type binary_file is file of character;
	file load_file : binary_file open read_mode is "neanderram.mem";
	variable char : character;
	begin
		if (reset = '0' and reset'event) then
			-- init ram
			read(load_file, char); -- 0x03 '.'
			read(load_file, char); -- 0x4E 'N'
			read(load_file, char); -- 0x44 'D'
			read(load_file, char); -- 0x52 'R'
			for i in 0 to 255 loop
				if not endfile(load_file) then
						read(load_file, char);
						ram(i) <= std_logic_vector(to_unsigned(character'pos(char),8));
						read(load_file, char);	-- 0x00 orindo de alinhamento 16bits	
				end if; -- if not endfile(load_file) then
			end loop; -- for i in 0 to 255
        else
		    if (reset = '1' and notrw = '1') then
			    -- Write
			    ram(to_integer(unsigned(addr))) <= data;
		    end if; -- reset == '1'
		end if; -- reset == '0'
	end process rampW;

	data <= data_out when (reset = '1' and notrw = '0')
		  else (others => 'Z');

	rampR : process(notrw, reset, addr, data)
	begin
		if (reset = '1' and notrw = '0') then
				-- Read
				data_out <= ram(to_integer(unsigned(addr)));
		end if; -- reset = '1' and notrw = '0'
	end process rampR;
end architecture behavior;