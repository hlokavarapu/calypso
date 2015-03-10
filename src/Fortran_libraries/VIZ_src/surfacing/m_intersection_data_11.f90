!
!     module m_intersection_data_11
!
      module m_intersection_data_11
!
!      Written by H. Matsui on june, 2006
!
      use m_precision
!
      implicit none
!
!
!   4 nodes which have differrent sign connected 3 edges
!      (one hexagonal ... 4 triangles)
!
!     flag = 1: c-c_ref >= 0
!     flag = 1: c-c_ref < 0
!
!       12345678: boundary...6 of 12: hexagonal
!                 (3-1-2), (4-1-3), (4-6-1), (4-5-6)
!  71:  11100010: 3-4, 7-8, 6-7, 2-6, 1-5, 4-1: 3-7-6-10- 9-4
!                  6-3-7, 10-3-6, 10-4-3, 10- 9-4
! 142:  01110001: 4-1, 8-5, 7-8, 3-7, 2-6, 1-2: 4-8-7-11-10-1
!                  7-4-8, 11-4-7, 11-1-4, 11-10-1
!  29:  10111000: 1-2, 5-6, 8-5, 4-8, 3-7, 2-3: 1-5-8-12-11-2
!                  8-1-5, 12-1-8, 12-2-1, 12-11-2
!  43:  11010100: 2-3, 6-7, 5-6, 1-5, 4-8, 3-4: 2-6-5- 9-12-3
!                  5-2-6,  9-2-5,  9-3-2,  9-12-3
!                  
! 184:  00011101: 7-8, 3-4, 4-1, 1-5, 2-6, 6-7: 7-3-4- 9-10-6
!                  4-7-3,  9-7-4,  9-6-7,  9-10-6
! 113:  10001110: 8-5, 4-1, 1-2, 2-6, 3-7, 7-8: 8-4-1-10-11-7
!                  1-8-4, 10-8-1, 10-7-8, 10-11-7
! 226:  01000111: 5-6, 1-2, 2-3, 3-7, 4-8, 8-5: 5-1-2-11-12-8
!                  2-5-1, 11-5-2, 11-8-5, 11-12-8
! 212:  00101011: 6-7, 2-3, 3-4, 4-8, 1-5, 5-6: 6-2-3-12- 9-5
!                  3-6-2, 12-6-3, 12-5-6, 12- 9-5
!                  
!  54:  01101100: 1-2, 3-4, 3-7, 6-7, 8-5, 1-5: 1-3-11-6-8- 9
!                  11-1-3, 6-1-11, 6- 9-1, 6-8- 9
! 108:  00110110: 2-3, 4-1, 4-8, 7-8, 5-6, 2-6: 2-4-12-7-5-10
!                  12-2-4, 7-2-12, 7-10-2, 7-5-10
! 201:  10010011: 3-4, 1-2, 1-5, 8-5, 6-7, 3-7: 3-1- 9-8-6-11
!                   9-3-1, 8-3- 9, 8-11-3, 8-6-11
! 147:  11001001: 4-1, 2-3, 2-6, 5-6, 7-8, 4-8: 4-2-10-5-7-12
!                  10-4-2, 5-4-10, 5-12-4, 5-7-12
!
!
      integer(kind = kint), parameter, private :: nnod_tri = 3
      integer(kind = kint), parameter, private :: nnod_hex = 6
!
      integer(kind = kint), parameter :: nkind_etype_11 = 12
      integer(kind = kint), parameter :: num_patch_11 =   4
      integer(kind = kint), parameter :: itri_2_patch_11(12)            &
     &     = (/3, 1, 2,   4, 1, 3,   4, 6, 1,   4, 5, 6/)
!
      integer(kind = kint), parameter                                   &
     &   :: iflag_psf_etype_11(nkind_etype_11)                          &
     &     = (/ 71, 142, 29,  43, 184, 113,                             &
     &         226, 212, 54, 108, 201, 147/)
!
!
      integer(kind = kint), parameter                                   &
     &        :: iedge_hex_11(nnod_hex, nkind_etype_11)                 &
     &      = reshape(                                                  &
     &       (/ 3, 7,  6, 10,  9,  4,    4, 8, 7, 11, 10, 1,            &
     &          1, 5,  8, 12, 11,  2,    2, 6, 5,  9, 12, 3,            &
     &          7, 3,  4,  9, 10,  6,    8, 4, 1, 10, 11, 7,            &
     &          5, 1,  2, 11, 12,  8,    6, 2, 3, 12,  9, 5,            &
     &          1, 3, 11,  6,  8,  9,    2, 4, 12, 7, 5, 10,            &
     &          3, 1,  9,  8,  6, 11,    4, 2, 10, 5, 7, 12/),          &
     &       shape=(/nnod_hex, nkind_etype_11/) )
!
      integer(kind = kint), parameter                                   &
     &        :: iedge_4_patch_11(nnod_tri,num_patch_11,nkind_etype_11) &
     &      = reshape(                                                  &
     &       (/ 6, 3, 7,   10, 3,  6,   10, 4, 3,   10,  9,  4,         &
     &          7, 4, 8,   11, 4,  7,   11, 1, 4,   11, 10,  1,         &
     &          8, 1, 5,   12, 1,  8,   12, 2, 1,   12, 11,  2,         &
     &          5, 2, 6,    9, 2,  5,    9, 3, 2,    9, 12,  3,         &
     &          4, 7, 3,    9, 7,  4,    9, 6, 7,    9, 10,  6,         &
     &          1, 8, 4,   10, 8,  1,   10, 7, 8,   10, 11,  7,         &
     &          2, 5, 1,   11, 5,  2,   11, 8, 5,   11, 12,  8,         &
     &          3, 6, 2,   12, 6,  3,   12, 5, 6,   12,  9,  5,         &
     &         11, 1, 3,    6, 1, 11,   6,  9, 1,    6,  8,  9,         &
     &         12, 2, 4,    7, 2, 12,   7, 10, 2,    7,  5, 10,         &
     &          9, 3, 1,    8, 3,  9,   8, 11, 3,    8,  6, 11,         &
     &         10, 4, 2,    5, 4, 10,   5, 12, 4,    5,  7, 12/),       &
     &       shape=(/nnod_tri,num_patch_11,nkind_etype_11/) )
!
      end module m_intersection_data_11
