-- $Author: rpaley_yid $
-- $Date: 2003-01-14 21:48:11 $
-- $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/single_port_pkg.vhd,v 1.1.1.1 2003-01-14 21:48:11 rpaley_yid Exp $
-- $Locker:  $
-- $Revision: 1.1.1.1 $
-- $State: Exp $

-- --------------------------------------------------------------------------
-- 
-- Purpose: Package file for single_port memory and testbench
-- 
-- References: 
--   1. The Designer's Guide to VHDL by Peter Ashenden
--      ISBN: 1-55860-270-4 (pbk.)
--   2. Writing Testbenches - Functional Verification of HDL models by 
--      Janick Bergeron | ISBN: 0-7923-7766-4
--
-- Notes: 
--
-- --------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE single_port_pkg IS 
CONSTANT PAGEDEPTH : INTEGER := 256; -- memory page depth
CONSTANT PAGENUM : INTEGER := 4096; -- number of pages in memory.
CONSTANT DATA_WIDTH : INTEGER := 32; -- memory data bus width
CONSTANT ADDRESS_WIDTH : INTEGER := 16; -- memory address bus width
-- Data bus type for memory interface
SUBTYPE data_inter_typ IS STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
-- Data bus type for internal memory 
SUBTYPE data_typ IS BIT_VECTOR(DATA_WIDTH-1 DOWNTO 0); 
-- Address bus type for memory interface
SUBTYPE addr_inter_typ IS STD_LOGIC_VECTOR(ADDRESS_WIDTH-1 DOWNTO 0);
-- Address bus type for internal memory
SUBTYPE addr_typ IS NATURAL;
-- Operations testbench can do.
TYPE do_typ IS ( init , read , write , dealloc , end_test );

TYPE to_srv_typ IS RECORD -- Record passed from test case to test bench
  do   : do_typ;
  addr : addr_inter_typ;
  data : data_inter_typ;
  event : BOOLEAN;
END RECORD to_srv_typ;

TYPE frm_srv_typ IS RECORD -- Record passed from test bench to test case
  data : data_inter_typ;
  event : BOOLEAN;
END RECORD frm_srv_typ;

 
END PACKAGE single_port_pkg;

PACKAGE BODY single_port_pkg IS

END PACKAGE BODY single_port_pkg;

-- $Log: not supported by cvs2svn $
-- Revision 1.1  2003/01/14 17:48:44  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 17:58:49  Default
-- Initial revision
--



