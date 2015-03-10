!>@file   copy_sph_groups_from_IO.f90
!!@brief  module copy_sph_groups_from_IO
!!
!!@author H. Matsui
!!@date Programmed in July, 2007
!
!>@brief Copy sphectr grouping data from IO
!!
!!@verbatim
!!      subroutine copy_rtp_nod_grp_from_IO
!!      subroutine copy_rtp_radial_grp_from_IO
!!      subroutine copy_rtp_theta_grp_from_IO
!!      subroutine copy_rtp_zonal_grp_from_IO
!!      subroutine copy_rj_radial_grp_from_IO
!!      subroutine copy_rj_sphere_grp_from_IO
!!@endverbatim
!
!
      module copy_sph_groups_from_IO
!
      use m_precision
!
      use m_constants
      use m_group_data_sph_specr
      use m_group_data_sph_specr_IO
!
      implicit none
!
! -----------------------------------------------------------------------
!
      contains
!
! -----------------------------------------------------------------------
!
      subroutine copy_rtp_nod_grp_from_IO
!
!
      num_bc_grp_rtp =  num_bc_grp_rtp_IO
      call allocate_rtp_nod_grp_stack
!
      if (num_bc_grp_rtp .gt. izero) then
!
        ntot_bc_grp_rtp = ntot_bc_grp_rtp_IO
        call allocate_rtp_nod_grp_item
!
        name_bc_grp_rtp(1:num_bc_grp_rtp)                               &
     &        = name_bc_grp_rtp_IO(1:num_bc_grp_rtp)
        istack_bc_grp_rtp(0:num_bc_grp_rtp)                             &
     &        = istack_bc_grp_rtp_IO(0:num_bc_grp_rtp)
        item_bc_grp_rtp(1:ntot_bc_grp_rtp)                              &
     &        = item_bc_grp_rtp_IO(1:ntot_bc_grp_rtp)
      else
        ntot_bc_grp_rtp = 0
        call allocate_rtp_nod_grp_item
      end if
!
      call deallocate_rtp_nod_grp_IO_item
!
      end subroutine copy_rtp_nod_grp_from_IO
!
! -----------------------------------------------------------------------
!
      subroutine copy_rtp_radial_grp_from_IO
!
!
      num_radial_grp_rtp =  num_radial_grp_rtp_IO
      call allocate_rtp_r_grp_stack
!
      if (num_radial_grp_rtp .gt. izero) then
!
        ntot_radial_grp_rtp = ntot_radial_grp_rtp_IO
        call allocate_rtp_r_grp_item
!
        name_radial_grp_rtp(1:num_radial_grp_rtp)                       &
     &        = name_radial_grp_rtp_IO(1:num_radial_grp_rtp)
        istack_radial_grp_rtp(0:num_radial_grp_rtp)                     &
     &        = istack_radial_grp_rtp_IO(0:num_radial_grp_rtp)
        item_radial_grp_rtp(1:ntot_radial_grp_rtp)                      &
     &        = item_radial_grp_rtp_IO(1:ntot_radial_grp_rtp)
      else
        ntot_radial_grp_rtp = 0
        call allocate_rtp_r_grp_item
      end if
!
      call deallocate_rtp_r_grp_IO_item
!
      end subroutine copy_rtp_radial_grp_from_IO
!
! -----------------------------------------------------------------------
!
      subroutine copy_rtp_theta_grp_from_IO
!
!
      num_theta_grp_rtp =  num_theta_grp_rtp_IO
      call allocate_rtp_theta_grp_stack
!
      if (num_theta_grp_rtp .gt. izero) then
!
        ntot_theta_grp_rtp = ntot_theta_grp_rtp_IO
        call allocate_rtp_theta_grp_item
!
        name_theta_grp_rtp(1:num_theta_grp_rtp)                         &
     &        = name_theta_grp_rtp_IO(1:num_theta_grp_rtp)
        istack_theta_grp_rtp(0:num_theta_grp_rtp)                       &
     &        = istack_theta_grp_rtp_IO(0:num_theta_grp_rtp)
        item_theta_grp_rtp(1:ntot_theta_grp_rtp)                        &
     &        = item_theta_grp_rtp_IO(1:ntot_theta_grp_rtp)
      else
        ntot_theta_grp_rtp = 0
        call allocate_rtp_theta_grp_item
      end if
!
      call deallocate_rtp_t_grp_IO_item
!
      end subroutine copy_rtp_theta_grp_from_IO
!
! -----------------------------------------------------------------------
!
      subroutine copy_rtp_zonal_grp_from_IO
!
!
      num_zonal_grp_rtp =  num_zonal_grp_rtp_IO
      call allocate_rtp_zonal_grp_stack
!
      if (num_zonal_grp_rtp .gt. izero) then
!
        ntot_zonal_grp_rtp = ntot_zonal_grp_rtp_IO
        call allocate_rtp_zonal_grp_item
!
        name_zonal_grp_rtp(1:num_zonal_grp_rtp)                         &
     &        = name_zonal_grp_rtp_IO(1:num_zonal_grp_rtp)
        istack_zonal_grp_rtp(0:num_zonal_grp_rtp)                       &
     &        = istack_zonal_grp_rtp_IO(0:num_zonal_grp_rtp)
        item_zonal_grp_rtp(1:ntot_zonal_grp_rtp)                        &
     &        = item_zonal_grp_rtp_IO(1:ntot_zonal_grp_rtp)
      else
        ntot_zonal_grp_rtp = 0
        call allocate_rtp_zonal_grp_item
      end if
!
      call deallocate_rtp_p_grp_IO_item
!
      end subroutine copy_rtp_zonal_grp_from_IO
!
! -----------------------------------------------------------------------
!
      subroutine copy_rj_radial_grp_from_IO
!
!
      num_radial_grp_rj =  num_radial_grp_rj_IO
      call allocate_rj_r_grp_stack
!
      if (num_radial_grp_rj .gt. izero) then
!
        ntot_radial_grp_rj = ntot_radial_grp_rj_IO
        call allocate_rj_r_grp_item
!
        name_radial_grp_rj(1:num_radial_grp_rj)                         &
     &        = name_radial_grp_rj_IO(1:num_radial_grp_rj)
        istack_radial_grp_rj(0:num_radial_grp_rj)                       &
     &        = istack_radial_grp_rj_IO(0:num_radial_grp_rj)
        item_radial_grp_rj(1:ntot_radial_grp_rj)                        &
     &        = item_radial_grp_rj_IO(1:ntot_radial_grp_rj)
      else
        ntot_radial_grp_rj = 0
        call allocate_rj_r_grp_item
      end if
!
      call deallocate_rj_r_grp_IO_item
!
      end subroutine copy_rj_radial_grp_from_IO
!
! -----------------------------------------------------------------------
!
      subroutine copy_rj_sphere_grp_from_IO
!
!
      num_sphere_grp_rj =  num_sphere_grp_rj_IO
      call allocate_rj_sphere_grp_stack
!
      if (num_sphere_grp_rj .gt. izero) then
!
        ntot_sphere_grp_rj = ntot_sphere_grp_rj_IO
        call allocate_rj_sphere_grp_item
!
        name_sphere_grp_rj(1:num_sphere_grp_rj)                         &
     &        = name_sphere_grp_rj_IO(1:num_sphere_grp_rj)
        istack_sphere_grp_rj(0:num_sphere_grp_rj)                       &
     &        = istack_sphere_grp_rj_IO(0:num_sphere_grp_rj)
        item_sphere_grp_rj(1:ntot_sphere_grp_rj)                        &
     &        = item_sphere_grp_rj_IO(1:ntot_sphere_grp_rj)
      else
        ntot_sphere_grp_rj = 0
        call allocate_rj_sphere_grp_item
      end if
!
      call deallocate_rj_j_grp_IO_item
!
      end subroutine copy_rj_sphere_grp_from_IO
!
! -----------------------------------------------------------------------
!
      end module copy_sph_groups_from_IO
 