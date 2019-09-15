library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.memory_channel_types.ALL;

entity sdram_controller is
port(
        sys_clk:                in std_logic;
        mem_clk:                in std_logic;
        mc_in:                  in mem_channel_in_t;
        mc_out:                 out mem_channel_out_t;

        sdram_data:             inout std_logic_vector(15 downto 0);
        sdram_addr:             out std_logic_vector(12 downto 0);
        sdram_ba:               out std_logic_vector(1 downto 0);
        sdram_dqm:              out std_logic_vector(1 downto 0);
        sdram_ras:              out std_logic;
        sdram_cas:              out std_logic;
        sdram_cke:              out std_logic;
        sdram_clk:              out std_logic;
        sdram_we:               out std_logic;
        sdram_cs:               out std_logic
    );
end entity;

architecture synth of sdram_controller is
begin
    sdram_addr <= (others => '0');
    sdram_data <= (others => 'Z');
    sdram_ba <= (others => '0');
    sdram_dqm <= (others => '0');
    sdram_ras <= '1';
    sdram_cas <= '1';
    sdram_cke <= '0';
    sdram_clk <= '0';
    sdram_we <= '1';
    sdram_cs <= '1';

    mc_out.op_strobe <= '0';
end architecture;


