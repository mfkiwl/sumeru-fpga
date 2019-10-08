library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
use work.memory_channel_types.ALL;

entity cpu is
port(
    clk_50m:                    in std_logic;
    btn:                        in std_logic;
    led:                        out std_logic;
    spi0_sck:                   out std_logic;
    spi0_ss:                    out std_logic;
    spi0_mosi:                  out std_logic;
    spi0_miso:                  in std_logic;
    sdram_data:                 inout std_logic_vector(15 downto 0);
    sdram_addr:                 out std_logic_vector(12 downto 0);
    sdram_ba:                   out std_logic_vector(1 downto 0);
    sdram_dqm:                  out std_logic_vector(1 downto 0);
    sdram_ras:                  out std_logic;
    sdram_cas:                  out std_logic;
    sdram_cke:                  out std_logic;
    sdram_clk:                  out std_logic;
    sdram_we:                   out std_logic;
    sdram_cs:                   out std_logic);
end entity;

architecture synth of cpu is
    signal sys_clk:             std_logic;
    signal mem_clk:             std_logic;
    signal cache_clk:           std_logic;
    signal reset_n:             std_logic;

    signal pc:                  std_logic_vector(31 downto 0) := (others => '0');

    signal sdc_in:              mem_channel_in_t;
    signal sdc_out:             mem_channel_out_t;
    signal sdc_data_out:        std_logic_vector(15 downto 0);
    signal sdc_busy:            std_logic;

    signal mc0_in:              mem_channel_in_t;
    signal mc0_out:             mem_channel_out_t;

    signal mc1_in:              mem_channel_in_t;
    signal mc1_out:             mem_channel_out_t;

    signal bootcode_load_done:  std_logic;

    signal icache_hit:          std_logic;
    signal icache_data:         std_logic_vector(31 downto 0);

    type state_t is (
        INIT,
        IDLE,
        WAIT_STROBE,
        WAIT_BUSY);
        
    signal state:               state_t := INIT;

begin
    spi0_sck <= '0';
    spi0_ss <= '0';
    spi0_mosi <= '0';

    pll: entity work.pll 
        port map(
            inclk0 => clk_50m,
            c0 => sys_clk,
            c1 => mem_clk,
            c2 => cache_clk,
            locked => reset_n);

    sdram_controller: entity work.sdram_controller
        port map(
            sys_clk => sys_clk,
            mem_clk => mem_clk,
            mc_in => sdc_in,
            mc_out => sdc_out,
            data_out => sdc_data_out,
            sdram_data => sdram_data,
            sdram_addr => sdram_addr,
            sdram_ba => sdram_ba,
            sdram_dqm => sdram_dqm,
            sdram_ras => sdram_ras,
            sdram_cas => sdram_cas,
            sdram_cke => sdram_cke,
            sdram_clk => sdram_clk,
            sdram_we => sdram_we,
            sdram_cs => sdram_cs,
            busy => sdc_busy);
            
    memory_arbitrator: entity work.memory_arbitrator
        port map(
            clk => sys_clk,

            sdc_busy => sdc_busy,
            sdc_in => sdc_in,
            sdc_out => sdc_out,

            mc0_in => mc0_in,
            mc0_out => mc0_out,

            mc1_in => mc1_in,
            mc1_out => mc1_out,
        
            mc2_in => ((others => '0'), '0', '0', '0', 
                       (others => '0'), (others => '0')),

            mc3_in => ((others => '0'), '0', '0', '0', 
                       (others => '0'), (others => '0')));

    bootcode_loader: entity work.memory_loader
        generic map(
            DATA_FILE => "BOOTCODE.hex"
        )
        port map(
            sys_clk => sys_clk,
            mem_clk => mem_clk,
            reset_n => reset_n,

            load_done => bootcode_load_done,
            mc_in => mc1_in,
            mc_out => mc1_out);

    icache: entity work.icache
        port map(
            sys_clk => sys_clk,
            cache_clk => cache_clk,
            enable => bootcode_load_done,

            addr => pc,
            hit => icache_hit,
            data => icache_data,

            mc_in => mc0_in,
            mc_out => mc0_out,

            sdc_data_out => sdc_data_out
            );

    process(sys_clk)
    begin
        if (rising_edge(sys_clk)) then
            if (icache_hit = '1') then
                pc <= std_logic_vector(unsigned(pc) + 4);
                if (icache_data = x"4A4A52B7") then
                    led <= not led;
                end if;
            end if;
        end if;
    end process;

end architecture;


