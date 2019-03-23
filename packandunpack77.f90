!unpack77 wants mycall in its hash table. probably already there, though
subroutine xdsetpack77mycall(mycall)
  use iso_c_binding, only: c_char
  use packjt77
  implicit none
  character(len=1,kind=c_char), dimension(13), intent(in) :: mycall
  integer i

  do i = 1, 13
        mycall13(i:i) = mycall(i)
  end do
end subroutine xdsetpack77mycall

subroutine xdsetpack77dxcall(dxcall)
  use iso_c_binding, only: c_char
  use packjt77
  implicit none
  character(len=1,kind=c_char), dimension(13), intent(in) :: dxcall
  integer i
  do i = 1, 13
        dxcall13(i:i) = dxcall(i)
  end do
end subroutine xdsetpack77dxcall

!c callable entry point for pack77
subroutine xdpack77(msg,i3,n3,c77)
  use iso_c_binding, only: c_char
  use packjt77
  implicit none
  character(len=1,kind=c_char), dimension(37), intent(in) :: msg
  character*37 msg_0
  character(len=1,kind=c_char), dimension(77), intent(out) :: c77
  character*77 c77_0
  integer i3
  integer n3
  integer i
  do i=1,37
     msg_0(i:i) = msg(i)
  end do
  c77_0 = " ";
  call pack77(msg_0, i3, n3, c77_0)
  do i=1,77
     c77(i) = c77_0(i:i)
  end do
end subroutine xdpack77

!c callable entry point for unpack77
subroutine xdunpack77(c77,nrx,msg,unpk77_success)
  use iso_c_binding, only: c_char
  use packjt77
  implicit none
  character(len=1,kind=c_char), dimension(37), intent(out) :: msg
  character*37 msg_0
  character(len=1,kind=c_char), dimension(77), intent(in) :: c77
  character*77 c77_0
  integer n3
  integer nrx
  integer i
  logical unpk77_success
  do i=1,77
     c77_0(i:i) = c77(i)
  end do
  msg_0 = " ";
  call unpack77(c77_0, nrx, msg_0, unpk77_success)
  do i=1,37
     msg(i) = msg_0(i:i)
  end do
end subroutine xdunpack77

