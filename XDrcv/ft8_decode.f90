! modified by Wayne Wright, W5XD
! I would really rather not have to do this....
! WSJTX 2.2 introduced early decodes. (well, DigiRite actually "introduced" the feature.)
! The WSJTX 2.2 implementation of early decodes is rather rigid. It MUST be called when
! 41, 47 and 50 symbols are available and not at any other number of symbols of data available.
! it does some optimization--the 47 and 50 runs use fortran static data saved from prior runs.
! But maybe not everyone wants to run the FT8 decoder that way...
! 
!This implementation of the ft8_decode routine detects repeated calls
!with nzhsym at 50 and provides decodes in that case.
module ft8_decode

  parameter (MAXFOX=1000)
  character*12 c2fox(MAXFOX)
  character*4  g2fox(MAXFOX)
  integer nsnrfox(MAXFOX)
  integer nfreqfox(MAXFOX)
  integer n30fox(MAXFOX)
  integer n30z
  integer nfox

  type :: ft8_decoder
     procedure(ft8_decode_callback), pointer :: callback
   contains
     procedure :: decode
  end type ft8_decoder

  abstract interface
     subroutine ft8_decode_callback (this,sync,snr,dt,freq,decoded,nap,qual)
       import ft8_decoder
       implicit none
       class(ft8_decoder), intent(inout) :: this
       real, intent(in) :: sync
       integer, intent(in) :: snr
       real, intent(in) :: dt
       real, intent(in) :: freq
       character(len=37), intent(in) :: decoded
       integer, intent(in) :: nap 
       real, intent(in) :: qual 
     end subroutine ft8_decode_callback
  end interface

contains

    subroutine decode(this,callback,iwave,nQSOProgress,nfqso,nftx,newdat,  &
       nutc,nfa,nfb,nzhsym,ndepth,emedelay,ncontest,nagain,lft8apon,     &
       lapcqonly,napwid,mycall12,hiscall12,ldiskdat)
    use iso_c_binding, only: c_bool, c_int
    use timer_module, only: timer
    use ISO_FORTRAN_ENV

    include 'ft8/ft8_params.f90'

    class(ft8_decoder), intent(inout) :: this
    procedure(ft8_decode_callback) :: callback
    parameter (MAXCAND=300,MAX_EARLY=100)
    real*8 tsec,tseq
    real s(NH1,NHSYM)
    real sbase(NH1)
    real candidate(3,MAXCAND)
    real dd(15*12000),dd1(15*12000)
    logical, intent(in) :: lft8apon,lapcqonly,nagain
    logical newdat,lsubtract,ldupe,lrefinedt
    logical*1 ldiskdat
    logical lsubtracted(MAX_EARLY)
    character*12 mycall12,hiscall12
    integer*2 iwave(15*12000)
    integer apsym2(58),aph10(10)
    character datetime*13,msg37*37
    character*37 allmessages(100)
    character*12 ctime
    integer allsnrs(100)
    integer itone(NN)
    integer itone_save(NN,MAX_EARLY)
    real f1_save(MAX_EARLY)
    real xdt_save(MAX_EARLY)
    integer nzhsym_save;

    save s,dd,dd1,ndec_early,itone_save,f1_save,xdt_save,lsubtracted,allmessages, nzhsym_save
    
    this%callback => callback
    write(datetime,1001) nutc        !### TEMPORARY ###
1001 format("000000_",i6.6)

    call ft8apset(mycall12,hiscall12,ncontest,apsym2,aph10)
!WSJTX 2.2 uses nzhsym and the "save" of ndec_early and itone_save to call
!subtractft8 on the current sound samples (higher nzhsym) w.r.t. the previously
!detected itones (previous nzhsym).
!That code is "rigid" in the sense that it only works for the specific values of
!nzysym of 41, 47, and 50 in that order.
!In order to get any decodes at all, this modification supports calling nzhsym = 50
!repeatedly
    if (nzhsym.eq.50 .and. nzhsym_save.eq.50) then
           dd=iwave
           ndecodes=0
           allmessages='                                     '
           allsnrs=0
           !this write appears on stderr, which the XDFT wrapper picks out separate from stdout
           !write(ERROR_UNIT,*) "ft8_decode 50"
           !call flush(ERROR_UNIT)
    else
        !write(ERROR_UNIT,*) "ft8_decode other ", nzhsym
        if(nzhsym.le.47) then
           dd=iwave
           dd1=dd
        endif
        if(nzhsym.eq.41) then
           ndecodes=0
           allmessages='                                     '
           allsnrs=0
        else
           ndecodes=ndec_early
        endif
        if(nzhsym.eq.47 .and. ndec_early.eq.0) then
           dd1=dd
           go to 800
        endif
        if(nzhsym.eq.47 .and. ndec_early.ge.1) then
           lsubtracted=.false.
           lrefinedt=.true.
           if(ndepth.le.2) lrefinedt=.false.
           call timer('sub_ft8b',0)
           do i=1,ndec_early
              if(xdt_save(i)-0.5.lt.0.396) then
                 call subtractft8(dd,itone_save(1,i),f1_save(i),xdt_save(i),  &
                      lrefinedt)
                 lsubtracted(i)=.true.
              endif
              call timestamp(tsec,tseq,ctime)
              if(.not.ldiskdat .and. tseq.ge.14.3d0) then !Bail out before done
                 call timer('sub_ft8b',1)
                 dd1=dd
                 go to 800
              endif
           enddo
           call timer('sub_ft8b',1)
           dd1=dd
           go to 900
        endif
        if(nzhsym.eq.50 .and. ndec_early.ge.1) then
           n=47*3456
           dd(1:n)=dd1(1:n)
           dd(n+1:)=iwave(n+1:)
           call timer('sub_ft8c',0)
           do i=1,ndec_early
              if(lsubtracted(i)) cycle
              call subtractft8(dd,itone_save(1,i),f1_save(i),xdt_save(i),.true.)
           enddo
           call timer('sub_ft8c',1)
        endif
    endif
    nzhsym_save = nzhsym;
    ifa=nfa
    ifb=nfb
    if(nagain) then
       ifa=nfqso-10
       ifb=nfqso+10
    endif

! For now:
! ndepth=1: 1 pass, bp  
! ndepth=2: subtraction, 3 passes, bp+osd (no subtract refinement) 
! ndepth=3: subtraction, 3 passes, bp+osd
    npass=3
    if(ndepth.eq.1) npass=1
    do ipass=1,npass
      newdat=.true.
      syncmin=1.3
      if(ndepth.le.2) syncmin=1.6
      if(ipass.eq.1) then
        lsubtract=.true.
        ndeep=ndepth
        if(ndepth.eq.3) ndeep=2
      elseif(ipass.eq.2) then
        n2=ndecodes
        if(ndecodes.eq.0) cycle
        lsubtract=.true.
        ndeep=ndepth
      elseif(ipass.eq.3) then
        if((ndecodes-n2).eq.0) cycle
        lsubtract=.true. 
        ndeep=ndepth
      endif 
      call timer('sync8   ',0)
      maxc=MAXCAND
      call sync8(dd,ifa,ifb,syncmin,nfqso,maxc,s,candidate,   &
           ncand,sbase)
      call timer('sync8   ',1)
      do icand=1,ncand
        sync=candidate(3,icand)
        f1=candidate(1,icand)
        xdt=candidate(2,icand)
        xbase=10.0**(0.1*(sbase(nint(f1/3.125))-40.0))
        msg37='                                     '
        call timer('ft8b    ',0)
        call ft8b(dd,newdat,nQSOProgress,nfqso,nftx,ndeep,nzhsym,lft8apon,  &
             lapcqonly,napwid,lsubtract,nagain,ncontest,iaptype,mycall12,   &
             hiscall12,f1,xdt,xbase,apsym2,aph10,nharderrors,dmin,          &
             nbadcrc,iappass,msg37,xsnr,itone)
        call timer('ft8b    ',1)
        nsnr=nint(xsnr) 
        xdt=xdt-0.5
        hd=nharderrors+dmin
        if(nbadcrc.eq.0) then
           ldupe=.false.
           do id=1,ndecodes
              if(msg37.eq.allmessages(id)) ldupe=.true.
           enddo
           if(.not.ldupe) then
              ndecodes=ndecodes+1
              allmessages(ndecodes)=msg37
              allsnrs(ndecodes)=nsnr
              f1_save(ndecodes)=f1
              xdt_save(ndecodes)=xdt+0.5
              itone_save(1:NN,ndecodes)=itone
           endif
           if(.not.ldupe .and. associated(this%callback)) then
              qual=1.0-(nharderrors+dmin)/60.0 ! scale qual to [0.0,1.0]
              if(emedelay.ne.0) xdt=xdt+2.0
              call this%callback(sync,nsnr,xdt,f1,msg37,iaptype,qual)
           endif
        endif
        call timestamp(tsec,tseq,ctime)
        if(.not.ldiskdat .and. nzhsym.eq.41 .and.                        &
             tseq.ge.13.4d0) go to 800                 !Bail out before done
      enddo  ! icand
   enddo  ! ipass

800 ndec_early=0
   if(nzhsym.lt.50) ndec_early=ndecodes

900 return
end subroutine decode

subroutine timestamp(tsec,tseq,ctime)
  real*8 tsec,tseq
  character*12 ctime
  integer itime(8)
  call date_and_time(values=itime)
  tsec=3600.d0*(itime(5)-itime(4)/60.d0) + 60.d0*itime(6) +      &
       itime(7) + 0.001d0*itime(8)
  tsec=mod(tsec+2*86400.d0,86400.d0)
  tseq=mod(itime(7)+0.001d0*itime(8),15.d0)
  if(tseq.lt.10.d0) tseq=tseq+15.d0
  sec=itime(7)+0.001*itime(8)
  write(ctime,1000) itime(5)-itime(4)/60,itime(6),sec
1000 format(i2.2,':',i2.2,':',f6.3)
  if(ctime(7:7).eq.' ') ctime(7:7)='0'
  return
end subroutine timestamp

end module ft8_decode
