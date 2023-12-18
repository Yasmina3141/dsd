--=============================================================================
-- @file vga_controller.vhdl
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
-- vga_controller
--
-- @brief This file specifies a VGA controller circuit
--
--=============================================================================

--=============================================================================
-- ENTITY DECLARATION FOR VGA_CONTROLLER
--=============================================================================
entity vga_controller is
  port (
    CLKxCI : in std_logic;
    RSTxRI : in std_logic;

    -- Data/color input
    RedxSI   : in std_logic_vector(COLOR_BW - 1 downto 0);
    GreenxSI : in std_logic_vector(COLOR_BW - 1 downto 0);
    BluexSI  : in std_logic_vector(COLOR_BW - 1 downto 0);

    -- Coordinate output
    XCoordxDO : out unsigned(COORD_BW - 1 downto 0);
    YCoordxDO : out unsigned(COORD_BW - 1 downto 0);

    -- Timing output
    HSxSO : out std_logic;
    VSxSO : out std_logic;

    VSEdgexSO : out std_logic;

    -- Data/color output
    RedxSO   : out std_logic_vector(COLOR_BW - 1 downto 0);
    GreenxSO : out std_logic_vector(COLOR_BW - 1 downto 0);
    BluexSO  : out std_logic_vector(COLOR_BW - 1 downto 0)
  );
end vga_controller;

--=============================================================================
-- ARCHITECTURE DECLARATION
--=============================================================================
architecture rtl of vga_controller is

  -- TODO: Implement your own code here
  signal pixelCntxDP, pixelCntxDN : unsigned(11 - 0 downto 0);
  signal lineCntxDP, lineCntxDN : unsigned(10 - 0 downto 0);

  signal VSEdgexDP, VSEdgexDN : std_logic;

  signal pixelRstxS : std_logic;
  signal lineRstxS : std_logic;
--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin

  -- TODO: Implement your own code here
  pixelCntxDN <= (others => '0') when pixelRstxS = '1' else
  pixelCntxDP + 1;

  pixelRstxS <= '1' when pixelCntxDP = 1328 - 1 else '0';

  pixelCnt: process (CLKxCI, RSTxRI) is
  begin
    if (RSTxRI = '1') then
      pixelCntxDP <= (others => '0');
    elsif (CLKxCI'event and CLKxCI = '1') then
      pixelCntxDP <= pixelCntxDN;
    end if;
  end process pixelCnt;

  lineCntxDN <= (others => '0') when lineRstxS = '1' else
  lineCntxDP + 1                when pixelCntxDP = 1328 - 1 else
  lineCntxDP;

  lineRstxS <= '1' when lineCntxDP = 806 - 1 and pixelCntxDP = 1328 - 1 else '0';

  lineCnt: process (CLKxCI, RSTxRI) is
  begin
    if (RSTxRI = '1') then
      lineCntxDP <= (others => '0');
    elsif (CLKxCI'event and CLKxCI = '1') then
      lineCntxDP <= lineCntxDN;
    end if;
  end process lineCnt;

  VSxSO <= VS_POLARITY when lineCntxDP < VS_PULSE else not VS_POLARITY;
  HSxSO <= HS_POLARITY when pixelCntxDP < HS_PULSE else not HS_POLARITY;

  RedxSO <= RedxSI when
  lineCntxDP >= VS_PULSE + VS_BACK_PORCH and
  lineCntxDP < VS_PULSE + VS_BACK_PORCH + VS_DISPLAY and
  pixelCntxDP >= HS_PULSE + HS_BACK_PORCH and 
  pixelCntxDP < HS_PULSE + HS_BACK_PORCH + HS_DISPLAY else (others => '0');

  GreenxSO <= GreenxSI when 
  lineCntxDP >= VS_PULSE + VS_BACK_PORCH and
  lineCntxDP < VS_PULSE + VS_BACK_PORCH + VS_DISPLAY and
  pixelCntxDP >= HS_PULSE + HS_BACK_PORCH and 
  pixelCntxDP < HS_PULSE + HS_BACK_PORCH + HS_DISPLAY else (others => '0');

  BluexSO <= BluexSI when 
  lineCntxDP >= VS_PULSE + VS_BACK_PORCH and
  lineCntxDP < VS_PULSE + VS_BACK_PORCH + VS_DISPLAY and
  pixelCntxDP >= HS_PULSE + HS_BACK_PORCH and 
  pixelCntxDP < HS_PULSE + HS_BACK_PORCH + HS_DISPLAY else (others => '0');

  XCoordxDO <= pixelCntxDP - to_unsigned(HS_PULSE + HS_BACK_PORCH, COORD_BW);
  YCoordxDO <= lineCntxDP - to_unsigned(VS_PULSE + VS_BACK_PORCH, COORD_BW);

  process (CLKxCI, RSTxRI) is
  begin
    if (RSTxRI = '1') then
      VSEdgexDP <= '0';
    elsif (CLKxCI'event and CLKxCI = '1') then
      VSEdgexDP <= VSEdgexDN;
    end if;
  end process;

  VSEdgexDN <= VS_POLARITY when lineCntxDP < VS_PULSE else not VS_POLARITY;

  VSEdgexSO <= not VSEdgexDP and VSEdgexDN;

end rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================