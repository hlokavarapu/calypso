!>@file   m_spheric_global_ranks.f90
!!@brief  module m_spheric_global_ranks
!!
!!@author H. Matsui
!!@date   Programmed  H. Matsui in July, 2007
!
!>@brief  Global subdomain informatikn for spherical shell
!!
!!@verbatim
!!      subroutine allocate_sph_ranks
!!      subroutine allocate_sph_1d_domain_id
!!
!!      subroutine deallocate_sph_ranks
!!      subroutine deallocate_sph_1d_domain_id
!!
!!      subroutine check_sph_domains(nprocs, ierr, e_message)
!!      subroutine check_sph_ranks(my_rank)
!!      subroutine check_sph_1d_domain_id
!!@endverbatim
!
      module m_spheric_global_ranks
!
      use m_precision
!
      implicit none
!
!>      number of subdomains
      integer(kind = kint) :: ndomain_sph
!
!>      number of 1d subdomains for @f$ f(r,\theta,\phi) @f$
      integer(kind = kint) :: ndomain_rtp(3)
!>      number of 1d subdomains for @f$ f(r,l,m) @f$
      integer(kind = kint) :: ndomain_rlm(2)
!>      number of 1d subdomains for @f$ f(r,j) @f$
      integer(kind = kint) :: ndomain_rj(2)
!>      number of 1d subdomains for @f$ f(r,\theta,m) @f$
      integer(kind = kint) :: ndomain_rtm(3)
!
      integer(kind = kint), allocatable :: iglobal_rank_rtp(:,:)
      integer(kind = kint), allocatable :: iglobal_rank_rtm(:,:)
      integer(kind = kint), allocatable :: iglobal_rank_rlm(:,:)
      integer(kind = kint), allocatable :: iglobal_rank_rj(:,:)
!
      integer(kind = kint), allocatable :: id_domain_rtp_r(:)
      integer(kind = kint), allocatable :: id_domain_rtp_t(:)
      integer(kind = kint), allocatable :: id_domain_rtp_p(:)
      integer(kind = kint), allocatable :: id_domain_rj_r(:)
      integer(kind = kint), allocatable :: id_domain_rj_j(:)
!
! -----------------------------------------------------------------------
!
      contains
!
! -----------------------------------------------------------------------
!
      subroutine allocate_sph_ranks
!
      allocate(iglobal_rank_rtp(3,0:ndomain_sph))
      allocate(iglobal_rank_rtm(3,0:ndomain_sph))
      allocate(iglobal_rank_rlm(2,0:ndomain_sph))
      allocate(iglobal_rank_rj(2,0:ndomain_sph))
!
      iglobal_rank_rtp = 0
      iglobal_rank_rtm = 0
      iglobal_rank_rlm = 0
      iglobal_rank_rj =  0
!
      end subroutine allocate_sph_ranks
!
! -----------------------------------------------------------------------
!
      subroutine allocate_sph_1d_domain_id
!
      use m_spheric_parameter
!
      integer(kind = kint) :: n1, n2, n3
!
      n1 = nidx_global_rtp(1)
      n2 = nidx_global_rtp(2)
      n3 = nidx_global_rtp(3)
      allocate( id_domain_rtp_r(n1) )
      allocate( id_domain_rtp_t(n2) )
      allocate( id_domain_rtp_p(n3) )
!
      id_domain_rtp_r = -1
      id_domain_rtp_t = -1
      id_domain_rtp_p = -1
!
!
!
      n1 = nidx_global_rj(1)
      n2 = nidx_global_rj(2)
      allocate( id_domain_rj_r(n1) )
      allocate( id_domain_rj_j(0:n2) )
!
      id_domain_rj_r = -1
      id_domain_rj_j = -1
!
      end subroutine allocate_sph_1d_domain_id
!
! -----------------------------------------------------------------------
! -----------------------------------------------------------------------
!
      subroutine deallocate_sph_ranks
!
      deallocate(iglobal_rank_rtp, iglobal_rank_rtm)
      deallocate(iglobal_rank_rlm, iglobal_rank_rj)
!
      end subroutine deallocate_sph_ranks
!
! -----------------------------------------------------------------------
!
      subroutine deallocate_sph_1d_domain_id
!
      deallocate( id_domain_rtp_r, id_domain_rtp_t, id_domain_rtp_p )
      deallocate( id_domain_rj_r, id_domain_rj_j )
!
      end subroutine deallocate_sph_1d_domain_id
!
! -----------------------------------------------------------------------
! -----------------------------------------------------------------------
!
      subroutine check_sph_domains(nprocs, ierr, e_message)
!
      use m_error_IDs
!
      integer(kind = kint), intent(in) :: nprocs
      integer(kind = kint), intent(inout) :: ierr
      character(len = kchara), intent(inout) :: e_message
      integer(kind = kint) :: np
!
!
      ierr = 0
      ndomain_sph = ndomain_rj(1)*ndomain_rj(2)
      if (ndomain_sph .ne. nprocs) then
        write(e_message,'(a)') 'check num of domain spectr file(r,j)'
        ierr = ierr_mesh
        return
      end if
!
      np = ndomain_rtp(1)*ndomain_rtp(2)*ndomain_rtp(3)
      if (ndomain_sph .ne. np) then
        write(e_message,'(a)') 'check num of domain for (r,t,p)'
        ierr = ierr_mesh
        return
      end if
      np = ndomain_rtm(1)*ndomain_rtm(2)*ndomain_rtm(3)
      if (ndomain_sph .ne. np) then
        write(e_message,'(a)') 'check num of domain for (r,t,m)'
        ierr = ierr_mesh
        return
      end if
      np = ndomain_rlm(1)*ndomain_rlm(2)
      if (ndomain_sph .ne. np) then
        write(e_message,'(a)') 'check num of domain for (r,l,m)'
        ierr = ierr_mesh
        return
      end if
!
      if(ndomain_rtm(1) .ne. ndomain_rtp(1)) then
        write(e_message,'(a,a1,a)')                                     &
     &            'Set same number of radial subdomains', char(10),     &
     &            'for Legendre transform and spherical grids'
        ierr = ierr_mesh
        return
      end if
!
      end subroutine check_sph_domains
!
! -----------------------------------------------------------------------
!
      subroutine check_sph_ranks(my_rank)
!
      integer(kind = kint), intent(in) :: my_rank
      integer(kind = kint) :: i
!
!
      write(my_rank+50,*) 'i, iglobal_rank_rtp'
      do i = 0, ndomain_sph-1
        write(my_rank+50,*) i, iglobal_rank_rtp(1:3,i)
      end do
!
      write(my_rank+50,*) 'i, iglobal_rank_rtm'
      do i = 0, ndomain_sph-1
        write(my_rank+50,*) i, iglobal_rank_rtm(1:3,i)
      end do
!
      write(my_rank+50,*) 'i, iglobal_rank_rlm'
      do i = 0, ndomain_sph-1
        write(my_rank+50,*) i, iglobal_rank_rlm(1:2,i)
      end do
!
      write(my_rank+50,*) 'i, iglobal_rank_rj'
      do i = 0, ndomain_sph-1
        write(my_rank+50,*) i, iglobal_rank_rj(1:2,i)
      end do
!
      end subroutine check_sph_ranks
!
! -----------------------------------------------------------------------
!
      subroutine check_sph_1d_domain_id
!
      use m_spheric_parameter
!
      write(50,*) 'id_domain_rtp_r'
      write(50,'(5i16)') id_domain_rtp_r(1:nidx_global_rtp(1))
!
      write(50,*) 'id_domain_rtp_t'
      write(50,'(5i16)') id_domain_rtp_t(1:nidx_global_rtp(2))
!
      write(50,*) 'id_domain_rtp_p'
      write(50,'(5i16)') id_domain_rtp_p(1:nidx_global_rtp(3))
!
!
      write(50,*) 'id_domain_rj_r'
      write(50,'(5i16)') id_domain_rj_r(1:nidx_global_rj(1))
!
      write(50,*) 'id_domain_rj_j'
      write(50,'(5i16)') id_domain_rj_j(0)
      write(50,'(5i16)') id_domain_rj_j(1:nidx_global_rj(2))
!
      end subroutine check_sph_1d_domain_id
!
! -----------------------------------------------------------------------
!
      end module m_spheric_global_ranks
