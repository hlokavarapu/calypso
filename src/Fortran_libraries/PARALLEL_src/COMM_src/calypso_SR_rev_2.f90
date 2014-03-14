!>@file   calypso_SR_rev_2.f90
!!@brief  module calypso_SR_rev_2
!!
!!@author H. Matsui
!!@date Programmed in March, 2013
!
!>@brief  solenoidal data communication
!!@n      using reverse import table
!!
!!@verbatim
!!      subroutine calypso_send_recv_rev_2(nnod_org, nnod_new,          &
!!     &                           npe_send, isend_self,                &
!!     &                           id_pe_send, istack_send, inod_export,&
!!     &                           npe_recv, irecv_self,                &
!!     &                           id_pe_recv, istack_recv, irev_import,&
!!     &                           X_org, X_new)
!!      subroutine calypso_send_recv_rev_3x2(nnod_org, nnod_new,        &
!!     &                           npe_send, isend_self,                &
!!     &                           id_pe_send, istack_send, inod_export,&
!!     &                           npe_recv, irecv_self,                &
!!     &                           id_pe_recv, istack_recv, irev_import,&
!!     &                           X1_org, X2_org, X3_org,              &
!!     &                           X1_new, X2_new, X3_new)
!!@endverbatim
!!
!!@n @param  nnod_org    Number of data points for origin
!!@n @param  nnod_new    Number of components for destination
!!@n
!!@n @param  npe_send    Number of processses to send
!!@n @param  isend_self  Integer flag to copy within own process
!!@n @param  id_pe_send(npe_send)      Process ID to send
!!@n @param  istack_send(0:npe_send)
!!                    End points of send buffer for each process
!!@n @param  inod_export(istack_send(npe_send))
!!                    local node ID to copy in send buffer
!!@n
!!@n @param  npe_recv    Number of processses to receive
!!@n @param  irecv_self  Integer flag to copy within own process
!!@n @param  id_pe_recv(npe_send)      Process ID to receive
!!@n @param  istack_recv(0:npe_send)
!!                    End points of receive buffer for each process
!!@n @param  irev_import(nnod_new)
!!                    import buffer ID for each data point
!!@n
!!@n @param  X_org(2*nnod_org)   Send data
!!@n @param  X_new(2*nnod_new)   Received data
!
      module calypso_SR_rev_2
!
      use m_precision
      use m_constants
!
      implicit none
!
!-----------------------------------------------------------------------
!
      contains
!
!-----------------------------------------------------------------------
!
      subroutine calypso_send_recv_rev_2(nnod_org, nnod_new,            &
     &                           npe_send, isend_self,                  &
     &                           id_pe_send, istack_send, inod_export,  &
     &                           npe_recv, irecv_self,                  &
     &                           id_pe_recv, istack_recv, irev_import,  &
     &                           X_org, X_new)
!
      use calypso_mpi
      use m_solver_SR
      use set_to_send_buffer
      use set_from_recv_buf_rev
!
      integer(kind = kint), intent(in) :: nnod_org
      integer(kind = kint), intent(in) :: nnod_new
!
      integer(kind = kint), intent(in) :: npe_send, isend_self
      integer(kind = kint), intent(in) :: id_pe_send(npe_send)
      integer(kind = kint), intent(in) :: istack_send(0:npe_send)
      integer(kind = kint), intent(in)                                  &
     &                      :: inod_export( istack_send(npe_send) )
!
      integer(kind = kint), intent(in) :: npe_recv, irecv_self
      integer(kind = kint), intent(in) :: id_pe_recv(npe_recv)
      integer(kind = kint), intent(in) :: istack_recv(0:npe_recv)
      integer(kind = kint), intent(in) :: irev_import(nnod_new)
!
      real (kind=kreal), intent(in)::    X_org(2*nnod_org)
!
      real (kind=kreal), intent(inout):: X_new(2*nnod_new)
!
      integer (kind = kint) :: neib, ist, num
      integer (kind = kint) :: i
      integer (kind = kint) :: ncomm_send, ncomm_recv
      integer (kind = kint) :: ist_send, ist_recv
!
!
      call resize_work_sph_SR(itwo, npe_send, npe_recv,                 &
     &    istack_send(npe_send), istack_recv(npe_recv))
!
      ncomm_send = npe_send - isend_self
      ncomm_recv = npe_recv - irecv_self
!
!C-- SEND
!
      call set_to_send_buf_2(nnod_org,                                  &
     &    istack_send(npe_send), inod_export, X_org, WS)
!C
      do neib = 1, ncomm_send
        ist= 2 * istack_send(neib-1) + 1
        num  = 2 * (istack_send(neib  ) - istack_send(neib-1))
        call MPI_ISEND(WS(ist), num, CALYPSO_REAL,                      &
     &      id_pe_send(neib), 0, CALYPSO_COMM, req1(neib), ierr_MPI)
      end do
!C
!C-- RECEIVE
      if(ncomm_recv .gt. 0) then
        do neib= 1, ncomm_recv
          ist= 2 * istack_recv(neib-1) + 1
          num  = 2 * (istack_recv(neib  ) - istack_recv(neib-1))
          call MPI_IRECV(WR(ist), num, CALYPSO_REAL,                    &
     &      id_pe_recv(neib), 0, CALYPSO_COMM, req2(neib), ierr_MPI)
        end do
!
        call MPI_WAITALL (ncomm_recv, req2, sta2, ierr_MPI)
      end if
!
      if (isend_self .eq. 1) then
        ist_send= 2 * istack_send(npe_send-1)
        ist_recv= 2 * istack_recv(npe_recv-1)
        num = 2*(istack_send(npe_send) - istack_send(npe_send-1))
!$omp parallel do
        do i = 1, num
          WR(ist_recv+i) = WS(ist_send+i)
        end do
!$omp end parallel do
      end if
!
      call set_from_recv_buf_rev_2(nnod_new,                            &
     &    istack_recv(npe_recv), irev_import, WR, X_new)
!
      if(ncomm_send .gt. 0) then
        call MPI_WAITALL (ncomm_send, req1, sta1, ierr_MPI)
      end if
!
      end subroutine calypso_send_recv_rev_2
!
! ----------------------------------------------------------------------
!
      subroutine calypso_send_recv_rev_3x2(nnod_org, nnod_new,          &
     &                           npe_send, isend_self,                  &
     &                           id_pe_send, istack_send, inod_export,  &
     &                           npe_recv, irecv_self,                  &
     &                           id_pe_recv, istack_recv, irev_import,  &
     &                           X1_org, X2_org, X3_org,                &
     &                           X1_new, X2_new, X3_new)
!
      use calypso_mpi
      use m_solver_SR
      use set_to_send_buf_tri
      use set_from_recv_buf_rev_tri
!
      integer(kind = kint), intent(in) :: nnod_org
      integer(kind = kint), intent(in) :: nnod_new
!
      integer(kind = kint), intent(in) :: npe_send, isend_self
      integer(kind = kint), intent(in) :: id_pe_send(npe_send)
      integer(kind = kint), intent(in) :: istack_send(0:npe_send)
      integer(kind = kint), intent(in)                                  &
     &                      :: inod_export( istack_send(npe_send) )
!
      integer(kind = kint), intent(in) :: npe_recv, irecv_self
      integer(kind = kint), intent(in) :: id_pe_recv(npe_recv)
      integer(kind = kint), intent(in) :: istack_recv(0:npe_recv)
      integer(kind = kint), intent(in) :: irev_import(nnod_new)
!
      real (kind=kreal), intent(in)::    X1_org(2*nnod_org)
      real (kind=kreal), intent(in)::    X2_org(2*nnod_org)
      real (kind=kreal), intent(in)::    X3_org(2*nnod_org)
!
      real (kind=kreal), intent(inout):: X1_new(2*nnod_new)
      real (kind=kreal), intent(inout):: X2_new(2*nnod_new)
      real (kind=kreal), intent(inout):: X3_new(2*nnod_new)
!
      integer (kind = kint) :: neib, ist, num
      integer (kind = kint) :: i
      integer (kind = kint) :: ncomm_send, ncomm_recv
      integer (kind = kint) :: ist_send, ist_recv
!
!
      call resize_work_sph_SR((itwo*ithree), npe_send, npe_recv,        &
     &    istack_send(npe_send), istack_recv(npe_recv))
!
      ncomm_send = npe_send - isend_self
      ncomm_recv = npe_recv - irecv_self
!
!C-- SEND
!
      call set_to_send_buf_3x2(nnod_org, istack_send(npe_send),         &
     &    inod_export, X1_org, X2_org, X3_org, WS)
!C
      do neib = 1, ncomm_send
        ist= 6 * istack_send(neib-1) + 1
        num  = 6 * (istack_send(neib  ) - istack_send(neib-1))
        call MPI_ISEND(WS(ist), num, CALYPSO_REAL,                      &
     &      id_pe_send(neib), 0, CALYPSO_COMM, req1(neib), ierr_MPI)
      end do
!C
!C-- RECEIVE
      if(ncomm_recv .gt. 0) then
        do neib= 1, ncomm_recv
          ist= 6 * istack_recv(neib-1) + 1
          num  = 6 * (istack_recv(neib  ) - istack_recv(neib-1))
          call MPI_IRECV(WR(ist), num, CALYPSO_REAL,                    &
     &      id_pe_recv(neib), 0, CALYPSO_COMM, req2(neib), ierr_MPI)
        end do
!
        call MPI_WAITALL (ncomm_recv, req2, sta2, ierr_MPI)
      end if
!
      if (isend_self .eq. 1) then
        ist_send= 6 * istack_send(npe_send-1)
        ist_recv= 6 * istack_recv(npe_recv-1)
        num = 6*(istack_send(npe_send) - istack_send(npe_send-1))
!$omp parallel do
        do i = 1, num
          WR(ist_recv+i) = WS(ist_send+i)
        end do
!$omp end parallel do
      end if
!
      call set_from_recv_buf_rev_3x2(nnod_new, istack_recv(npe_recv),   &
     &    irev_import, WR, X1_new, X2_new, X3_new)
!
      if(ncomm_send .gt. 0) then
        call MPI_WAITALL (ncomm_send, req1, sta1, ierr_MPI)
      end if
!
      end subroutine calypso_send_recv_rev_3x2
!
! ----------------------------------------------------------------------
!
      end module calypso_SR_rev_2
