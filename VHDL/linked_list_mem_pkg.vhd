-- $Author: rpaley_yid $
-- $Date: 2003-01-14 21:48:10 $
-- $Header: /home/marcus/revision_ctrl_test/oc_cvs/cvs/single_port/VHDL/linked_list_mem_pkg.vhd,v 1.1.1.1 2003-01-14 21:48:10 rpaley_yid Exp $
-- $Locker
-- $Revision: 1.1.1.1 $
-- $State: Exp $

-- --------------------------------------------------------------------------
-- 
-- Purpose: This package implements functions to allocate, write, read, and
--          deallocate a linked list based memory.
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
USE WORK.single_port_pkg.all;

PACKAGE linked_list_mem_pkg IS
  -- data memory array type definition
  TYPE mem_array_typ IS ARRAY (0 TO PAGEDEPTH-1) OF data_typ;
  -- Define memory page linked list cell. This cell contains,
  -- the mem_array, starting page address, valid data array, and 
  -- the pointer to the next element in the linked list.
  TYPE mem_page_typ;
  -- pointer to next item in the linked list.
  TYPE mem_page_ptr IS ACCESS mem_page_typ; 
  TYPE mem_page_typ IS RECORD
    mem_array : mem_array_typ; -- data memory
    -- This array is a flag which indicates if the corresponding
    -- address location inside mem_array contains valid data.
    data_valid_array : BIT_VECTOR( 0 TO PAGEDEPTH-1);
    page_address : addr_typ;
    next_cell : mem_page_ptr;
  END RECORD mem_page_typ;
  PROCEDURE rw_mem (
                   VARIABLE data : INOUT data_inter_typ;
                   VARIABLE addr : addr_typ;
                   VARIABLE write_flag : BOOLEAN;
                   VARIABLE next_cell : INOUT mem_page_ptr 
                       );
  PROCEDURE deallocate_mem (
                            VARIABLE next_cell : INOUT mem_page_ptr
                           );

END PACKAGE linked_list_mem_pkg;

PACKAGE BODY LINKED_LIST_MEM_PKG IS
  -- --------------------------------------------------
  -- The purpose of this procedure is to write a memory location from 
  -- the linked list, if the particular page does not exist, create it.
  -- --------------------------------------------------  
  PROCEDURE rw_mem (
                      VARIABLE data : INOUT data_inter_typ;
                      VARIABLE addr : addr_typ;
                      VARIABLE write_flag : BOOLEAN;
                      VARIABLE next_cell : INOUT mem_page_ptr
  ) IS
   VARIABLE current_cell_v : mem_page_ptr; -- current page pointer
   VARIABLE page_address_v : addr_typ; -- calculated page address
   VARIABLE index_v        : INTEGER; -- address within the memory page
   VARIABLE mem_array_v : mem_array_typ;
   VARIABLE data_valid_array_v : BIT_VECTOR(0 TO PAGEDEPTH-1); 
  BEGIN
    -- Copy the top of the linked list pointer to a working pointer
    current_cell_v := next_cell; 
    -- Calculate the index within the page from the given address
    index_v := addr MOD PAGEDEPTH; 
    -- Calculate the page address from the given address
    page_address_v := addr - index_v; 
    -- Search through the memory to determine if the calculated
    -- memory page exists. Stop searching when reach the end of
    -- the linked list.
    WHILE ( current_cell_v /= NULL 
            AND current_cell_v.page_address /= page_address_v) LOOP
      current_cell_v := current_cell_v.next_cell;
    END LOOP; 
    
    IF write_flag THEN 
      IF ( current_cell_v /= NULL AND -- Check if address exists in memory.
           current_cell_v.page_address = page_address_v  
           ) THEN
        -- Found the memory page the particular address belongs to
        current_cell_v.mem_array(index_v) := TO_BITVECTOR(data);
        -- set memory location valid flag
        current_cell_v.data_valid_array(index_v) := '1'; 
      ELSE 
        -- The memory page the address belongs to was not allocated in memory.
        -- Allocate page here and assign data.
      mem_array_v(index_v) := TO_BITVECTOR(data);
      data_valid_array_v(index_v) := '1';
      next_cell := NEW mem_page_typ'( mem_array => mem_array_v,
                                  data_valid_array => data_valid_array_v,
                                  page_address => page_address_v,
                                  next_cell => next_cell
                                ); 
      END IF;
    ELSE -- Read memory
      IF ( current_cell_v /= NULL AND -- Check if address exists in memory.
           current_cell_v.page_address = page_address_v AND 
           current_cell_v.data_valid_array(index_v) = '1'
           ) THEN
        -- Found the memory page the particular address belongs to,
        -- and the memory location has valid data.
        data := TO_STDLOGICVECTOR(current_cell_v.mem_array(index_v));
      ELSE 
        -- Trying to read from unwritten or unallocated 
        -- memory location, return 'U';
        data := (OTHERS => 'U');
      END IF;
    END IF;  
  END PROCEDURE rw_mem; 
 
  PROCEDURE deallocate_mem (
                            VARIABLE next_cell : INOUT mem_page_ptr
                           ) IS
    VARIABLE delete_cell_v : mem_page_ptr;
  BEGIN 
    -- Deallocate the linked link memory from work station memory.
    WHILE next_cell /= NULL LOOP -- while not reached the end of the LL
      delete_cell_v := next_cell; -- Copy pointer to record for deleting
      next_cell := next_cell.next_cell; -- set pointer to next cell in LL
      deallocate(delete_cell_v); -- Deallocate current cell from memory.
    END LOOP;
  END PROCEDURE deallocate_mem;
END PACKAGE BODY LINKED_LIST_MEM_PKG;

-- $Log: not supported by cvs2svn $
-- Revision 1.1  2003/01/14 17:47:32  Default
-- Initial revision
--
-- Revision 1.1  2002/12/24 18:03:50  Default
-- Initial revision
--



