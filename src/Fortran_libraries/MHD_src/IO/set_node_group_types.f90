!>@file   set_node_group_types.f90
!!@brief  module set_node_group_types
!!
!!@author H. Matsui and H. Okuda
!!@date Programmed by H. Matsui in Sep. 2005
!
!> @brief set surface boundary condition flags from conterol input
!!
!!@verbatim
!!      subroutine set_bc_group_types_scalar(bc_type_ctl, ibc_type)
!!      subroutine set_bc_group_types_vector(bc_type_ctl, ibc_type)
!!      subroutine set_bc_group_types_sgs_scalar(bc_type_ctl, ibc_type)
!!      subroutine set_bc_group_types_sgs_vect(bc_type_ctl, ibc_type)
!!      subroutine set_bc_group_types_rotation(bc_type_ctl, ibc_type)
!!      subroutine set_bc_group_types_sph_center(bc_type_ctl, ibc_type)
!!      subroutine set_bc_group_types_fluxes(bc_type_ctl, ibc_type)
!!@endverbatim
!
      module set_node_group_types
!
      use m_precision
      use m_boundary_condition_IDs
      use skip_comment_f
!
      implicit none
!
!>      control name for fixed field by control
      character(len = kchara), parameter :: fixed_bc =     'fixed'
!>      control name for fixed field by control
      character(len = kchara), parameter :: fixed_ctl_bc = 'fixed_ctl'
!>      control name for fixed field by external file
      character(len = kchara), parameter :: fixed_file =    'file'
!>      control name for fixed field by external file
      character(len = kchara), parameter :: fixed_file_bc = 'fixed_file'
!>      control name for fixed field in SGS model
      character(len = kchara), parameter :: fixed_SGS =  'sgs'
!
!>      control name for fixed x-componenet by control
      character(len = kchara), parameter :: fixed_x = 'fix_x'
!>      control name for fixed y-componenet by control
      character(len = kchara), parameter :: fixed_y = 'fix_y'
!>      control name for fixed z-componenet by control
      character(len = kchara), parameter :: fixed_z = 'fix_z'
!>      control name for fixed x-componenet by control
      character(len = kchara), parameter :: fix_ctl_x = 'fix_ctl_x'
!>      control name for fixed y-componenet by control
      character(len = kchara), parameter :: fix_ctl_y = 'fix_ctl_y'
!>      control name for fixed z-componenet by control
      character(len = kchara), parameter :: fix_ctl_z = 'fix_ctl_z'
!
!>      control name for fixed x-componenet by external file
      character(len = kchara), parameter :: bc_file_x = 'file_x'
!>      control name for fixed y-componenet by external file
      character(len = kchara), parameter :: bc_file_y = 'file_y'
!>      control name for fixed z-componenet by external file
      character(len = kchara), parameter :: bc_file_z = 'file_z'
!>      control name for fixed x-componenet by external file
      character(len = kchara), parameter :: fix_file_x = 'fix_file_x'
!>      control name for fixed y-componenet by external file
      character(len = kchara), parameter :: fix_file_y = 'fix_file_y'
!>      control name for fixed z-componenet by external file
      character(len = kchara), parameter :: fix_file_z = 'fix_file_z'
!
!>      control name for fixed x-componenet in SGS model
      character(len = kchara), parameter :: fix_SGS_x = 'sgs_x'
!>      control name for fixed y-componenet in SGS model
      character(len = kchara), parameter :: fix_SGS_y = 'sgs_y'
!>      control name for fixed z-componenet in SGS model
      character(len = kchara), parameter :: fix_SGS_z = 'sgs_z'
!>      control name for fixed rotation around x-axis boundary
      character(len = kchara), parameter :: fix_rot_x = 'rot_x'
!>      control name for fixed rotation around y-axis boundary
      character(len = kchara), parameter :: fix_rot_y = 'rot_y'
!>      control name for fixed rotation around z-axis boundary
      character(len = kchara), parameter :: fix_rot_z = 'rot_z'
!
!>      control name to filling to center
      character(len = kchara), parameter                                &
     &               :: fill_sph_center = 'sph_to_center'
!>      control name to filling to center
      character(len = kchara), parameter                                &
     &               :: fix_sph_center = 'fix_at_center'
!
!>      control name for fixed flux by control
      character(len = kchara), parameter :: flux_bc = 'fixed_flux'
!>      control name for fixed flux by external file
      character(len = kchara), parameter                                &
     &               :: flux_file_bc = 'fixed_flux_file'
!
      private :: fixed_bc, fixed_ctl_bc, fixed_file, fixed_file_bc
      private :: flux_bc, flux_file_bc
      private :: fixed_SGS
      private :: fixed_x, fix_ctl_x, bc_file_x, fix_file_x
      private :: fixed_y, fix_ctl_y, bc_file_y, fix_file_y
      private :: fixed_z, fix_ctl_z, bc_file_z, fix_file_z
      private :: fix_SGS_x, fix_rot_x
      private :: fix_SGS_y, fix_rot_y
      private :: fix_SGS_z, fix_rot_z
      private :: fill_sph_center, fix_sph_center
!
!-----------------------------------------------------------------------
!
      contains
!
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_scalar(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if     (cmp_no_case(bc_type_ctl, fixed_bc) .gt. 0                 &
     &   .or. cmp_no_case(bc_type_ctl, fixed_ctl_bc) .gt. 0) then
        ibc_type =  iflag_bc_fix_s
      else if(cmp_no_case(bc_type_ctl, fixed_file) .gt. 0               &
     &   .or. cmp_no_case(bc_type_ctl, fixed_file_bc) .gt. 0) then
        ibc_type =  iflag_bc_file_s
      end if
!
      end subroutine set_bc_group_types_scalar
!
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_vector(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if      (cmp_no_case(bc_type_ctl, fixed_x) .gt.   0               &
     &    .or. cmp_no_case(bc_type_ctl, fix_ctl_x) .gt. 0) then
        ibc_type = iflag_bc_fix_x
      else if (cmp_no_case(bc_type_ctl, fixed_y) .gt.   0               &
     &    .or. cmp_no_case(bc_type_ctl, fix_ctl_y) .gt. 0) then
        ibc_type = iflag_bc_fix_y
      else if (cmp_no_case(bc_type_ctl, fixed_z) .gt. 0                 &
     &    .or. cmp_no_case(bc_type_ctl, fix_ctl_z) .gt. 0) then
        ibc_type = iflag_bc_fix_z
      else if (cmp_no_case(bc_type_ctl, bc_file_x) .gt. 0               &
     &    .or. cmp_no_case(bc_type_ctl, fix_file_x) .gt. 0) then
        ibc_type = iflag_bc_file_x
      else if (cmp_no_case(bc_type_ctl, bc_file_y) .gt. 0               &
     &    .or. cmp_no_case(bc_type_ctl, fix_file_y) .gt. 0) then
        ibc_type = iflag_bc_file_y
      else if (cmp_no_case(bc_type_ctl, bc_file_z) .gt. 0               &
     &    .or. cmp_no_case(bc_type_ctl, fix_file_z) .gt. 0) then
        ibc_type = iflag_bc_file_z
      end if
!
      end subroutine set_bc_group_types_vector
!
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_sgs_scalar(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if(cmp_no_case(bc_type_ctl, fixed_SGS).gt. 0) then
        ibc_type = iflag_bc_sgs_s
      end if
!
      end subroutine set_bc_group_types_sgs_scalar
!
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_sgs_vect(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if      (cmp_no_case(bc_type_ctl, fix_SGS_x) .gt. 0) then
        ibc_type = iflag_bc_sgs_x
      else if (cmp_no_case(bc_type_ctl, fix_SGS_y) .gt. 0) then
        ibc_type = iflag_bc_sgs_y
      else if (cmp_no_case(bc_type_ctl, fix_SGS_z) .gt. 0) then
        ibc_type = iflag_bc_sgs_z
      end if
!
      end subroutine set_bc_group_types_sgs_vect
!
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_rotation(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if      (cmp_no_case(bc_type_ctl, fix_rot_x) .gt. 0) then
        ibc_type = iflag_bc_rot + 1
      else if (cmp_no_case(bc_type_ctl, fix_rot_y) .gt. 0) then
        ibc_type = iflag_bc_rot + 2
      else if (cmp_no_case(bc_type_ctl, fix_rot_z) .gt. 0) then
        ibc_type = iflag_bc_rot + 3
      end if
!
      end subroutine set_bc_group_types_rotation
!
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_sph_center(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if      (cmp_no_case(bc_type_ctl, fill_sph_center) .gt. 0) then
        ibc_type = iflag_sph_2_center
      else if (cmp_no_case(bc_type_ctl, fix_sph_center) .gt. 0) then
        ibc_type = iflag_sph_clip_center
      end if
!
      end subroutine set_bc_group_types_sph_center
!
!-----------------------------------------------------------------------
!-----------------------------------------------------------------------
!
      subroutine set_bc_group_types_fluxes(bc_type_ctl, ibc_type)
!
      character (len=kchara), intent(in) :: bc_type_ctl
      integer(kind = kint), intent(inout) :: ibc_type
!
!
      if      (cmp_no_case(bc_type_ctl, flux_bc) .gt. 0) then
        ibc_type = iflag_bc_fix_flux
      else if (cmp_no_case(bc_type_ctl, flux_file_bc) .gt. 0) then
        ibc_type = iflag_bc_file_flux
      end if
!
      end subroutine set_bc_group_types_fluxes
!
!-----------------------------------------------------------------------
!
      end module set_node_group_types