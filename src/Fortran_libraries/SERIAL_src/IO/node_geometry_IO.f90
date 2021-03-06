!>@file   node_geometry_IO.f90
!!@brief  module node_geometry_IO
!!
!!@author H. Matsui
!!@date Programmed by H.Matsui and H.Okuda in July 2000
!!@n     Modified by H. Matsui on  Aug., 2006
!
!>@brief  routines for ASCII data IO for mesh geometry
!!
!!@verbatim
!!      subroutine write_geometry_info(id_file)
!!      subroutine write_scalar_in_element(id_file)
!!      subroutine write_vector_in_element(id_file)
!!      subroutine write_geometry_info_b(id_file)
!!
!!      subroutine read_number_of_node(id_file)
!!      subroutine read_geometry_info(id_file)
!!      subroutine read_number_of_node_b(id_file)
!!      subroutine read_geometry_info_b(id_file)
!!@endverbatim
!
      module node_geometry_IO
!
      use m_precision
!
      use m_read_mesh_data
!
      implicit none
!
      character(len=255) :: character_4_read
      private :: character_4_read
!
!------------------------------------------------------------------
!
       contains
!
!------------------------------------------------------------------
!
      subroutine write_geometry_info(id_file)
!
      integer (kind = kint), intent(in) :: id_file
      integer (kind = kint) :: i
!
!
      write(id_file,'(2i16)') numnod_dummy, internal_node_dummy
!
      do i=1, numnod_dummy
        write(id_file,'(i16,1p3E25.15e3)')  globalnodid_dummy(i),       &
     &        xx_dummy(i,1:3)
      end do
!
      call deallocate_node_data_dummy
!
      end subroutine write_geometry_info
!
!------------------------------------------------------------------
!
      subroutine write_scalar_in_element(id_file)
!
      integer (kind = kint), intent(in) :: id_file
      integer(kind = kint) :: i
!
      write(id_file,'(2i16)') numnod_dummy, internal_node_dummy
      do i = 1, numnod_dummy
        write(id_file,'(i16, 1p3e23.15)') i, ele_scalar_IO(i)
      end do
!
      call deallocate_ele_scalar_IO
!
      end subroutine write_scalar_in_element
!
!------------------------------------------------------------------
!
      subroutine write_vector_in_element(id_file)
!
      integer (kind = kint), intent(in) :: id_file
      integer(kind = kint) :: i
!
      write(id_file,'(2i16)') numnod_dummy, internal_node_dummy
      do i = 1, numnod_dummy
        write(id_file,'(i16,1p3e23.15)') i, ele_vector_IO(i,1:3)
      end do
!
      call deallocate_ele_vector_IO
!
      end subroutine write_vector_in_element
!
!------------------------------------------------------------------
!------------------------------------------------------------------
!
      subroutine write_geometry_info_b(id_file)
!
      integer (kind = kint), intent(in) :: id_file
      integer (kind = kint) :: i
!
!
      write(id_file) numnod_dummy, internal_node_dummy
!
      do i=1, numnod_dummy
        write(id_file)  globalnodid_dummy(i), xx_dummy(i,1:3)
      end do
!
      call deallocate_node_data_dummy
!
      end subroutine write_geometry_info_b
!
!------------------------------------------------------------------
!------------------------------------------------------------------
!
      subroutine read_number_of_node(id_file)
!
      use skip_comment_f
      integer (kind = kint), intent(in) :: id_file
!
!
      call skip_comment(character_4_read,id_file)
      read(character_4_read,*) numnod_dummy, internal_node_dummy
!      write(*,*) numnod_dummy, internal_node_dummy
!
      end subroutine read_number_of_node
!
!------------------------------------------------------------------
!
      subroutine read_geometry_info(id_file)
!
      integer (kind = kint), intent(in) :: id_file
      integer (kind = kint) :: i, k
!
!
      call allocate_node_data_dummy
!
      do i=1, numnod_dummy
        read(id_file,*)  globalnodid_dummy(i), (xx_dummy(i,k),k=1,3)
      end do
!
      end subroutine read_geometry_info
!
!------------------------------------------------------------------
!------------------------------------------------------------------
!
       subroutine read_number_of_node_b(id_file)
!
       integer (kind = kint), intent(in) :: id_file
!
       read(id_file) numnod_dummy, internal_node_dummy
!      write(*,*) numnod_dummy, internal_node_dummy
!
       end subroutine read_number_of_node_b
!
!------------------------------------------------------------------
!
       subroutine read_geometry_info_b(id_file)
!
       integer (kind = kint), intent(in) :: id_file
       integer (kind = kint) :: i, k
!
!
       call allocate_node_data_dummy
!
       do i=1, numnod_dummy
        read(id_file)  globalnodid_dummy(i), (xx_dummy(i,k),k=1,3)
       end do
!
       end subroutine read_geometry_info_b
!
!------------------------------------------------------------------
!
      end module node_geometry_IO
