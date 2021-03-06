!>@file   set_radius_4_sph_dynamo.f90
!!@brief  module set_radius_4_sph_dynamo
!!
!!@author H. Okuda and H. Matsui
!!@date Programmed in  2008
!
!> @brief Set radial information
!!
!!@verbatim
!!      Programmed by H. Matsui on June., 1994
!!      modified by H. Matsui on Apr., 2009
!!
!!      subroutine set_radius_dat_4_sph_dynamo
!!***********************************************************************
!!*
!!*       ar_1d_rj(k,1)   : 1 / r
!!*       ar_1d_rj(k,2)   : 1 / r**2
!!*       ar_1d_rj(k,3)   : 1 / r**3
!!*
!!***********************************************************************
!!@endverbatim
!
!
      module set_radius_4_sph_dynamo
!
      use m_precision
!
      use m_constants
      use m_machine_parameter
      use m_spheric_constants
      use m_spheric_parameter
!
      implicit none
!
!  -------------------------------------------------------------------
!
      contains
!
!  -------------------------------------------------------------------
!
      subroutine set_radius_dat_4_sph_dynamo
!
      use m_group_data_sph_specr
      use set_radial_grid_sph_shell
      use skip_comment_f
!
      integer(kind = kint) :: k, kk
!
!
!* --------  radius  --------------
!
      do k = 1, num_radial_grp_rj
        if(     cmp_no_case(name_radial_grp_rj(k),                    &
     &                      ICB_nod_grp_name)) then
          kk = istack_radial_grp_rj(k-1) + 1
          nlayer_ICB = item_radial_grp_rj(kk)
        else if(cmp_no_case(name_radial_grp_rj(k),                    &
     &                      CMB_nod_grp_name)) then
          kk = istack_radial_grp_rj(k-1) + 1
          nlayer_CMB = item_radial_grp_rj(kk)
        else if(cmp_no_case(name_radial_grp_rj(k),                    &
     &                      CTR_nod_grp_name)) then
          kk = istack_radial_grp_rj(k-1) + 1
          nlayer_2_center = item_radial_grp_rj(kk)
        end if
      end do
!
      r_CMB = radius_1d_rj_r(nlayer_CMB)
      r_ICB = radius_1d_rj_r(nlayer_ICB)
!
      R_earth(0) = (64.0d0 / 35.0d0) * r_CMB
      R_earth(1) = one / R_earth(0)
      R_earth(2) = one / R_earth(0)**2
!
!
      call set_radial_distance_flag(nidx_rj(1), nlayer_ICB, nlayer_CMB, &
     &    r_ICB, r_CMB, radius_1d_rj_r, iflag_radial_grid)
!
!
      do k = 1 ,nlayer_CMB
        ar_1d_rj(k,1) = one / radius_1d_rj_r(k)
        ar_1d_rj(k,2) = ar_1d_rj(k,1)**2
        ar_1d_rj(k,3) = ar_1d_rj(k,1)**3
      end do
!
      r_ele_rj(1) = half * radius_1d_rj_r(1)
      do k = 2 ,nlayer_CMB
        r_ele_rj(k) = half * (radius_1d_rj_r(k-1) + radius_1d_rj_r(k))
        ar_ele_rj(k,1) = one / r_ele_rj(k)
        ar_ele_rj(k,2) = ar_ele_rj(k,1)**2
        ar_ele_rj(k,3) = ar_ele_rj(k,1)**3
      end do
!
      if(iflag_debug .gt. 0) then
        write(*,*) 'nlayer_ICB', nlayer_ICB, radius_1d_rj_r(nlayer_ICB)
        write(*,*) 'nlayer_CMB', nlayer_CMB, radius_1d_rj_r(nlayer_CMB)
        write(*,*) 'iflag_radial_grid', iflag_radial_grid
      end if
!
      end subroutine set_radius_dat_4_sph_dynamo
!
!  -------------------------------------------------------------------
!
      end module set_radius_4_sph_dynamo
