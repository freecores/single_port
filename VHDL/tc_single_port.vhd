-- $Author: rpaley_yid $
-- $Date: 2003-01-14 21:48:11 $
-- $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/tc_single_port.vhd,v 1.1.1.1 2003-01-14 21:48:11 rpaley_yid Exp $
-- $Locker
-- $Revision: 1.1.1.1 $
-- $State: Exp $

-- --------------------------------------------------------------------------
-- 
-- Purpose: This file specifies test cases for the single_port
-- Memory.
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
USE WORK.SINGLE_PORT_PKG.ALL;
USE WORK.PKG_IMAGE.ALL;
 
ENTITY tc_single_port IS
PORT  (
  to_srv : OUT to_srv_typ;
  frm_srv : IN frm_srv_typ
);
END ENTITY tc_single_port;

-- --------------------------------------------------
-- Test Case TC0
-- This test case is to check two pages of memory 
-- Starting at physical address 0x0 , 
-- Write a '1' to bit position 0, leaving all other bits 0.
-- Increment the address, 
-- Write a '1' to bit position 1, leaving all other bits 0.
-- Increment the address.
-- Write a '1' to bit position 2, leaving all other bits 0.
-- Continue in this fasion, until write a 1 to the MSB.
-- increment the address,
-- Write a '1' to bit position 0, leaving all other bits 0.
-- Continue until the entire page is written to.
-- Read back all addresses in the page, ensuring the
-- correct data is read back.
-- --------------------------------------------------


ARCHITECTURE TC0 OF tc_single_port IS
BEGIN
  MAIN : PROCESS
    VARIABLE to_srv_v : to_srv_typ;
    VARIABLE frm_srv_v : frm_srv_typ;
    VARIABLE dv : data_inter_typ := 
                  STD_LOGIC_VECTOR(TO_UNSIGNED(1,data_inter_typ'length));
    VARIABLE offset_v : INTEGER;
  BEGIN
    offset_v := 0;
    -- Run this write/read test 10 times for benchmark
    -- purposes.
    for i in 0 to 9 loop 
    for index in 0 to 2*PAGEDEPTH-1 loop
      -- Specify to testbench server to perform write operation;
      to_srv_v.do := write;
      to_srv_v.data := dv; -- specify data to write
      dv := To_StdLogicVector(TO_BitVector(dv) rol 1); -- ROL 1 for next write
      -- Specify physical address.
      to_srv_v.addr := STD_LOGIC_VECTOR(TO_UNSIGNED(index+offset_v,
                       ADDRESS_WIDTH));
      to_srv <= to_srv_v ; WAIT FOR 0 NS;
      WAIT ON frm_srv'TRANSACTION;
    end loop;
    -- Reset data to 1.
    dv := STD_LOGIC_VECTOR(TO_UNSIGNED(1,data_inter_typ'length));
    for index in 0 to 2*PAGEDEPTH-1 loop  
      -- Perform read operation. 
      to_srv_v.do := read;
      -- Specify physical address.
      to_srv_v.addr := STD_LOGIC_VECTOR(TO_UNSIGNED(index+offset_v,
                       ADDRESS_WIDTH));
      to_srv <= to_srv_v ; WAIT FOR 0 NS;
      WAIT ON frm_srv'TRANSACTION;
      -- Compare actual with expected read back data, if the
      -- the expected and actual to not compare, print the 
      -- expected and actual values.
      ASSERT frm_srv.data = dv 
        REPORT "Expected: " & HexImage(frm_srv.data) &
               " did not equal Actual: " & HexImage(dv)
        SEVERITY ERROR; 
      -- Set expected data for next read.
      dv := TO_STDLOGICVECTOR(TO_BITVECTOR(dv) rol 1);
    end loop;
    end loop;
    to_srv_v.do := dealloc; -- Deallocate memory
    --  
    to_srv <= to_srv_v ; WAIT FOR 0 NS;
    -- Tell test bench server process test completed.
    to_srv_v.do := end_test;
    to_srv <= to_srv_v; 
    ASSERT FALSE
      REPORT "Completed Test TC0"
      SEVERITY NOTE;
    WAIT;
  END PROCESS main;
END TC0;

-- --------------------------------------------------
-- Test Case TC1
-- This test case is to check if the test bench will
-- return 'U' for invalid memory locations for 
-- single_port architectures ArrayMEm and LinkedList
-- --------------------------------------------------
ARCHITECTURE TC1 OF tc_single_port IS
BEGIN
  MAIN : PROCESS
    VARIABLE to_srv_v : to_srv_typ;
    VARIABLE frm_srv_v : frm_srv_typ;
    VARIABLE dv : data_inter_typ := (OTHERS => 'U');
  BEGIN
    -- Perform read operation. 
    to_srv_v.do := read;
    -- Specify physical address.
    to_srv_v.addr := STD_LOGIC_VECTOR(TO_UNSIGNED(0,
                     ADDRESS_WIDTH));
    to_srv <= to_srv_v; WAIT FOR 0 NS;
    WAIT ON frm_srv'TRANSACTION;
    -- Compare actual with expected read back data, if the
    -- the expected and actual to not compare, print the 
    -- expected and actual values.
    ASSERT frm_srv.data = dv 
      REPORT "Expected: " & HexImage(frm_srv.data) &
             " did not equal Actual: " & HexImage(dv)
      SEVERITY ERROR; 

    -- Write and read back from same address.

    -- Specify to testbench server to perform write operation;
    to_srv_v.do := write;
    dv := X"a5a5a5a5";
    to_srv_v.data := dv; -- specify data to write
    -- Specify physical address.
    to_srv_v.addr := STD_LOGIC_VECTOR(TO_UNSIGNED(0,
                     ADDRESS_WIDTH));
    to_srv <= to_srv_v; WAIT FOR 0 NS;
    -- Wait until the test bench server finished with the write.
    -- WAIT UNTIL frm_srv.event = true; 
    WAIT ON frm_srv'transaction;
    
    to_srv_v.do := read;
    -- Specify physical address.
    to_srv_v.addr := STD_LOGIC_VECTOR(TO_UNSIGNED(0,
                     ADDRESS_WIDTH));
    to_srv <= to_srv_v; WAIT FOR 0 NS;
    WAIT ON frm_srv'transaction;
    
    -- Compare actual with expected read back data, if the
    -- the expected and actual to not compare, print the 
    -- expected and actual values.
    ASSERT frm_srv.data = dv 
      REPORT "Expected: " & HexImage(frm_srv.data) &
             " did not equal Actual: " & HexImage(dv)
      SEVERITY ERROR; 

    to_srv_v.do := dealloc; -- Deallocate memory
    --  
    to_srv <= to_srv_v; WAIT FOR 0 NS;
    -- Tell test bench server process test completed.
    to_srv_v.do := end_test;
    to_srv <= to_srv_v; WAIT FOR 0 NS;
    
    ASSERT FALSE
      REPORT "Completed Test TC1"
      SEVERITY NOTE;
    WAIT;
  END PROCESS main;
END TC1;

-- $Log: not supported by cvs2svn $
-- Revision 1.1  2003/01/14 17:49:04  Default
-- Initial revision
--
-- Revision 1.2  2002/12/31 19:19:43  Default
-- Updated 'transaction statements for fixed simulator.
--
-- Revision 1.1  2002/12/24 18:13:50  Default
-- Initial revision
--

