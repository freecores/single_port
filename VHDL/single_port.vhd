-- $Author: rpaley_yid $
-- $Date: 2003-01-14 21:48:11 $
-- $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/single_port.vhd,v 1.1.1.1 2003-01-14 21:48:11 rpaley_yid Exp $
-- $Locker
-- $Revision: 1.1.1.1 $
-- $State: Exp $

-- --------------------------------------------------------------------------
-- 
-- Purpose: This is a single port asynchronous memory. This files
-- describes three architectures. Two architectures are traditional 
-- array based memories. One describes the memory as an array of 
-- STD_LOGIC_VECTOR, and the other describes the ARRAY as BIT_VECTOR.
-- The third architecture describes the memory arranged as a linked
-- list in order to conserve computer memory usage. The memory 
-- is organized as a linked list of BIT_VECTOR arrays whose size
-- is defined PAGEDEPTH in single_port_pkg.vhd.
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
USE WORK.single_port_pkg.ALL;
USE WORK.linked_list_mem_pkg.ALL;

ENTITY single_port IS 
  GENERIC (
    rnwtQ : TIME := 1 NS
  );
  PORT (
    d : IN data_inter_typ;
    q : OUT data_inter_typ;
    a : IN addr_inter_typ;
    rnw : IN STD_LOGIC;
    dealloc_mem : IN BOOLEAN 
  );
END ENTITY single_port;

ARCHITECTURE ArrayMemNoFlag OF single_port IS
BEGIN
  
  mem_proc : PROCESS
    TYPE mem_typ IS ARRAY ( 0 TO PAGENUM*PAGEDEPTH-1) OF data_inter_typ;
    VARIABLE mem : mem_typ;
  BEGIN
    WAIT on rnw'transaction;
    IF ( rnw = '0') THEN -- Write
      mem(TO_INTEGER(unsigned(a))) := d;
    ELSE -- Read
      q <= mem(TO_INTEGER(unsigned(a))) AFTER rnwtQ;
    END IF;
  END PROCESS mem_proc;

END ArrayMemNoFlag;

ARCHITECTURE ArrayMem OF single_port IS
BEGIN
  
  mem_proc : PROCESS
  TYPE mem_typ IS ARRAY ( 0 TO PAGENUM*PAGEDEPTH-1 ) OF data_typ;
  TYPE flag_typ IS ARRAY ( 0 TO PAGENUM*PAGEDEPTH-1 ) OF BOOLEAN;
  VARIABLE mem : mem_typ;
  VARIABLE flag : flag_typ;
  BEGIN
    WAIT ON rnw'transaction;
    IF ( rnw = '0') THEN -- Write
      mem(TO_INTEGER(unsigned(a))) := TO_BITVECTOR(d);
      flag(TO_INTEGER(unsigned(a))) := true; -- set valid memory location flag
    ELSE -- read data, either valid or 'U'
      IF ( flag(TO_INTEGER(unsigned(a))) = true ) THEN
        q <= TO_STDLOGICVECTOR(mem(TO_INTEGER(unsigned(a)))) AFTER rnwtQ;
      ELSE -- reading invalid memory location
        q <= (OTHERS => 'U') after rnwtQ;
      END IF;
    END IF; 
  END PROCESS mem_proc;
END ArrayMem;

ARCHITECTURE LinkedList OF single_port IS
  BEGIN
  
  mem_proc : PROCESS 
  VARIABLE mem_page_v : mem_page_ptr;
  VARIABLE d_v : data_inter_typ;
  VARIABLE a_v : addr_typ;
  VARIABLE WRITE_MEM_v : BOOLEAN := true;
  VARIABLE READ_MEM_v  : BOOLEAN := false;
  BEGIN
    WAIT ON dealloc_mem'transaction , rnw'TRANSACTION;
    IF NOT dealloc_mem THEN
      d_v :=  d;
      a_v := TO_INTEGER(unsigned(a));
      IF ( rnw = '0' ) THEN -- write to linked list memory
        rw_mem( data => d_v,
                addr => a_v,
                write_flag => WRITE_MEM_v,
                next_cell => mem_page_v
              ); 
      ELSE -- read from linked list memory
        rw_mem( data => d_v,
                addr => a_v,
                write_flag => READ_MEM_v,
                next_cell => mem_page_v
              );
        q <= d_v after rnwtQ; 
      END IF;
    ELSE -- Deallocate memory from work station memory.
      deallocate_mem(mem_page_v);
    END IF; 
  END PROCESS mem_proc;
 
END LinkedList;

-- $Log: not supported by cvs2svn $
-- Revision 1.1  2003/01/14 17:48:31  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 18:09:05  Default
-- Initial revision
--

