!>@file   mesh_data_IO.f90
!!@brief  module mesh_data_IO
!!
!!@author H. Matsui
!!@date Programmed by H.Matsui and H.Okuda in July 2000
!!@n     Modified by H. Matsui on Sep., 2006
!
!>@brief  Routines for ASCII mesh data IO
!!
!!@verbatim
!!      subroutine write_geometry_data
!!      subroutine write_geometry_data_b
!!
!!      subroutine read_geometry_data
!!      subroutine read_geometry_data_b
!!
!!      subroutine output_node_sph_geometry
!!      subroutine output_node_cyl_geometry
!!@endverbatim
!
      module mesh_data_IO
!
      use m_precision
!
      use m_read_mesh_data
      use domain_data_IO
      use comm_stack_item_IO
      use node_geometry_IO
      use element_connect_IO
!
      implicit  none
!
      integer(kind=kint) :: iflag_sph_file_name = 0
      integer(kind=kint) :: iflag_cyl_file_name = 0
      character(len=kchara), parameter, private                         &
     &                   :: mesh_sph_def_head = 'mesh/node_sph'
      character(len=kchara), parameter, private                         &
     &                   :: mesh_cyl_def_head = 'mesh/node_cyl'
      character(len=kchara) :: mesh_sph_file_head = mesh_sph_def_head
      character(len=kchara) :: mesh_cyl_file_head = mesh_cyl_def_head
!
!------------------------------------------------------------------
!
      contains
!
!------------------------------------------------------------------
!
      subroutine write_geometry_data
!
      use m_fem_mesh_labels
!
!
      write(input_file_code,'(a)', advance='NO') hd_fem_para()
      call write_domain_info(input_file_code)
!
      write(input_file_code,'(a)', advance='NO') hd_fem_node()
      call write_geometry_info(input_file_code)
!
!
      write(input_file_code,'(a)', advance='NO') hd_fem_elem()
      call write_element_info(input_file_code)
!
!
      write(input_file_code,'(a)', advance='NO') hd_fem_import()
      call write_import_data(input_file_code)
!
!
      write(input_file_code,'(a)', advance='NO') hd_fem_export()
      call write_export_data(input_file_code)
!
      end subroutine write_geometry_data
!
!------------------------------------------------------------------
!
      subroutine write_geometry_data_b
!
!
      call write_domain_info_b(input_file_code)
!
      call write_geometry_info_b(input_file_code)
      call write_element_info_b(input_file_code)
!
      call write_import_data_b(input_file_code)
      call write_export_data_b(input_file_code)
!
      end subroutine write_geometry_data_b
!
!------------------------------------------------------------------
!------------------------------------------------------------------
!
       subroutine read_geometry_data
!
!
!        write(*,*) 'read_domain_info'
        call read_domain_info(input_file_code)
!        write(*,*) 'read_number_of_node'
        call read_number_of_node(input_file_code)
!        write(*,*) 'read_geometry_info'
        call read_geometry_info(input_file_code)
!
!  ----  read element data -------
!
!        write(*,*) 'read_number_of_element'
        call read_number_of_element(input_file_code)
!        write(*,*) 'read_element_info'
        call read_element_info(input_file_code)
!
! ----  import & export 
!
!        write(*,*) 'read_import_data'
        call read_import_data(input_file_code)
!        write(*,*) 'read_export_data'
        call read_export_data(input_file_code)
!
       end subroutine read_geometry_data
!
!------------------------------------------------------------------
!
       subroutine read_geometry_data_b
!
!
        call read_domain_info_b(input_file_code)
        call read_number_of_node_b(input_file_code)
        call read_geometry_info_b(input_file_code)
!
!  ----  read element data -------
!
        call read_number_of_element_b(input_file_code)
        call read_element_info_b(input_file_code)
!
! ----  import & export 
!
        call read_import_data_b(input_file_code)
        call read_export_data_b(input_file_code)
!
       end subroutine read_geometry_data_b
!
!------------------------------------------------------------------
!------------------------------------------------------------------
!
      subroutine output_node_sph_geometry
!
      use m_fem_mesh_labels
!
!
      write(input_file_code,'(a)', advance='NO') hd_fem_para_sph()
      write(input_file_code,'(a)', advance='NO') hd_fem_para()
      call write_domain_info(input_file_code)
!
      write(input_file_code,'(a)', advance='NO') hd_fem_node_sph()
      call write_geometry_info(input_file_code)
!
      end subroutine output_node_sph_geometry
!
!  ---------------------------------------------------------------------
!
      subroutine output_node_cyl_geometry
!
      use m_fem_mesh_labels
!
!
      write(input_file_code,'(a)', advance='NO') hd_fem_para_cyl()
      write(input_file_code,'(a)', advance='NO') hd_fem_para()
!
!
      call write_domain_info(input_file_code)
!
      write(input_file_code,'(a)', advance='NO') hd_fem_node_cyl()
      call write_geometry_info(input_file_code)
!
      end subroutine output_node_cyl_geometry
!
!------------------------------------------------------------------
!
      end module mesh_data_IO
