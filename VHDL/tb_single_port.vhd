-- $Author: rpaley_yid $
-- $Date: 2003-01-14 21:48:11 $
-- $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/tb_single_port.vhd,v 1.1.1.1 2003-01-14 21:48:11 rpaley_yid Exp $
-- $Locker
-- $Revision: 1.1.1.1 $
-- $State: Exp $

-- --------------------------------------------------------------------------
-- 
-- Purpose: This file specifies test bench harness for the single_port
--          Memory. It also contains the configuration files for all the 
--          tests.
--
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
LIBRARY WORK;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.linked_list_mem_pkg.ALL;
USE WORK.single_port_pkg.all;
USE STD.TEXTIO.ALL;

ENTITY tb_single_port IS
END ENTITY tb_single_port;

ARCHITECTURE BHV of tb_single_port IS

COMPONENT single_port IS
  GENERIC (
    rnwtQ : TIME := 1 NS
  );
  PORT (
    d : IN data_inter_typ;
    q : OUT data_inter_typ;
    a : IN addr_inter_typ;
    rnw : IN STD_LOGIC;
    dealloc_mem : BOOLEAN
);
END COMPONENT single_port;  

COMPONENT tc_single_port IS
  PORT (
  to_srv : OUT to_srv_typ;
  frm_srv : IN frm_srv_typ
);
END COMPONENT tc_single_port;

SIGNAL d : data_inter_typ;
SIGNAL q : data_inter_typ;
SIGNAL a : addr_inter_typ;
SIGNAL rnw : STD_LOGIC;
SIGNAL dealloc_mem : BOOLEAN;
SIGNAL to_srv : to_srv_typ;
SIGNAL frm_srv : frm_srv_typ;
SIGNAL tie_vdd : STD_LOGIC := '1';
BEGIN
  dut : single_port 
    PORT MAP (
      d => d,
      a => a,
      q => q,
      rnw => rnw,
      dealloc_mem => dealloc_mem
  );

  tc : tc_single_port
    PORT MAP (
    to_srv => to_srv,
    frm_srv => frm_srv
  );

  single_port_server : PROCESS
    VARIABLE frm_srv_v : frm_srv_typ;
    CONSTANT ACCESS_DELAY : TIME := 5 NS;
  BEGIN
    -- Wait until the test case is finished setting up the next memory access.
    WAIT ON to_srv'TRANSACTION;
    CASE to_srv.do IS
      WHEN init =>
        ASSERT FALSE
          REPORT "initialized"
          SEVERITY NOTE; 
      WHEN read => -- perform memory read
        d <= to_srv.data;
        a <= to_srv.addr;
        rnw <= '1';
        -- Wait for data to appear 
        WAIT FOR ACCESS_DELAY;
      WHEN write => -- perform memory write
        d <= to_srv.data;
        a <= to_srv.addr;
        rnw <= '0';
        WAIT FOR ACCESS_DELAY;
      WHEN dealloc => -- deallocate the linked list for the LL architecture
        dealloc_mem <= true;
      WHEN end_test => -- reached the end of the test case
        WAIT; 
    END CASE;
    frm_srv_v.data := q;
    -- Send message to test case to continue the test.
    frm_srv <= frm_srv_v ; WAIT FOR 0 NS;
  END PROCESS single_port_server;
END BHV;

CONFIGURATION ll_main_cfg OF TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(LinkedList);
    END FOR; -- dut 
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC0);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION ll_main_cfg;

CONFIGURATION ll_error_cfg OF TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(LinkedList);
    END FOR; -- dut 
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC1);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION ll_error_cfg ;

CONFIGURATION mem_main_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMem);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC0);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION mem_main_cfg;

CONFIGURATION mem_error_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMem);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC1);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION mem_error_cfg;

CONFIGURATION memnoflag_main_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMemNoFlag);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC0);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION memnoflag_main_cfg;

CONFIGURATION memnoflag_error_cfg of TB_SINGLE_PORT IS
  FOR BHV
    FOR dut : single_port
      USE ENTITY work.single_port(ArrayMemNoFlag);
    END FOR; -- dut
    FOR tc : tc_single_port
      USE ENTITY work.tc_single_port(TC1);
    END FOR; -- tc;
  END FOR; -- BHV
END CONFIGURATION memnoflag_error_cfg;

-- $Log: not supported by cvs2svn $
-- Revision 1.1  2003/01/14 17:49:04  Default
-- Initial revision
--
-- Revision 1.2  2002/12/31 19:19:43  Default
-- Updated 'transaction statements for fixed simulator.
--
-- Revision 1.1  2002/12/24 18:10:18  Default
-- Initial revision
--


