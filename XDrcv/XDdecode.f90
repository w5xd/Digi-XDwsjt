subroutine xddecode(params, id2, temporary_directory)
    ! Copyright (c) 2019 by Wayne E. Wright, W5XD.
    ! 
    ! stripped down version of wsjtx-2.0.0 
    ! subroutine multimode_decoder in decoder.f90
    ! everything that is not FT8/FT4 is removed.
    ! 
    ! Its a problem of choose your poison. The choices considered were:
    ! A) This modified version of multimode_decoder 
    ! OR
    ! B) Don't modify any wsjtx source and instead make XDft8 depend
    ! on an existing jt9.exe in an existing install on the 
    ! deployed machine.
    ! 
    ! Both introduce undesirable dependencies, but I see no
    ! addtional alternatives.
    ! (A) is bad because promotes very private interfaces internal
    ! to wsjtx to become a public interface used by XDft8.
    !
    ! (B) is less bad w.r.t. private interfaces because it
    ! uses the jt9common and shared memory as-is. Its also
    ! cool because XDft8 builds need not figure out how to
    ! compile/link the ft8 decoder at all. But...
    ! It has the undesirable requirement to deploy a wsjtx-2.0.0 
    ! binary. And what happens when WSJT-X upgrades and removes
    ! updates that binary in way that XDft8 cannot use? (not pretty.)
    ! And then there is the problem that when WSJT-X runs, it
    ! does a seek&destroy on "jt9.exe" processes...which kills
    ! any XDft8 decoders that were running...
    ! 
    ! I also considered:
    ! (C) link a dll with the wsjtx decoder.f90, multimode_decoder
    ! as its main entry point. That avoids this invention of a new entry
    ! point to support for XDft8 to call. But...
    ! Linking multimode_decoder pulls in, it appears,
    ! pretty much every .f90 file in the source tree, and some
    ! stuff who's source is not in the lib folder. So I quit
    ! pulling that thread out of the sweater and... 
    !
    ! As of this writing, I decided that (A) is preferable to (B).
    ! ...so here is a stripped down version of multimode_decoder
    ! that is capable only of FT8 and FT4.
        
  use timer_module, only: timer
  use ft8_decode
  use ft4_decode
  use iso_c_binding, only: C_CHAR, c_null_char
 
  include 'jt9com.f90'
  include 'timer_common.inc'

  integer(c_short) id2(NMAX)
  type(params_block) :: params
  character(kind=c_char, len=1), dimension(*), intent(in) :: temporary_directory
  character(len=500) :: temp_dir
  integer i

  type, extends(ft8_decoder) :: counting_ft8_decoder
     integer :: decoded
  end type counting_ft8_decoder
  type, extends(ft4_decoder) :: counting_ft4_decoder
     integer :: decoded
  end type counting_ft4_decoder

  logical single_decode,bVHF,newdat,ex
  character(len=20) :: datetime
  character(len=12) :: mycall, hiscall
  character(len=6) :: mygrid, hisgrid
  save
  type(counting_ft8_decoder) :: my_ft8
  type(counting_ft4_decoder) :: my_ft4

  !cast C character arrays to Fortran character strings
  datetime=transfer(params%datetime, datetime)
  mycall=transfer(params%mycall,mycall)
  hiscall=transfer(params%hiscall,hiscall)
  mygrid=transfer(params%mygrid,mygrid)
  hisgrid=transfer(params%hisgrid,hisgrid)
  temp_dir = " ";
  do i=1,500
   if (temporary_directory(i) == c_null_char) exit
   temp_dir(i:i) = temporary_directory(i)
  end do

  ! initialize decode counts
  my_ft8%decoded = 0
  my_ft4%decoded = 0

  single_decode=iand(params%nexp_decode,32).ne.0
  bVHF=iand(params%nexp_decode,64).ne.0
  if(mod(params%nranera,2).eq.0) ntrials=10**(params%nranera/2)
  if(mod(params%nranera,2).eq.1) ntrials=3*10**(params%nranera/2)
  if(params%nranera.eq.0) ntrials=0
  
  nfail=0
10 if (params%nagain) then
     open(13,file=trim(temp_dir)//'/decoded.txt',status='unknown',            &
          position='append',iostat=ios)
  else
     open(13,file=trim(temp_dir)//'/decoded.txt',status='unknown',iostat=ios)
  endif
  if(ios.ne.0) then
     nfail=nfail+1
     if(nfail.le.3) then
        call sleep_msec(10)
        go to 10
     endif
  endif

  if(params%nmode.eq.8) then
! We're in FT8 mode
     
     if(ncontest.eq.5) then
! Fox mode: initialize and open houndcallers.txt     
        inquire(file=trim(temp_dir)//'/houndcallers.txt',exist=ex)
        if(.not.ex) then
           c2fox='            '
           g2fox='    '
           nsnrfox=-99
           nfreqfox=-99
           n30z=0
           nwrap=0
           nfox=0
        endif
        open(19,file=trim(temp_dir)//'/houndcallers.txt',status='unknown')
     endif

     call timer('decft8  ',0)
     newdat=params%newdat
     ncontest=iand(params%nexp_decode,7)
     call my_ft8%decode(ft8_decoded,id2,params%nQSOProgress,params%nfqso,    &
          params%nftx,newdat,params%nutc,params%nfa,params%nfb,              &
          params%ndepth,ncontest,logical(params%nagain),                     &
          logical(params%lft8apon),logical(params%lapcqonly),                &
          params%napwid,mycall,hiscall,hisgrid)
     call timer('decft8  ',1)
     if(nfox.gt.0) then
        n30min=minval(n30fox(1:nfox))
        n30max=maxval(n30fox(1:nfox))
     endif
     j=0

     if(ncontest.eq.5) then
! Fox mode: save decoded Hound calls for possible selection by FoxOp
        rewind 19
        if(nfox.eq.0) then
           endfile 19
           rewind 19
        else
           do i=1,nfox
              n=n30fox(i)
              if(n30max-n30fox(i).le.4) then
                 j=j+1
                 c2fox(j)=c2fox(i)
                 g2fox(j)=g2fox(i)
                 nsnrfox(j)=nsnrfox(i)
                 nfreqfox(j)=nfreqfox(i)
                 n30fox(j)=n
                 m=n30max-n
                 if(len(trim(g2fox(j))).eq.4) then
                    call azdist(mygrid,g2fox(j)//'  ',0.d0,nAz,nEl,nDmiles,	&
                         nDkm,nHotAz,nHotABetter)
                 else
                    nDkm=9999
                 endif
                 write(19,1004) c2fox(j),g2fox(j),nsnrfox(j),nfreqfox(j),nDkm,m
1004             format(a12,1x,a4,i5,i6,i7,i3)
              endif
           enddo
           nfox=j
           flush(19)
        endif
     endif
     go to 800
  endif

  if(params%nmode.eq.5) then
     call timer('decft4  ',0)
     call my_ft4%decode(ft4_decoded,id2,params%nQSOProgress,params%nfqso,    &
          params%nutc,params%nfa,params%nfb,params%ndepth,                   &
          logical(params%lapcqonly),ncontest,mycall,hiscall)
     call timer('decft4  ',1)
     go to 800
  endif

800 ndecoded = my_ft4%decoded + my_ft8%decoded
  write(*,1010) nsynced,ndecoded
1010 format('<DecodeFinished>',2i4)
  call flush(6)
  close(13)
  close(19)
  if(params%nmode.eq.4 .or. params%nmode.eq.65) close(14)

  return

contains

  subroutine ft8_decoded (this,sync,snr,dt,freq,decoded,nap,qual)
    use ft8_decode
    implicit none

    class(ft8_decoder), intent(inout) :: this
    real, intent(in) :: sync
    integer, intent(in) :: snr
    real, intent(in) :: dt
    real, intent(in) :: freq
    character(len=37), intent(in) :: decoded
    character c1*12,c2*12,g2*4,w*4
    integer i0,i1,i2,i3,i4,i5,n30,nwrap
    integer, intent(in) :: nap 
    real, intent(in) :: qual 
    character*2 annot
    character*37 decoded0
    logical isgrid4,first,b0,b1,b2
    data first/.true./
    save

    isgrid4(w)=(len_trim(w).eq.4 .and.                                        &
         ichar(w(1:1)).ge.ichar('A') .and. ichar(w(1:1)).le.ichar('R') .and.  &
         ichar(w(2:2)).ge.ichar('A') .and. ichar(w(2:2)).le.ichar('R') .and.  &
         ichar(w(3:3)).ge.ichar('0') .and. ichar(w(3:3)).le.ichar('9') .and.  &
         ichar(w(4:4)).ge.ichar('0') .and. ichar(w(4:4)).le.ichar('9'))

    if(first) then
       c2fox='            '
       g2fox='    '
       nsnrfox=-99
       nfreqfox=-99
       n30z=0
       nwrap=0
       nfox=0
       first=.false.
    endif
    
    decoded0=decoded

    annot='  ' 
    if(ncontest.eq.0 .and. nap.ne.0) then
       write(annot,'(a1,i1)') 'a',nap
       if(qual.lt.0.17) decoded0(37:37)='?'
    endif

!    i0=index(decoded0,';')
! Always print 37 characters? Or, send i3,n3 up to here from ft8b_2 and use them
! to decide how many chars to print?
!TEMP
    i0=1
    if(i0.le.0) write(*,1000) params%nutc,snr,dt,nint(freq),decoded0(1:22),annot
1000 format(i6.6,i4,f5.1,i5,' ~ ',1x,a22,1x,a2)
    if(i0.gt.0) write(*,1001) params%nutc,snr,dt,nint(freq),decoded0,annot
1001 format(i6.6,i4,f5.1,i5,' ~ ',1x,a37,1x,a2)
    write(13,1002) params%nutc,nint(sync),snr,dt,freq,0,decoded0
1002 format(i6.6,i4,i5,f6.1,f8.0,i4,3x,a37,' FT8')

    if(ncontest.eq.5) then
    i1=index(decoded0,' ')
    i2=i1 + index(decoded0(i1+1:),' ')
    i3=i2 + index(decoded0(i2+1:),' ')
    if(i1.ge.3 .and. i2.ge.7 .and. i3.ge.10) then
       c1=decoded0(1:i1-1)//'            '
       c2=decoded0(i1+1:i2-1)
       g2=decoded0(i2+1:i3-1)
       b0=c1.eq.mycall
       if(c1(1:3).eq.'DE ' .and. index(c2,'/').ge.2) b0=.true.
       if(len(trim(c1)).ne.len(trim(mycall))) then
          i4=index(trim(c1),trim(mycall))
          i5=index(trim(mycall),trim(c1))
          if(i4.ge.1 .or. i5.ge.1) b0=.true.
       endif
       b1=i3-i2.eq.5 .and. isgrid4(g2)
       b2=i3-i2.eq.1
       if(b0 .and. (b1.or.b2) .and. nint(freq).ge.1000) then
          n=params%nutc
          n30=(3600*(n/10000) + 60*mod((n/100),100) + mod(n,100))/30
          if(n30.lt.n30z) nwrap=nwrap+5760    !New UTC day, handle the wrap
          n30z=n30
          n30=n30+nwrap
             if(nfox.lt.MAXFOX) nfox=nfox+1
          c2fox(nfox)=c2
          g2fox(nfox)=g2
          nsnrfox(nfox)=snr
          nfreqfox(nfox)=nint(freq)
          n30fox(nfox)=n30
       endif
    endif
    endif
    
    call flush(6)
    call flush(13)
    
    select type(this)
    type is (counting_ft8_decoder)
       this%decoded = this%decoded + 1
    end select

    return
  end subroutine ft8_decoded
  
subroutine ft4_decoded (this,sync,snr,dt,freq,decoded,nap,qual)
    use ft4_decode
    implicit none

    class(ft4_decoder), intent(inout) :: this
    real, intent(in) :: sync
    integer, intent(in) :: snr
    real, intent(in) :: dt
    real, intent(in) :: freq
    character(len=37), intent(in) :: decoded
    character c1*12,c2*12,g2*4,w*4
    integer i0,i1,i2,i3,i4,i5,n30,nwrap
    integer, intent(in) :: nap 
    real, intent(in) :: qual 
    character*2 annot
    character*37 decoded0
    
    decoded0=decoded

    annot='  ' 
    if(ncontest.eq.0 .and. nap.ne.0) then
       write(annot,'(a1,i1)') 'a',nap
       if(qual.lt.0.17) decoded0(37:37)='?'
    endif

    write(*,1001) params%nutc,snr,dt,nint(freq),decoded0,annot
1001 format(i6.6,i4,f5.1,i5,' + ',1x,a37,1x,a2)
    write(13,1002) params%nutc,nint(sync),snr,dt,freq,0,decoded0
1002 format(i6.6,i4,i5,f6.1,f8.0,i4,3x,a37,' FT4')
    
    call flush(6)
    call flush(13)
    
    select type(this)
    type is (counting_ft4_decoder)
       this%decoded = this%decoded + 1
    end select

    return
  end subroutine ft4_decoded
end subroutine xddecode 

subroutine sleep_msec(m)
        integer m
end subroutine sleep_msec

