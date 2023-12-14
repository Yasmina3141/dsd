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

  signal ITER_CNTxDP, ITER_CNTxDN : unsigned(MEM_DATA_BW - 1 downto 0);

  signal CRxDP, CRxDN : signed(N_BITS - 1 downto 0);
  signal CIxDP, CIxDN : signed(N_BITS - 1 downto 0);
  signal ZRxDP, ZRxDN : signed(N_BITS - 1 downto 0);
  signal ZIxDP, ZIxDN : signed(N_BITS - 1 downto 0);
  signal X_CNTxDP, X_CNTxDN : unsigned(COORD_BW - 1 downto 0);
  signal Y_CNTxDP, Y_CNTxDN : unsigned(COORD_BW - 1 downto 0);


  signal MUX_ZRxD, MUX_ZIxD : signed(N_BITS - 1 downto 0);
  signal ZRSxD, ZISxD : signed(N_BITS - 1 downto 0);
  signal MULT_ZI_ZRxD : signed(N_BITS - 1 downto 0);
  signal SUB_ZRS_ZISxD : signed(N_BITS - 1 downto 0);
  signal SUM_SxD : signed(N_BITS - 1 downto 0);
  signal ZRS_INTERxD : signed(2*N_BITS -1 downto 0);
  signal ZIS_INTERxD : signed(2*N_BITS - 1 downto 0);


  signal ITER_RSTxS : std_logic;
  signal UNBOUNDEDxS : std_logic;


--=============================================================================
-- ARCHITECTURE BEGIN
--=============================================================================
begin
  
  ITER_RSTxS <= '1' when ITER_CNTxDP = MAX_ITER or SUM_SxD > ITER_LIM else '0';

  CRxDN <= CRxDP + C_RE_INC when ITER_RSTxS = '1' else CRxDP;

  ITER_CNTxDN <= ITER_CNTxDP + 1 when ITER_RSTxS = '0' else (others => '0');

  CR_inc: process (CLKxCI, RSTxRI) is
    begin
      if (RSTxRI = '1') then
        CRxDP <= C_RE_0;
        ZRxDP <= (others => '0');
      elsif (CLKxCI'event and CLKxCI = '1') then
        CRxDP <= CRxDN;
        ZRxDP <= ZRxDN;
      end if;
    end process CR_inc;
  
    CIxDN <= CIxDP + C_IM_INC when ITER_RSTxS = '1' else CIxDP;
  
  CI_inc : process (CLKxCI, RSTxRI) is
    begin
      if (RSTxRI = '1') then
        CIxDP <= C_IM_0;
        ZIxDP <= (others => '0');
      elsif (CLKxCI'event and CLKxCI = '1') then
        CIxDP <= CIxDN;
        ZIxDP <= ZIxDN;
      end if;
    end process CI_inc;

  ITER_CNT : process (CLKxCI, RSTxRI) is
  begin
    if (RSTxRI = '1') then
      ITER_CNTxDP <= (others => '0');
    elsif (CLKxCI'event and CLKxCI = '1') then
      ITER_CNTxDP <= ITER_CNTxDN;
    end if;
  end process ITER_CNT;

  X_CNTxDN <= X_CNTxDP + 1 when ITER_RSTxS = '1' else
              (others => '0') when X_CNTxDP = HS_DISPLAY - 1
              else X_CNTxDP;
  Y_CNTxDN <= Y_CNTxDP + 1 when X_CNTxDP = HS_DISPLAY - 1 else Y_CNTxDP;

  COORD_CNT : process (CLKxCI, RSTxRI) is
    begin
      if (RSTxRI = '1') then
        X_CNTxDP <= (others => '0');
        Y_CNTxDP <= (others => '0');
      elsif (CLKxCI'event and CLKxCI = '1') then
        X_CNTxDP <= X_CNTxDN;
        Y_CNTxDP <= Y_CNTxDN;
      end if;
    end process COORD_CNT;

  MUX_ZRxD <= CRxDP when ITER_RSTxS = '1' else ZRxDP;
  MUX_ZIxD <= CIxDP when ITER_RSTxS = '1' else ZIxDP;


  ZRSxD <= shift_right(MUX_ZRxD * MUX_ZRxD, N_FRAC)(N_BITS - 1 downto 0);
  ZISxD <= shift_right(MUX_ZIxD * MUX_ZIxD, N_FRAC)(N_BITS - 1 downto 0);

  SUM_SxD <= to_signed(to_integer(shift_right(MUX_ZRxD * MUX_ZRxD, N_FRAC)(N_BITS - 1 downto 0)) + to_integer(shift_right(MUX_ZIxD * MUX_ZIxD, N_FRAC)(N_BITS - 1 downto 0)), N_BITS);

  MULT_ZI_ZRxD <= shift_right(2*MUX_ZRxD * MUX_ZIxD, N_FRAC)(2*N_BITS - 1 downto N_BITS);

  SUB_ZRS_ZISxD <= ZRSxD - ZISxD;

  --UNBOUNDEDxS <= '1' when SUM_SxD > ITER_LIM else '0';

  ZRxDN <= SUB_ZRS_ZISxD + CRxDP;

  ZIxDN <= MULT_ZI_ZRxD + CIxDP;
    
  WExSO <= ITER_RSTxS;

  ITERxDO <= ITER_CNTxDP when ITER_CNTxDP /= MAX_ITER else (others => '0') ;

  XxDO <= X_CNTxDP;
  YxDO <= Y_CNTxDP;

end architecture rtl;
--=============================================================================
-- ARCHITECTURE END
--=============================================================================
