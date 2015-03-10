!
!      module m_control_data_4_iso
!
!        programmed by H.Matsui on May. 2006
!
!      subroutine deallocate_cont_dat_4_iso(iso)
!        type(iso_ctl), intent(inout) :: iso
!
!      subroutine read_control_data_4_iso(iso)
!        type(iso_ctl), intent(inout) :: iso
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!     example of control for Kemo's surface rendering
!!
!!  begin isosurf_rendering
!!    iso_file_head    'psf'
!!    iso_output_type  ucd
!!
!!    begin isosurf_define
!!      isosurf_field        pressure
!!      isosurf_component      scalar
!!      isosurf_value            4000.0
!!
!!      begin plot_area_ctl
!!        array chosen_ele_grp_ctl   2
!!          chosen_ele_grp_ctl   inner_core   end
!!          chosen_ele_grp_ctl   outer_core   end
!!        end array chosen_ele_grp_ctl
!!      end plot_area_ctl
!!    end isosurf_define
!!
!!    begin isosurf_result_define
!!      result_type      constant
!!      result_value     0.7
!!      array output_field   2
!!        output_field    velocity         vector   end
!!        output_field    magnetic_field   radial   end
!!      end array output_field
!!    end isosurf_result_define
!!
!!  end isosurf_rendering
!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!
!!    iso_output_type:
!!           ucd, OpenDX
!!
!!    result_type:  (Original name: display_method)
!!                   specified_fields
!!                   constant
!!    num_result_comp: number of fields
!!    output_field: (Original name: color_comp and color_subcomp)
!!         field and componenet name for output
!!           x, y, z, radial, elevation, azimuth, cylinder_r
!!           norm, vector, tensor, spherical_vector, cylindrical_vector
!!    result_value: (Original name: specified_color)
!!
!!    
!!
!!    isosurf_data: field for isosurface
!!    isosurf_comp: component for isosurface
!!           x, y, z, radial, elevation, azimuth, cylinder_r, norm
!!    isosurf_value:  value for isosurface
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      module m_control_data_4_iso
!
      use m_precision
!
      use m_constants
      use m_machine_parameter
      use m_read_control_elements
      use skip_comment_f
      use t_read_control_arrays
!
      implicit  none
!
!
      type iso_ctl
        character(len=kchara) :: iso_file_head_ctl
        character(len=kchara) :: iso_output_type_ctl
!
        character(len=kchara) :: isosurf_data_ctl(1)
        character(len=kchara) :: isosurf_comp_ctl(1)
        real(kind=kreal) :: isosurf_value_ctl
        real(kind=kreal) :: result_value_iso_ctl
!
        character(len=kchara) :: iso_result_type_ctl
!
!>      Structure for list of output field
!!@n      iso_out_field_ctl%c1_tbl: Name of field
!!@n      iso_out_field_ctl%c2_tbl: Name of component
        type(ctl_array_c2) :: iso_out_field_ctl
!
!>      Structure for element group list for isosurfacing
!!@n      iso_area_ctl%c_tbl: Name of element group
        type(ctl_array_chara) :: iso_area_ctl
!
!     Top level
        integer (kind=kint) :: i_iso_ctl = 0
!     2nd level for isosurf_rendering
        integer (kind=kint) :: i_iso_file_head = 0
        integer (kind=kint) :: i_iso_out_type =  0
        integer (kind=kint) :: i_iso_define =    0
        integer (kind=kint) :: i_iso_result =    0
!     3nd level for isosurf_define
        integer (kind=kint) :: i_iso_field =     0
        integer (kind=kint) :: i_iso_comp =      0
        integer (kind=kint) :: i_iso_value =     0
        integer (kind=kint) :: i_iso_plot_area = 0
!     3rd level for isosurf_result_define
        integer (kind=kint) :: i_result_type =     0
        integer (kind=kint) :: i_result_value =    0
!
      end type iso_ctl
!
!     Top level
      character(len=kchara) :: hd_iso_ctl = 'isosurf_rendering'
!
!     2nd level for isosurf_rendering
      character(len=kchara) :: hd_iso_file_head = 'iso_file_head'
      character(len=kchara) :: hd_iso_out_type = 'iso_output_type'
      character(len=kchara) :: hd_iso_define = 'isosurf_define'
      character(len=kchara) :: hd_iso_result = 'isosurf_result_define'
!
!     3nd level for isosurf_define
      character(len=kchara) :: hd_iso_field =     'isosurf_field'
      character(len=kchara) :: hd_iso_comp =      'isosurf_component'
      character(len=kchara) :: hd_iso_value =     'isosurf_value'
      character(len=kchara) :: hd_iso_plot_area = 'plot_area_ctl'
!
!     4th level for plot_area_ctl
      character(len=kchara) :: hd_iso_plot_grp  = 'chosen_ele_grp_ctl'
!
!     3rd level for isosurf_result_define
      character(len=kchara) :: hd_result_type =       'result_type'
      character(len=kchara) :: hd_iso_result_field = 'output_field'
      character(len=kchara) :: hd_result_value =      'result_value'
!
      private :: hd_iso_plot_grp, hd_result_type
      private :: hd_result_value, hd_iso_plot_area, hd_iso_value
      private :: hd_iso_comp, hd_iso_field, hd_iso_result
      private :: hd_iso_define, hd_iso_out_type, hd_iso_file_head
      private :: hd_iso_result_field
!
      private :: read_iso_define_data, read_iso_control_data
      private :: read_iso_result_control, read_iso_plot_area_ctl
!
!  ---------------------------------------------------------------------
!
      contains
!
!  ---------------------------------------------------------------------
!
      subroutine deallocate_cont_dat_4_iso(iso)
!
      type(iso_ctl), intent(inout) :: iso
!
!
      call dealloc_control_array_c2(iso%iso_out_field_ctl)
      iso%iso_out_field_ctl%num =  0
      iso%iso_out_field_ctl%icou = 0
!
      call dealloc_control_array_chara(iso%iso_area_ctl)
      iso%iso_area_ctl%num =  0
      iso%iso_area_ctl%icou = 0
!
      end subroutine deallocate_cont_dat_4_iso
!
!  ---------------------------------------------------------------------
!  ---------------------------------------------------------------------
!
      subroutine read_control_data_4_iso(iso)
!
      type(iso_ctl), intent(inout) :: iso
!
!
      call load_ctl_label_and_line
      call read_iso_control_data(iso)
!
      end subroutine read_control_data_4_iso
!
!   --------------------------------------------------------------------
!   --------------------------------------------------------------------
!
      subroutine read_iso_control_data(iso)
!
      type(iso_ctl), intent(inout) :: iso
!
!
      if(right_begin_flag(hd_iso_ctl) .eq. 0) return
      if (iso%i_iso_ctl.gt.0) return
      do
        call load_ctl_label_and_line
!
        call find_control_end_flag(hd_iso_ctl, iso%i_iso_ctl)
        if(iso%i_iso_ctl .gt. 0) exit
!
        call read_iso_result_control(iso)
        call read_iso_define_data(iso)
!
!
        call read_character_ctl_item(hd_iso_file_head,                  &
     &          iso%i_iso_file_head, iso%iso_file_head_ctl)
        call read_character_ctl_item(hd_iso_out_type,                   &
     &        iso%i_iso_out_type, iso%iso_output_type_ctl)
      end do
!
      end subroutine read_iso_control_data
!
!   --------------------------------------------------------------------
!
      subroutine read_iso_define_data(iso)
!
      type(iso_ctl), intent(inout) :: iso
!
!
      if(right_begin_flag(hd_iso_define) .eq. 0) return
      if (iso%i_iso_define.gt.0) return
      do
        call load_ctl_label_and_line
!
        call find_control_end_flag(hd_iso_define, iso%i_iso_define)
        if(iso%i_iso_define .gt. 0) exit
!
        call  read_iso_plot_area_ctl(iso)
!
!
        call read_character_ctl_item(hd_iso_field,                      &
     &        iso%i_iso_field, iso%isosurf_data_ctl(1) )
        call read_character_ctl_item(hd_iso_comp,                       &
     &        iso%i_iso_comp, iso%isosurf_comp_ctl(1) )
!
        call read_real_ctl_item(hd_iso_value,                           &
     &        iso%i_iso_value, iso%isosurf_value_ctl)
      end do
!
      end subroutine read_iso_define_data
!
!   --------------------------------------------------------------------
!
      subroutine read_iso_result_control(iso)
!
      type(iso_ctl), intent(inout) :: iso
!
!
      if(right_begin_flag(hd_iso_result) .eq. 0) return
      if (iso%i_iso_result.gt.0) return
      do
        call load_ctl_label_and_line
!
        call find_control_end_flag(hd_iso_result, iso%i_iso_result)
        if(iso%i_iso_result .gt. 0) exit
!
        call read_control_array_c2                                      &
     &     (hd_iso_result_field, iso%iso_out_field_ctl)
!
        call read_character_ctl_item(hd_result_type,                    &
     &        iso%i_result_type, iso%iso_result_type_ctl)
!
        call read_real_ctl_item(hd_result_value,                        &
     &        iso%i_result_value, iso%result_value_iso_ctl)
      end do
!
      end subroutine read_iso_result_control
!
!   --------------------------------------------------------------------
!
      subroutine read_iso_plot_area_ctl(iso)
!
      type(iso_ctl), intent(inout) :: iso
!
!
      if(right_begin_flag(hd_iso_plot_area) .eq. 0) return
      if (iso%i_iso_plot_area.gt.0) return
      do
        call load_ctl_label_and_line
!
        call find_control_end_flag(hd_iso_plot_area,                    &
     &      iso%i_iso_plot_area)
        if(iso%i_iso_plot_area .gt. 0) exit
!
        call read_control_array_c1(hd_iso_plot_grp, iso%iso_area_ctl)
      end do
!
      end subroutine read_iso_plot_area_ctl
!
!   --------------------------------------------------------------------
!
      end module m_control_data_4_iso
