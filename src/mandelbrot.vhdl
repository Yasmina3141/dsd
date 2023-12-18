--=============================================================================
-- @file mandelbrot.vhdl
--=============================================================================
-- Standard library
library ieee;
-- Standard packages
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- Packages
library work;
use work.dsd_prj_pkg.all;

--=============================================================================
--
-- mandelbrot
--
-- @brief This file specifies a basic circuit for mandelbrot
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR MANDELBROT
--=============================================================================
entity mandelbrot is
  port (
    CLKxCI : in std_logic;
    RSTxRI : in std_logic;

    WExSO   : out std_logic;
    XxDO    : out unsigned(COORD_BW - 1 downto 0);
    YxDO    : out unsigned(COORD_BW - 1 downto 0);
    ITERxDO : out unsigned(MEM_DATA_BW - 1 downto 0)
  );
end entity mandelbrot;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture rtl of mandelbrot is

  -- TODO: Implement your own code here
  signal NxDP, NxDN : unsigned(MEM_DATA_BW - 1 downto 0);
  signal z_rxDP, z_rxDN : signed(N_BITS - 1 downto 0);
  signal z_ixDP, z_ixDN : signed(N_BITS - 1 downto 0);
  signal XxDP, XxDN : unsigned(COORD_BW - 1 downto 0);
  signal YxDP, YxDN : unsigned(COORD_BW - 1 downto 0);
  signal coordXxDP, coordXxDN : signed(N_BITS - 1 downto 0);
  signal coordYxDP, coordYxDN : signed(N_BITS - 1 downto 0);
  signal resxD : signed(N_BITS - 1 downto 0);
  signal lenxD : unsigned(N_BITS - 1 downto 0);
  
--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin

  -- TODO: Implement your own code here
  resxD <= shift_right(z_rxDP * z_rxDP, N_FRAC)(N_BITS - 1 downto 0) - shift_right(z_ixDP * z_ixDP, N_FRAC)(N_BITS - 1 downto 0) + coordXxDP;
  lenxD <= unsigned(shift_right(z_rxDP * z_rxDP, N_FRAC)(N_BITS - 1 downto 0)) + unsigned(shift_right(z_ixDP * z_ixDP, N_FRAC)(N_BITS - 1 downto 0));

  process(CLKxCI, RSTxRI)
  begin
    if RSTxRI = '1' then
      NxDP <= (others => '0');
      z_rxDP <= C_RE_0;
      z_ixDP <= C_IM_0;
      coordXxDP <= C_RE_0;
      coordYxDP <= C_IM_0;
      XxDP <= (others => '0');
      YxDP <= (others => '0');
    elsif (CLKxCI'event and CLKxCI = '1') then
      NxDP <= NxDN;
      z_rxDP <= z_rxDN;
      z_ixDP <= z_ixDN;
      XxDP <= XxDN;
      YxDP <= YxDN;
      coordXxDP <= coordXxDN;
      coordYxDP <= coordYxDN;
    end if;
  end process;

  XxDO <= XxDP;
  YxDO <= YxDP;
  ITERxDO <= NxDP;

  process(all)
  begin
    if NxDP = MAX_ITER or lenxD > ITER_LIM then
      NxDN <= (others => '0');
      WExSO <= '1';
      -- increment X and Y if necessary
      if XxDP = HS_DISPLAY - 1 then
        XxDN <= (others => '0');
        coordXxDN <= C_RE_0;
        z_rxDN <= C_RE_0;
        -- check if Y is at the end of the line
        if YxDP = VS_DISPLAY - 1 then
          YxDN <= (others => '0');
          coordYxDN <= C_IM_0;
          z_ixDN <= C_IM_0;
        else
          YxDN <= YxDP + 1;
          coordYxDN <= coordYxDP + C_IM_INC;
          z_ixDN <= coordYxDP + C_IM_INC;
        end if;
      else
        XxDN <= XxDP + 1;
        coordXxDN <= coordXxDP + C_RE_INC;
        z_rxDN <= coordXxDP + C_RE_INC;

        YxDN <= YxDP;
        coordYxDN <= coordYxDP;
        z_ixDN <= coordYxDP;
      end if;
    else
      NxDN <= NxDP + 1;
      WExSO <= '0';
      z_ixDN <= shift_left(shift_right(z_rxDP * z_ixDP, N_FRAC)(N_BITS - 1 downto 0), 1) + coordYxDP;
      z_rxDN <= resxD;
      
      XxDN <= XxDP;
      coordXxDN <= coordXxDP;
      YxDN <= YxDP;
      coordYxDN <= coordYxDP;
    end if;
  end process;

end architecture rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================