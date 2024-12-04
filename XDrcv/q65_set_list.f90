! Modified by Wayne Wright, W5XD, July, 2022
! This file, q65_set_list.f90 happens to contain the "stdcall" subroutine
! that is called, as of WSJTX 2.6, by FT8 decoding. The bulk of the code
! in this source file is not relevant to FT8, and introduces dependencies to 
! other q65 sources, so the expedient is to simply extract the needed subroutine

subroutine stdcall(callsign,std)

  character*12 callsign
  character*1 c
  logical is_digit,is_letter,std
!Statement functions:
  is_digit(c)=c.ge.'0' .and. c.le.'9'
  is_letter(c)=c.ge.'A' .and. c.le.'Z'

! Check for standard callsign
  iarea=-1
  n=len(trim(callsign))
  do i=n,2,-1
     if(is_digit(callsign(i:i))) exit
  enddo
  iarea=i                                   !Right-most digit (call area)
  npdig=0                                   !Digits before call area
  nplet=0                                   !Letters before call area
  do i=1,iarea-1
     if(is_digit(callsign(i:i))) npdig=npdig+1
     if(is_letter(callsign(i:i))) nplet=nplet+1
  enddo
  nslet=0                                   !Letters in suffix
  do i=iarea+1,n
     if(is_letter(callsign(i:i))) nslet=nslet+1
  enddo
  std=.true.
  if(iarea.lt.2 .or. iarea.gt.3 .or. nplet.eq.0 .or.       &
       npdig.ge.iarea-1 .or. nslet.gt.3) std=.false.

  return
end subroutine stdcall
