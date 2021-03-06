!m_ctl_data_surf_boundary.f90
!      module m_ctl_data_surf_boundary
!
!        programmed by H.Matsui on March, 2006
!        Modified by H.Matsui on Oct., 2007
!
!      subroutine deallocate_bc_h_flux_ctl
!      subroutine deallocate_bc_torque_ctl
!      subroutine deallocate_bc_press_sf_ctl
!      subroutine deallocate_bc_magne_sf_ctl
!      subroutine deallocate_bc_vecp_sf_ctl
!      subroutine deallocate_bc_current_sf_ctl
!      subroutine deallocate_bc_mag_p_sf_ctl
!      subroutine deallocate_sf_comp_flux_ctl
!      subroutine deallocate_sf_infty_ctl
!
!      subroutine read_bc_4_surf
!
! ------------------------------------------------------------------
!   example
!
!    begin bc_4_surface
!!!!!  boundary condition for heat flux  !!!!!!!!!!!!!!!!!!!!!!!!!!
!  available type:  fixed, file, SGS_commute
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!      array heat_flux_surf  2
!        heat_flux_surf  fixed       outer  0.000  end
!        heat_flux_surf  SGS_commute inner  0.000  end
!      end array heat_flux_surf
!!!!!  boundary condition for torque  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  available type
!     fix_x,  fix_y,  fix_z
!     file_x, file_y, file_z
!     normal_velocity
!     free_shell_in, free_shell_out
!     free_4_plane
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!      array velocity_surf     2
!        velocity_surf  free_shell_in inner_surf   0.000  end
!        velocity_surf  free_shell_out  outer_surf   0.000  end
!      end array velocity_surf
!!!!!  boundary condition for pressure gradiend !!!!!!!!!!!!!!!!!!!
!  available type:  inner_shell, outer_shell
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       array pressure_surf  2
!         pressure_surf   inner_shell inner_surf 0.000  end
!         pressure_surf   outer_shell outer_surf 0.000  end
!      end array pressure_surf
!!!!!  boundary condition for gradientof magnetic field  !!!!!!!!!!
!     fix_x,  fix_y,  fix_z
!     insulate_in, insulate_out (not recommended)
!     far_away                  (not used)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       array magnetic_field_surf  3
!          magnetic_field_surf  insulate_in  ICB_surf  0.000 end
!          magnetic_field_surf  insulate_out CMB_surf  0.000 end
!          magnetic_field_surf  far_away infinity_surf  0.000 end
!      end array magnetic_field_surf
!!!!!  boundary condition for gradientof magnetic field  !!!!!!!!!!
!     fix_x,  fix_y,  fix_z
!     insulate_in, insulate_out (not recommended)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       array vector_potential_surf  1
!          vector_potential_surf  insulate_out CMB_surf  0.000 end
!      end array vector_potential_surf
!!!!!  boundary condition for current density on surface  !!!!!!!!!!
!     fix_x,  fix_y,  fix_z
!     insulate_in,insulate_out (not recommended)
!     far_away                  (not used)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       array current_surf  3
!          current_surf  insulate_in  ICB_surf  0.000 end
!          current_surf  insulate_out CMB_surf  0.000 end
!          current_surf  far_away infinity_surf  0.000 end
!      end array current_surf
!!!!!  boundary condition for magnetic potential !!!!!!!!!!!!!!!!!
!  available type:  fixed (not used), file (not used)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       array electric_potential_surf  1
!          electric_potential_surf  insulate_in  ICB_surf  0.000 end
!          electric_potential_surf  insulate_out CMB_surf  0.000 end
!          electric_potential_surf  far_away infinity_surf  0.000 end
!      end array electric_potential_surf
!!!!!  boundary condition for dummy scalar !!!!!!!!!!!!!!!!!
!  available type:  fixed_grad (not used), file_grad (not used)
!                   fixed_field
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!       array composition_flux_surf  3
!          composition_flux_surf  insulate_in  ICB_surf  0.000 end
!          composition_flux_surf  insulate_out CMB_surf  0.000 end
!          composition_flux_surf  far_away infinity_surf  0.000 end
!      end array composition_flux_surf
!!!!!  boundary condition for infinity (obsolute) !!!!!!!!!!!!!!!!!
!  available type:  fixed (not used), file (not used)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!      array infinity_surf 1
!        infinity_surf  fixed infinity_surf  0.000  end
!      end array infinity_surf
!    end  bc_4_surface
!
! ------------------------------------------------------------------
!
      module m_ctl_data_surf_boundary
!
      use m_precision
!
      use m_machine_parameter
      use t_read_control_arrays
!
      implicit  none
!
!
!>      Structure for surface boundary conditions for heat flux
!!@n      surf_bc_HF_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_HF_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_HF_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_HF_ctl
!
!>      Structure for surface boundary conditions for stress
!!@n      surf_bc_ST_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_ST_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_ST_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_ST_ctl
!
!>      Structure for surface boundary conditions for pressure gradient
!!@n      surf_bc_PN_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_PN_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_PN_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_PN_ctl
!
!>      Structure for surface boundary conditions
!!           for grad of magnetic field
!!@n      surf_bc_BN_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_BN_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_BN_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_BN_ctl
!
!>      Structure for surface boundary conditions
!!           for grad of current density
!!@n      surf_bc_JN_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_JN_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_JN_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_JN_ctl
!
!>      Structure for surface boundary conditions
!!          for grad of magnetic vector potential
!!@n      surf_bc_AN_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_AN_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_AN_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_AN_ctl
!
!>      Structure for surface boundary conditions
!!          for grad of magnetic scalar potential
!!@n      surf_bc_MPN_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_MPN_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_MPN_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_MPN_ctl
!
!>      Structure for surface boundary conditions for compositional flux
!!@n      surf_bc_CF_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_CF_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_CF_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_CF_ctl
!
!
!>      Structure for surface boundary conditions for infinity
!!@n      surf_bc_INF_ctl%c1_tbl:  Type of boundary conditions
!!@n      surf_bc_INF_ctl%c2_tbl:  Surface group name for boundary
!!@n      surf_bc_INF_ctl%vect:    boundary condition value
      type(ctl_array_c2r), save :: surf_bc_INF_ctl
!
!   entry label
!
      character(len=kchara), parameter                                  &
     &      :: hd_bc_4_surf =    'bc_4_surface'
      integer (kind=kint) :: i_bc_4_surf =     0
!
!   4th level for surface boundary
!
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_hf =     'heat_flux_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_mf =     'velocity_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_gradp =  'pressure_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_gradb =  'magnetic_field_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_grada =  'vector_potential_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_gradj =  'current_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_gradmp = 'electric_potential_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_gradc =  'composition_flux_surf'
      character(len=kchara), parameter                                  &
     &       :: hd_n_bc_infty =  'infinity_surf'
!
      private :: hd_bc_4_surf, i_bc_4_surf
      private :: hd_n_bc_hf, hd_n_bc_gradc, hd_n_bc_infty
      private :: hd_n_bc_mf, hd_n_bc_gradp, hd_n_bc_gradmp
      private :: hd_n_bc_gradb, hd_n_bc_grada, hd_n_bc_gradj
!
!   --------------------------------------------------------------------
!
      contains
!
!   --------------------------------------------------------------------
!
      subroutine deallocate_bc_h_flux_ctl
!
      call dealloc_control_array_c2_r(surf_bc_HF_ctl)
!
      end subroutine deallocate_bc_h_flux_ctl
!
! -----------------------------------------------------------------------
!
       subroutine deallocate_bc_torque_ctl
!
      call dealloc_control_array_c2_r(surf_bc_ST_ctl)
!
       end subroutine deallocate_bc_torque_ctl
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_bc_press_sf_ctl
!
      call dealloc_control_array_c2_r(surf_bc_PN_ctl)
!
      end subroutine deallocate_bc_press_sf_ctl
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_bc_magne_sf_ctl
!
      call dealloc_control_array_c2_r(surf_bc_BN_ctl)
!
      end subroutine deallocate_bc_magne_sf_ctl
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_bc_current_sf_ctl
!
      call dealloc_control_array_c2_r(surf_bc_JN_ctl)
!
      end subroutine deallocate_bc_current_sf_ctl
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_bc_vecp_sf_ctl
!
      call dealloc_control_array_c2_r(surf_bc_AN_ctl)
!
      end subroutine deallocate_bc_vecp_sf_ctl
!
! -----------------------------------------------------------------------
!
       subroutine deallocate_bc_mag_p_sf_ctl
!
      call dealloc_control_array_c2_r(surf_bc_MPN_ctl)
!
       end subroutine deallocate_bc_mag_p_sf_ctl
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_sf_comp_flux_ctl
!
      call dealloc_control_array_c2_r(surf_bc_CF_ctl)
!
      end subroutine deallocate_sf_comp_flux_ctl
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_sf_infty_ctl
!
      call dealloc_control_array_c2_r(surf_bc_INF_ctl)
!
      end subroutine deallocate_sf_infty_ctl
!
! -----------------------------------------------------------------------
! -----------------------------------------------------------------------
!
      subroutine read_bc_4_surf
!
      use m_read_control_elements
      use skip_comment_f
!
!
      if(right_begin_flag(hd_bc_4_surf) .eq. 0) return
      if (i_bc_4_surf.gt.0) return
      do
        call load_ctl_label_and_line
!
        call find_control_end_flag(hd_bc_4_surf, i_bc_4_surf)
        if(i_bc_4_surf .gt. 0) exit
!
!
        call read_control_array_c2_r(hd_n_bc_hf, surf_bc_HF_ctl)
        call read_control_array_c2_r(hd_n_bc_mf, surf_bc_ST_ctl)
        call read_control_array_c2_r(hd_n_bc_gradp, surf_bc_PN_ctl)
        call read_control_array_c2_r(hd_n_bc_gradb, surf_bc_BN_ctl)
        call read_control_array_c2_r(hd_n_bc_gradj, surf_bc_JN_ctl)
        call read_control_array_c2_r(hd_n_bc_grada, surf_bc_AN_ctl)
        call read_control_array_c2_r(hd_n_bc_gradmp, surf_bc_MPN_ctl)
        call read_control_array_c2_r(hd_n_bc_gradc, surf_bc_CF_ctl)
        call read_control_array_c2_r(hd_n_bc_infty, surf_bc_INF_ctl)
      end do
!
      end subroutine read_bc_4_surf
!
!   --------------------------------------------------------------------
!
      end module m_ctl_data_surf_boundary
